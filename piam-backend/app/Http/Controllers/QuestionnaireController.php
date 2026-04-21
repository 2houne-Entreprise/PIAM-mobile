<?php

namespace App\Http\Controllers;

use App\Models\Questionnaire;
use App\Models\ControleTravaux;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

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

            // Gestion spécifique pour le Contrôle des Travaux
            if ($data['type'] === 'programmation_travaux') {
                $this->saveToControleTravaux($data['user_id'], $data['localite_id'], $jsonArray, $encodedJson);
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

        // Mappage des niveaux
        $mapping = [
            'niveau1' => [
                'siteSelectionne' => 'site_selectionne',
                'etablissement' => 'etablissement',
                'natureTravaux' => 'nature_travaux',
                'niveauEcole' => 'niveau_ecole',
                'typeStructure' => 'type_structure',
            ],
            'niveau2' => [
                'nomEntreprise' => 'nom_entreprise',
                'numeroMarche' => 'numero_marche',
                'intituleProjet' => 'intitule_projet',
                'dateDemarrage' => 'date_demarrage',
                'delaiMarche' => 'delai_marche',
                'chefChantier' => 'chef_chantier',
                'bureauControle' => 'bureau_controle',
                'effectifEncadrement' => 'effectif_encadrement',
                'effectifOuvrier' => 'effectif_ouvrier',
                'effectifTotal' => 'effectif_total',
                'casques' => 'casques',
                'gilets' => 'gilets',
                'masques' => 'masques',
                'chaussures' => 'chaussures',
                'gants' => 'gants',
                'premierSecours' => 'premier_secours',
            ],
            'niveau3' => [
                'sectionStatus' => 'section_status',
                'appreciationAvancement' => 'appreciation_avancement',
                'recommandation' => 'recommandations_principales',
            ],
            'niveau4' => [
                'dateReceptionProvisoire' => 'date_reception_provisoire',
                'dateReceptionDefinitive' => 'date_reception_definitive',
                'avisReception' => 'avis_reception',
            ]
        ];

        foreach ($mapping as $niveau => $fields) {
            if (isset($jsonArray[$niveau]) && is_array($jsonArray[$niveau])) {
                foreach ($fields as $flutterKey => $dbCol) {
                    if (isset($jsonArray[$niveau][$flutterKey])) {
                        $val = $jsonArray[$niveau][$flutterKey];
                        
                        // Conversion dates
                        if (str_starts_with($dbCol, 'date_')) {
                             if (is_string($val) && preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $val)) {
                                $parts = explode('/', $val);
                                $val = "{$parts[2]}-{$parts[1]}-{$parts[0]}";
                            }
                        }
                        
                        // Conversion JSON
                        if (is_array($val)) {
                            $val = json_encode($val);
                        }

                        $ctPayload[$dbCol] = $val;
                    }
                }
            }
        }

        ControleTravaux::updateOrCreate(
            ['user_id' => $userId, 'localite_id' => $finalLocaliteId],
            $ctPayload
        );
        Log::info("Data duplicated to controle_travaux table for Localite [$finalLocaliteId]");
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

            // Gestion spécifique pour le Contrôle des Travaux en batch
            if ($item['type'] === 'programmation_travaux') {
                try {
                    $this->saveToControleTravaux($userId, $item['localite_id'] ?? null, $jsonArray, $encodedJson);
                } catch (\Exception $e) {
                    Log::error("Error duplicating to controle_travaux in batch: " . $e->getMessage());
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

}
