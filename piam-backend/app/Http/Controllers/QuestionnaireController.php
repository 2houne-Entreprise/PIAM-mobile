<?php

namespace App\Http\Controllers;

use App\Models\Questionnaire;
use App\Models\ControleTravaux;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

use Illuminate\Support\Facades\DB;

class QuestionnaireController extends Controller
{
    /**
     * Liste des questionnaires de l'utilisateur connecté.
     * GET /api/questionnaires?type=declenchement&localite_id=5
     */
    public function index(Request $request): JsonResponse
    {
        $query = Questionnaire::forUser(Auth::id());

        if ($request->has('type')) {
            $query->ofType($request->input('type'));
        }
        if ($request->has('localite_id')) {
            $query->forLocalite($request->input('localite_id'));
        }

        $questionnaires = $query->orderBy('updated_at', 'desc')->get();

        return response()->json($questionnaires);
    }

    /**
     * Créer un questionnaire.
     * POST /api/questionnaires
     */
    public function store(Request $request): JsonResponse
    {
        Log::info("=== SYNC REQUEST START ===");
        Log::info($request->all());

        $validator = Validator::make($request->all(), [
            'type'        => 'required|string|max:100',
            'data_json'   => 'required',
            'localite_id' => 'nullable|integer',
            'photo'       => 'nullable|image|max:10485', // max 10MB
            'photo_path'  => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $data['user_id'] = Auth::id();
        $data['sync_status'] = 'synced';

        $jsonArray = is_string($data['data_json']) ? json_decode($data['data_json'], true) : $data['data_json'];

        // Encoder data_json si c'est un tableau (pour stockage DB dans la colonne JSON)
        if (is_array($data['data_json'])) {
            $encodedJson = json_encode($data['data_json']);
        } else {
            $encodedJson = $data['data_json'];
        }

        $payload = [
            'data_json'   => $encodedJson,
            'sync_status' => 'synced',
            'photo_path'  => $data['photo_path'] ?? null,
        ];

        // Gérer l'upload de photo si présente
        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('questionnaires', 'public');
            $payload['photo_path'] = $path; // ex: questionnaires/abc.jpg
        }

        // Aplanir les données vers les colonnes relationnelles
        if (is_array($jsonArray)) {
            $mappedColumns = $this->mapDataJsonToColumns($jsonArray);
            $payload = array_merge($payload, $mappedColumns);
        }

        $storeLocaliteId = ($data['localite_id'] === 0 || $data['localite_id'] === "0") ? null : ($data['localite_id'] ?? null);

        // Upsert : un seul questionnaire par (type, localite_id, user_id)
        try {
            $questionnaire = Questionnaire::updateOrCreate(
                [
                    'type'        => $data['type'],
                    'localite_id' => $storeLocaliteId,
                    'user_id'     => $data['user_id'],
                ],
                $payload
            );

            // Gestion spécifique pour le Contrôle des Travaux (ancien type groupé)
            if ($data['type'] === 'programmation_travaux') {
                $this->saveToControleTravaux($data['user_id'], $data['localite_id'], $jsonArray, $encodedJson);
            }

            // Gestion des nouveaux types par niveau (un type = un niveau)
            if (in_array($data['type'], ['controle_travaux_n1', 'controle_travaux_n2', 'controle_travaux_n3', 'controle_travaux_n4'])) {
                $this->saveControleTravauxFromNiveau($data['user_id'], $data['localite_id'], $data['type'], $jsonArray, $encodedJson);
            }

            Log::info("Questionnaire [{$data['type']}] saved for User [{$data['user_id']}]");
            return response()->json($questionnaire, 201);
        } catch (\Exception $e) {
            Log::error("Error saving questionnaire: " . $e->getMessage());
            return response()->json(['error' => 'Internal server error during save'], 500);
        }
    }

    /**
     * Enregistre les données spécifiquement dans la table controle_travaux.
     */
    private function saveToControleTravaux($userId, $localiteId, $jsonArray, $encodedJson)
    {
        // On traite localite_id: 0 comme NULL pour éviter les problèmes d'intégrité
        $finalLocaliteId = ($localiteId === 0 || $localiteId === "0") ? null : $localiteId;

        $ctPayload = [
            'data_json' => $encodedJson,
            'donnees'   => $encodedJson, // Pour compatibilité avec la structure existante
            'sync_status' => 'synced',
            'status'    => 'completed',
        ];

        // Tentative de déterminer le niveau principal
        if (isset($jsonArray['niveau'])) {
            $ctPayload['niveau'] = $jsonArray['niveau'];
        } elseif (isset($jsonArray['niveau1'])) {
            $ctPayload['niveau'] = 'Niveau 1';
        } elseif (isset($jsonArray['niveau2'])) {
            $ctPayload['niveau'] = 'Niveau 2';
        } elseif (isset($jsonArray['niveau3'])) {
            $ctPayload['niveau'] = 'Niveau 3';
        } elseif (isset($jsonArray['niveau4'])) {
            $ctPayload['niveau'] = 'Niveau 4';
        }

        // Mappage des niveaux (Correction des clés Flutter pour correspondre à l'app mobile)
        $mapping = [
            'niveau1' => [
                'intituleProjet' => 'intitule_projet',
                'projectName'    => 'intitule_projet', // fallback
                'nomEntreprise'  => 'nom_entreprise',
                'companyName'    => 'nom_entreprise', // fallback
                'numeroMarche'   => 'numero_marche',
                'dateDemarrageMarche' => 'date_demarrage',
                'delaiMarche'    => 'delai_marche',
                'etablissement'  => 'etablissement',
            ],
            'niveau2' => [
                'personnel.nom' => 'chef_chantier',
                'personnel.masqueNb' => 'masques',
                'personnel.casque' => 'casques',
                'personnel.gants' => 'gants',
                'personnel.chaussures' => 'chaussures',
                'personnel.gilet' => 'gilets',
                'personnel.premiersSecours' => 'premier_secours',
                'personnel.dateArrivee' => 'date_demarrage_chantier', // optionnel
            ],
            'niveau3' => [
                'sectionStatus' => 'section_status',
                'section15.appreciation' => 'appreciation_avancement',
                'section15.recommandation' => 'recommandations_principales',
            ],
            'niveau4' => [
                'reception_technique.date' => 'date_reception_technique',
                'reception_provisoire.date' => 'date_reception_provisoire',
                'reception_technique.avis' => 'avis_reception',
            ]
        ];

        foreach ($mapping as $niveau => $fields) {
            if (isset($jsonArray[$niveau]) && is_array($jsonArray[$niveau])) {
                $niveauData = $jsonArray[$niveau];
                foreach ($fields as $flutterKey => $dbCol) {
                    $val = null;
                    
                    // Support pour les clés imbriquées (ex: personnel.nom)
                    if (str_contains($flutterKey, '.')) {
                        $keys = explode('.', $flutterKey);
                        $temp = $niveauData;
                        foreach ($keys as $k) {
                            if (isset($temp[$k])) {
                                $temp = $temp[$k];
                            } else {
                                $temp = null;
                                break;
                            }
                        }
                        $val = $temp;
                    } else {
                        $val = $niveauData[$flutterKey] ?? null;
                    }

                    if ($val !== null) {
                        // Conversion dates (format fr vers iso)
                        if (str_starts_with($dbCol, 'date_')) {
                             if (is_string($val) && preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $val)) {
                                $parts = explode('/', $val);
                                $val = "{$parts[2]}-{$parts[1]}-{$parts[0]}";
                            }
                        }
                        
                        // Conversion JSON pour les colonnes MySQL de type JSON
                        if (is_array($val)) {
                            $val = json_encode($val);
                        }

                        $ctPayload[$dbCol] = $val;
                    }
                }
            }
        }
        
        // Enrichissement final avec le mappage général (pour ne rien rater des colonnes existantes dans P1)
        $generalMapped = $this->mapDataJsonToColumns($jsonArray);
        $ctPayload = array_merge($generalMapped, $ctPayload);

        ControleTravaux::updateOrCreate(
            ['user_id' => $userId, 'localite_id' => $finalLocaliteId],
            $ctPayload
        );
        Log::info("Data duplicated to controle_travaux table for Localite [$finalLocaliteId]");
    }

    /**
     * Rapport de Suivi : Retourne les données consolidées pour un site ou TOUS les sites.
     * GET /api/reports/suivi/{localiteId?}
     */
    public function getReportSuivi(int $localiteId = 0): JsonResponse
    {
        $userId = Auth::id();

        if ($localiteId > 0) {
            // Un seul site
            $ct = ControleTravaux::where('user_id', $userId)
                ->where('localite_id', $localiteId)
                ->first();

            $questionnaires = Questionnaire::where('user_id', $userId)
                ->where('localite_id', $localiteId)
                ->get()
                ->keyBy('type');

            return response()->json([
                'controle_travaux' => $ct,
                'questionnaires'   => $questionnaires,
                'localite_id'      => $localiteId,
            ]);
        } else {
            // Tous les sites de l'utilisateur
            $cts = ControleTravaux::where('user_id', $userId)->get();
            $questionnaires = Questionnaire::where('user_id', $userId)
                ->whereIn('type', ['identification', 'programmation_travaux', 'reception'])
                ->get();

            return response()->json([
                'controle_travaux' => $cts,
                'questionnaires'   => $questionnaires,
            ]);
        }
    }

    /**
     * Rapport de Synthèse : Retourne les agrégats par type de site.
     * GET /api/reports/synthese
     */
    public function getReportSynthese(): JsonResponse
    {
        $userId = Auth::id();

        // Jointure ou agrégation sur les questionnaires de type 'identification' et 'programmation_travaux'
        // Pour faire simple, on récupère tout et on laisse le client ou une boucle PHP agréger.
        // Mais comme l'utilisateur veut du "vrai MySQL", on peut faire une requête d'agrégation.
        
        $identificationData = Questionnaire::where('user_id', $userId)
            ->where('type', 'identification')
            ->get();

        $progData = Questionnaire::where('user_id', $userId)
            ->where('type', 'programmation_travaux')
            ->get();

        return response()->json([
            'identification' => $identificationData,
            'programmation'  => $progData,
        ]);
    }

    /**
     * Afficher un questionnaire.
     * GET /api/questionnaires/{id}
     */
    public function show(int $id): JsonResponse
    {
        $questionnaire = Questionnaire::where('id', $id)
            ->where('user_id', Auth::id())
            ->firstOrFail();

        return response()->json($questionnaire);
    }

    /**
     * Mettre à jour un questionnaire (sauvegarde auto).
     * PUT /api/questionnaires/{id}
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $questionnaire = Questionnaire::where('id', $id)
            ->where('user_id', Auth::id())
            ->firstOrFail();

        $validator = Validator::make($request->all(), [
            'data_json'   => 'sometimes|required',
            'localite_id' => 'nullable|integer',
            'sync_status' => 'nullable|string',
            'photo'       => 'nullable|image|max:10485',
            'photo_path'  => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        
        $payload = $data;
        $payload['sync_status'] = 'synced';

        // Gérer l'upload de photo si présente
        if ($request->hasFile('photo')) {
            // Optionnel: supprimer l'ancienne photo
            // if ($questionnaire->photo_path) Storage::disk('public')->delete($questionnaire->photo_path);
            
            $path = $request->file('photo')->store('questionnaires', 'public');
            $payload['photo_path'] = $path;
        }

        if (isset($data['data_json'])) {
            $jsonArray = is_string($data['data_json']) ? json_decode($data['data_json'], true) : $data['data_json'];
            
            if (is_array($data['data_json'])) {
                $payload['data_json'] = json_encode($data['data_json']);
            }

            if (is_array($jsonArray)) {
                $mappedColumns = $this->mapDataJsonToColumns($jsonArray);
                $payload = array_merge($payload, $mappedColumns);
            }
        }

        $questionnaire->update($payload);

        return response()->json($questionnaire);
    }

    /**
     * Supprimer un questionnaire.
     * DELETE /api/questionnaires/{id}
     */
    public function destroy(int $id): JsonResponse
    {
        $questionnaire = Questionnaire::where('id', $id)
            ->where('user_id', Auth::id())
            ->firstOrFail();

        $questionnaire->delete();

        return response()->json(['message' => 'Questionnaire supprimé']);
    }

    /**
     * Dashboard : compteurs par type et statut pour l'utilisateur connecté.
     * GET /api/dashboard-stats
     */
    public function dashboardStats(): JsonResponse
    {
        $userId = Auth::id();

        // Compteurs par type
        $byType = Questionnaire::forUser($userId)
            ->selectRaw('type, COUNT(*) as count')
            ->groupBy('type')
            ->pluck('count', 'type');

        // Total
        $total = Questionnaire::forUser($userId)->count();

        // Compteurs par sync_status
        $bySyncStatus = Questionnaire::forUser($userId)
            ->selectRaw('sync_status, COUNT(*) as count')
            ->groupBy('sync_status')
            ->pluck('count', 'sync_status');

        return response()->json([
            'total'          => $total,
            'by_type'        => $byType,
            'by_sync_status' => $bySyncStatus,
        ]);
    }

    /**
     * Synchronisation en batch : recevoir plusieurs questionnaires du mobile.
     * POST /api/questionnaires/sync-batch
     */
    public function syncBatch(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'questionnaires'              => 'required|array',
            'questionnaires.*.type'       => 'required|string|max:100',
            'questionnaires.*.data_json'  => 'required',
            'questionnaires.*.localite_id'=> 'nullable|integer',
            'questionnaires.*.photo_path' => 'nullable|string',
            'questionnaires.*.created_at' => 'nullable|date',
            'questionnaires.*.updated_at' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $results = [];
        $userId = Auth::id();

        foreach ($request->input('questionnaires') as $item) {
            $dataJsonRaw = $item['data_json'];
            $jsonArray = is_string($dataJsonRaw) ? json_decode($dataJsonRaw, true) : $dataJsonRaw;
            
            $encodedJson = is_array($dataJsonRaw) ? json_encode($dataJsonRaw) : $dataJsonRaw;

            $payload = [
                'data_json'   => $encodedJson,
                'sync_status' => 'synced',
                'photo_path'  => $item['photo_path'] ?? null,
            ];

            if (is_array($jsonArray)) {
                $mappedColumns = $this->mapDataJsonToColumns($jsonArray);
                $payload = array_merge($payload, $mappedColumns);
            }

            $syncLocaliteId = ($item['localite_id'] === 0 || $item['localite_id'] === "0") ? null : ($item['localite_id'] ?? null);

            $questionnaire = Questionnaire::updateOrCreate(
                [
                    'type'        => $item['type'],
                    'localite_id' => $syncLocaliteId,
                    'user_id'     => $userId,
                ],
                $payload
            );

            // Gestion spécifique pour le Contrôle des Travaux en batch (ancien type)
            if ($item['type'] === 'programmation_travaux') {
                try {
                    $this->saveToControleTravaux($userId, $item['localite_id'] ?? null, $jsonArray, $encodedJson);
                } catch (\Exception $e) {
                    Log::error("Error duplicating to controle_travaux in batch: " . $e->getMessage());
                }
            }

            // Gestion des nouveaux types par niveau en batch
            if (in_array($item['type'], ['controle_travaux_n1', 'controle_travaux_n2', 'controle_travaux_n3', 'controle_travaux_n4'])) {
                try {
                    $this->saveControleTravauxFromNiveau($userId, $item['localite_id'] ?? null, $item['type'], $jsonArray, $encodedJson);
                } catch (\Exception $e) {
                    Log::error("Error saving controle_travaux from niveau in batch: " . $e->getMessage());
                }
            }

            $results[] = $questionnaire;
        }

        Log::info("Batch sync completed for User [$userId]. Count: " . count($results));

        return response()->json([
            'message' => count($results) . ' questionnaire(s) synchronisé(s)',
            'data'    => $results,
        ]);
    }

    /**
     * Helper pour mapper les clés Flutter vars les colonnes MySQL.
     */
    private function mapDataJsonToColumns(array $dataJson): array
    {
        
        // Map original Flutter JSON keys to snake_case DB columns
        $keyMapping = [
            'accesEau' => 'acces_eau',
            'accesLatrines' => 'acces_latrines',
            'ancienne_latrine_degradee' => 'ancienne_latrine_degradee',
            'autre' => 'autre',
            'autresTravaux' => 'autres_travaux',
            'avancement' => 'avancement',
            'besoinConstruction' => 'besoin_construction',
            'bureauControle' => 'bureau_controle',
            'casques' => 'casques',
            'certifie' => 'certifie',
            'chaussures' => 'chaussures',
            'chefChantier' => 'chef_chantier',
            'codeAnsade' => 'code_ansade',
            'communeId' => 'commune_id',
            'conformites' => 'conformites',
            'constructionMur' => 'construction_mur',
            'dal' => 'dal',
            'dateActivite' => 'date_activite',
            'dateCertification' => 'date_certification',
            'dateDebutPrevue' => 'date_debut_prevue',
            'dateDebutReelle' => 'date_debut_reelle',
            'dateDemarrage' => 'date_demarrage',
            'dateFinPrevue' => 'date_fin_prevue',
            'dateFinReelle' => 'date_fin_reelle',
            'dateLeveeReserves' => 'date_levee_reserves',
            'dateReceptionDefinitive' => 'date_reception_definitive',
            'dateReceptionProvisoire' => 'date_reception_provisoire',
            'dateVisite' => 'date_visite',
            'date_activite' => 'date_activite',
            'delaiMarche' => 'delai_marche',
            'destructionAnciennesLatrines' => 'destruction_anciennes_latrines',
            'difficulteEau' => 'difficulte_eau',
            'distanceSource' => 'distance_source',
            'dlmEauSavon' => 'dlm_eau_savon',
            'dlmExiste' => 'dlm_existe',
            'dlmFonctionnel' => 'dlm_fonctionnel',
            'dlm_existe' => 'dlm_existe',
            'dossierComplet' => 'dossier_complet',
            'effectif' => 'effectif',
            'effectifEncadrement' => 'effectif_encadrement',
            'effectifOuvrier' => 'effectif_ouvrier',
            'etatSiteActuel' => 'etat_site_actuel',
            'gants' => 'gants',
            'gilets' => 'gilets',
            'intituleProjet' => 'intitule_projet',
            'jalons' => 'jalons',
            'latitude' => 'latitude',
            'latrineAmelioree' => 'latrine_amelioree',
            'latrineDefecation' => 'latrine_defecation',
            'latrineDefecationNon' => 'latrine_defecation_non',
            'latrineDegradee' => 'latrine_degradee',
            'latrineUsageToujours' => 'latrine_usage_toujours',
            'latrineVoisin' => 'latrine_voisin',
            'latrineVoisinNon' => 'latrine_voisin_non',
            'latrine_amelioree' => 'latrine_amelioree',
            'latrine_existe' => 'latrine_existe',
            'latrinesExiste' => 'latrines_existe',
            'leveeReserves' => 'levee_reserves',
            'longitude' => 'longitude',
            'marcheTravaux' => 'marche_travaux',
            'masques' => 'masques',
            'materiaux' => 'materiaux',
            'membres' => 'membres',
            'mesuresCorrectives' => 'mesures_correctives',
            'montantInvestiMenages' => 'montant_investi_menages',
            'moughataaId' => 'moughataa_id',
            'nbBlocs' => 'nb_blocs',
            'nbBlocsConstruire' => 'nb_blocs_construire',
            'nbCabines' => 'nb_cabines',
            'nbCabinesConstruire' => 'nb_cabines_construire',
            'nbCabinesFonctionnelles' => 'nb_cabines_fonctionnelles',
            'nbDLM_EauSansSavon' => 'nb_dlm_eau_sans_savon',
            'nbDLM_EauSavon' => 'nb_dlm_eau_savon',
            'nbDlm' => 'nb_dlm',
            'nbDlmEauSansSavon' => 'nb_dlm_eau_sans_savon',
            'nbDlmEauSavon' => 'nb_dlm_eau_savon',
            'nbEnfants' => 'nb_enfants',
            'nbFemmes' => 'nb_femmes',
            'nbHommes' => 'nb_hommes',
            'nbLatrines' => 'nb_latrines',
            'nbLatrinesAAmeliorer' => 'nb_latrines_a_ameliorer',
            'nbLatrinesAideExterieure' => 'nb_latrines_aide_exterieure',
            'nbLatrinesAmeliorees' => 'nb_latrines_ameliorees',
            'nbLatrinesAmelioreesHygienique' => 'nb_latrines_ameliorees_hygienique',
            'nbLatrinesAmelioreesPartagees' => 'nb_latrines_ameliorees_partagees',
            'nbLatrinesAutofinancees' => 'nb_latrines_autofinancees',
            'nbLatrinesAvecDLM' => 'nb_latrines_avec_dlm',
            'nbLatrinesDLM' => 'nb_latrines_dlm',
            'nbLatrinesEndommagees' => 'nb_latrines_endommagees',
            'nbLatrinesFinanceesCommunaute' => 'nb_latrines_financees_communaute',
            'nbLatrinesNonAmeliorees' => 'nb_latrines_non_ameliorees',
            'nbLatrinesNonFonctionnelles' => 'nb_latrines_non_fonctionnelles',
            'nbMenages' => 'nb_menages',
            'nbMenagesDAL' => 'nb_menages_dal',
            'nbMenagesDefecationAirLibre' => 'nb_menages_defecation_air_libre',
            'nbMenagesEnquetes' => 'nb_menages_enquetes',
            'nbMenagesLatrinesVoisins' => 'nb_menages_latrines_voisins',
            'nbMenagesSansDLM' => 'nb_menages_sans_dlm',
            'nbMenagesSansEau' => 'nb_menages_sans_eau',
            'nbMenagesUtilisantVoisin' => 'nb_menages_utilisant_voisin',
            'nbNouvellesLatrinesConstruites' => 'nb_nouvelles_latrines_construites',
            'nbPopulation' => 'nb_population',
            'nbPotentiels' => 'nb_potentiels',
            'nbTotal' => 'nb_total',
            'nbTotalLatrines' => 'nb_total_latrines',
            'nbTravaux' => 'nb_travaux',
            'nb_menages_partage_latrine' => 'nb_menages_partage_latrine',
            'nomControleur' => 'nom_controleur',
            'nomEntreprise' => 'nom_entreprise',
            'nomInfrastructure' => 'nom_infrastructure',
            'nonConformites' => 'non_conformites',
            'noteGlobale' => 'note_globale',
            'numeroMarche' => 'numero_marche',
            'observations' => 'observations',
            'origineMainOeuvre' => 'origine_main_oeuvre',
            'pointEauLavage' => 'point_eau_lavage',
            'premierSecours' => 'premier_secours',
            'presenceDLM' => 'presence_dlm',
            'pvReception' => 'pv_reception',
            'raisonsNon' => 'raisons_non',
            'recommandations' => 'recommandations',
            'remarqueNon' => 'remarque_non',
            'remarques' => 'remarques',
            'remarquesFinales' => 'remarques_finales',
            'reserves' => 'reserves',
            'signatureControleur' => 'signature_controleur',
            'signatureEntreprise' => 'signature_entreprise',
            'signatureMaitreOuvrage' => 'signature_maitre_ouvrage',
            'sourceEau' => 'source_eau',
            'superficie' => 'superficie',
            'trancheesDrainage' => 'tranchees_drainage',
            'travauxRealises' => 'travaux_realises',
            'typeDLM' => 'type_dlm',
            'typeEtablissement' => 'type_etablissement',
            'typeInfrastructure' => 'type_infrastructure',
            'typeLatrine' => 'type_latrine',
            'typeLatrines' => 'type_latrines',
            'type_dlm' => 'type_dlm',
            'utilisation_latrine_voisin' => 'utilisation_latrine_voisin',
            'wilayaId' => 'wilaya_id',
        ];

        $mapped = [];
        foreach ($dataJson as $key => $value) {
            if (isset($keyMapping[$key])) {
                $targetCol = $keyMapping[$key];

                // Conversion des dates: DD/MM/YYYY -> YYYY-MM-DD
                if (str_starts_with($targetCol, 'date_')) {
                    if (empty($value)) {
                        $value = null;
                    } elseif (is_string($value) && preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $value)) {
                        $parts = explode('/', $value);
                        $value = "{$parts[2]}-{$parts[1]}-{$parts[0]}";
                    }
                }

                // Conversion des tableaux en JSON (pour les colonnes de type text/json)
                if (is_array($value)) {
                    $value = json_encode($value);
                }

                $mapped[$targetCol] = $value;
            }
        }
        return $mapped;
    }

    /**
     * Enregistre les données d'un niveau spécifique dans la table controle_travaux.
     * Appelé quand le type est 'controle_travaux_n1', 'n2', 'n3' ou 'n4'.
     * Les données arrivent à plat (sans imbrication de niveau).
     */
    private function saveControleTravauxFromNiveau($userId, $localiteId, string $type, ?array $jsonArray, string $encodedJson): void
    {
        $finalLocaliteId = ($localiteId === 0 || $localiteId === '0') ? null : $localiteId;

        // Payload de base commun à tous les niveaux
        // Note: seules les colonnes existantes dans controle_travaux sont utilisées
        $ctPayload = [
            'data_json'   => $encodedJson,
            'sync_status' => 'synced',
        ];

        if ($jsonArray === null) {
            ControleTravaux::updateOrCreate(
                ['user_id' => $userId, 'localite_id' => $finalLocaliteId],
                $ctPayload
            );
            return;
        }

        // Mappage spécifique selon le niveau
        switch ($type) {
            case 'controle_travaux_n1':
                // Données générales (Niveau 1)
                $ctPayload['etablissement']   = $jsonArray['etablissement'] ?? null;
                $ctPayload['intitule_projet']  = $jsonArray['intituleProjet'] ?? $jsonArray['projectName'] ?? null;
                $ctPayload['nom_entreprise']   = $jsonArray['nomEntreprise'] ?? $jsonArray['companyName'] ?? null;
                $ctPayload['numero_marche']    = $jsonArray['numeroMarche'] ?? null;
                $ctPayload['delai_marche']     = $jsonArray['delaiMarche'] ?? null;
                $ctPayload['bureau_controle']  = $jsonArray['bureauControle'] ?? null;

                // Conversion de la date de démarrage
                $dateRaw = $jsonArray['dateDemarrageMarche'] ?? null;
                if ($dateRaw && preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $dateRaw)) {
                    $parts = explode('/', $dateRaw);
                    $dateRaw = "{$parts[2]}-{$parts[1]}-{$parts[0]}";
                }
                if ($dateRaw && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateRaw)) {
                    $dateRaw = null; // Ignorer les formats invalides
                }
                $ctPayload['date_demarrage'] = $dateRaw;
                break;

            case 'controle_travaux_n2':
                // Organisation chantier (Niveau 2)
                $personnel = $jsonArray['personnel'] ?? [];
                $ctPayload['chef_chantier']   = $personnel['nom'] ?? null;
                $ctPayload['casques']         = $personnel['casque'] ?? null;
                $ctPayload['gilets']          = $personnel['gilet'] ?? null;
                $ctPayload['masques']         = isset($personnel['masqueNb']) ? (string)$personnel['masqueNb'] : null;
                $ctPayload['chaussures']      = $personnel['chaussures'] ?? null;
                $ctPayload['gants']           = $personnel['gants'] ?? null;
                $ctPayload['premier_secours'] = $personnel['premiersSecours'] ?? null;

                // Date d'arrivée comme date de démarrage chantier
                $dateArr = $personnel['dateArrivee'] ?? null;
                if ($dateArr && preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $dateArr)) {
                    $parts = explode('/', $dateArr);
                    $dateArr = "{$parts[2]}-{$parts[1]}-{$parts[0]}";
                }
                if ($dateArr && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateArr)) {
                    $dateArr = null;
                }
                $ctPayload['date_demarrage_chantier'] = $dateArr;
                break;

            case 'controle_travaux_n3':
                // Contrôle technique (Niveau 3)
                $sectionStatus = $jsonArray['sectionStatus'] ?? null;
                if (is_array($sectionStatus)) {
                    $ctPayload['section_status'] = json_encode($sectionStatus);
                }
                $section15 = $jsonArray['section15'] ?? [];
                $ctPayload['appreciation_avancement']     = $section15['appreciation'] ?? null;
                $ctPayload['recommandations_principales'] = $section15['recommandation'] ?? null;
                break;

            case 'controle_travaux_n4':
                // Réception (Niveau 4)
                $rt = $jsonArray['reception_technique'] ?? [];
                $rp = $jsonArray['reception_provisoire'] ?? [];

                $dateTech = $rt['date'] ?? null;
                if ($dateTech && preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $dateTech)) {
                    $parts = explode('/', $dateTech);
                    $dateTech = "{$parts[2]}-{$parts[1]}-{$parts[0]}";
                }
                if ($dateTech && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateTech)) {
                    $dateTech = null;
                }
                $ctPayload['date_reception_technique']  = $dateTech;

                $dateProv = $rp['date'] ?? null;
                if ($dateProv && preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $dateProv)) {
                    $parts = explode('/', $dateProv);
                    $dateProv = "{$parts[2]}-{$parts[1]}-{$parts[0]}";
                }
                if ($dateProv && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateProv)) {
                    $dateProv = null;
                }
                $ctPayload['date_reception_provisoire'] = $dateProv;
                break;
        }

        ControleTravaux::updateOrCreate(
            ['user_id' => $userId, 'localite_id' => $finalLocaliteId],
            $ctPayload
        );

        Log::info("controle_travaux updated from type [{$type}] for Localite [{$finalLocaliteId}]");
    }

}
