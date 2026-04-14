import re
import os

keys = """accesEau
accesLatrines
ancienne_latrine_degradee
autre
autresTravaux
avancement
besoinConstruction
bureauControle
casques
certifie
chaussures
chefChantier
codeAnsade
communeId
conformites
constructionMur
dal
dateActivite
dateCertification
dateDebutPrevue
dateDebutReelle
dateDemarrage
dateFinPrevue
dateFinReelle
dateLeveeReserves
dateReceptionDefinitive
dateReceptionProvisoire
dateVisite
date_activite
delaiMarche
destructionAnciennesLatrines
difficulteEau
distanceSource
dlmEauSavon
dlmExiste
dlmFonctionnel
dlm_existe
dossierComplet
effectif
effectifEncadrement
effectifOuvrier
etatSiteActuel
gants
gilets
intituleProjet
jalons
latitude
latrineAmelioree
latrineDefecation
latrineDefecationNon
latrineDegradee
latrineUsageToujours
latrineVoisin
latrineVoisinNon
latrine_amelioree
latrine_existe
latrinesExiste
leveeReserves
localiteId
longitude
marcheTravaux
masques
materiaux
membres
mesuresCorrectives
montantInvestiMenages
moughataaId
nbBlocs
nbBlocsConstruire
nbCabines
nbCabinesConstruire
nbCabinesFonctionnelles
nbDLM_EauSansSavon
nbDLM_EauSavon
nbDlm
nbDlmEauSansSavon
nbDlmEauSavon
nbEnfants
nbFemmes
nbHommes
nbLatrines
nbLatrinesAAmeliorer
nbLatrinesAideExterieure
nbLatrinesAmeliorees
nbLatrinesAmelioreesHygienique
nbLatrinesAmelioreesPartagees
nbLatrinesAutofinancees
nbLatrinesAvecDLM
nbLatrinesDLM
nbLatrinesEndommagees
nbLatrinesFinanceesCommunaute
nbLatrinesNonAmeliorees
nbLatrinesNonFonctionnelles
nbMenages
nbMenagesDAL
nbMenagesDefecationAirLibre
nbMenagesEnquetes
nbMenagesLatrinesVoisins
nbMenagesSansDLM
nbMenagesSansEau
nbMenagesUtilisantVoisin
nbNouvellesLatrinesConstruites
nbPopulation
nbPotentiels
nbTotal
nbTotalLatrines
nbTravaux
nb_menages_partage_latrine
nomControleur
nomEntreprise
nomInfrastructure
nonConformites
noteGlobale
numeroMarche
observations
origineMainOeuvre
photo
photoPath
pointEauLavage
premierSecours
presenceDLM
pvReception
raisonsNon
recommandations
remarqueNon
remarques
remarquesFinales
reserves
signatureControleur
signatureEntreprise
signatureMaitreOuvrage
sourceEau
superficie
trancheesDrainage
travauxRealises
typeDLM
typeEtablissement
typeInfrastructure
typeLatrine
typeLatrines
type_dlm
utilisation_latrine_voisin
wilayaId"""

def to_snake_case(name):
    # Handle acronym DLM especially
    name = name.replace('DLM', 'Dlm').replace('DAL', 'Dal')
    # Some words already have underscores
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    name = re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()
    return name.replace('__', '_')

unique_snake_keys = set()
map_original_to_snake = {}

for k in keys.splitlines():
    k = k.strip()
    if not k: continue
    snake = to_snake_case(k)
    unique_snake_keys.add(snake)
    map_original_to_snake[k] = snake

sorted_snakes = sorted(list(unique_snake_keys))

# Identify types based on name heuristics
def get_column_type(name):
    if name.startswith('nb_'): return 'integer'
    if name.startswith('montant_'): return 'double'
    if name.startswith('date_'): return 'date'
    if name in ('latitude', 'longitude', 'distance_source', 'superficie', 'avancement', 'effectif', 'effectif_encadrement', 'effectif_ouvrier'): return 'double'
    if 'id' in name and (name.endswith('_id') or name == 'id'): return 'integer'
    # We will use string (varchar) for others just to be safe, except boolean ones but boolean can be tricky so stick with string
    return 'text'

# Build up columns string
columns_up = []
columns_down = []
for snake in sorted_snakes:
    # Skip standard columns that we already have in the model or are metadata
    if snake in ('localite_id', 'photo_path', 'photo'):
        continue
        
    col_type = get_column_type(snake)
    if col_type == 'text':
        columns_up.append(f"            $table->text('{snake}')->nullable();")
    else:
        columns_up.append(f"            $table->{col_type}('{snake}')->nullable();")
    columns_down.append(f"            $table->dropColumn('{snake}');")

mig_up = "\n".join(columns_up)
mig_down = "\n".join(columns_down)

migration_file = r"e:\Stage-S6\projet\PIAM-mobile\piam-backend\database\migrations\2026_04_14_114307_add_flattened_columns_to_questionnaires_table.php"

with open(migration_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Schema::table
content = content.replace("            //", mig_up, 1)
content = content.replace("            //", mig_down, 1)

with open(migration_file, 'w', encoding='utf-8') as f:
    f.write(content)

# Now, generate the PHP mapping array for the controller
mapping_lines = []
for orig, snake in map_original_to_snake.items():
    if snake in ('localite_id', 'photo_path', 'photo'): continue
    mapping_lines.append(f"            '{orig}' => '{snake}',")

mapping_str = "\n".join(mapping_lines)
print("Migration written.")
# Writing mapping file
with open('scratch_mapping.txt', 'w') as f:
    f.write(mapping_str)
