# 📘 CAHIER DES CHARGES COMPLET – APPLICATION PIAM

**Version:** 1.0  
**Date:** 2026-03-30  
**Statut:** Officiel  
**Destinataires:** Équipes Dev + IA

---

## 🧭 1. OBJECTIF DE L'APPLICATION

**Application mobile de collecte de données terrain** pour la gestion d'assainissement et le suivi ATPC.

### Cas d'usage :
- Suivi de l'assainissement en temps réel
- Gestion des latrines publiques
- Collecte standardisée des données
- Suivi ATPC (Analyse Technique du Projet de Chaîne)
- Rapports d'avancement


### Plateforme cible :
- Flutter (cross-platform)
- Mobile first
- Fonctionnement offline-first avec synchronisation différée

#### 📦 Stockage des données terrain

- Toutes les données saisies sont enregistrées localement dans une base SQLite (`piam.db`), dans la table unique `questionnaires`.
- Les données de chaque formulaire sont stockées au format JSON dans la colonne `data_json`.
- Unicité garantie par la contrainte `(type, localite_id)` : un seul enregistrement par type de formulaire et par localité.
- Synchronisation automatique dès qu'une connexion internet est disponible (champ `sync_status`).
- Sur le web, stockage équivalent via SharedPreferences (clé `piam_questionnaires`).

**Exigence** : L'application doit fonctionner en mode hors-ligne complet, garantir la persistance des données, et assurer la synchronisation différée sans perte.

---

## 🔐 2. AUTHENTIFICATION

### Fonctionnalités requises :

| Élément | Description | Validation |
|---------|-------------|-----------|
| **Login** | Username + Password | Obligatoire |
| **Date/Heure** | Vérification automatique | Bloquer si incohérent |
| **Sécurité** | Stockage sécurisé tokens | Utiliser Flutter Secure Storage |

### Règles métier :
- ❌ Blocage total si date systématique < date dernière connexion
- ✅ Avertissement si écart > 1 heure
- 🔄 Sync auto après login réussi

---

## ⚙️ 3. PARAMÉTRAGE INITIAL

### 3.1 Données obligatoires de localisation

#### 📍 Hiérarchie géographique (cascade) :

```
Wilaya (Région)
  └─ Moughataa (Département)
      └─ Commune (Commune)
          └─ Localité (Localité)
```

**Règles importantes :**
- Chaque niveau filtre le suivant
- Pas de saut de niveau autorisé
- Stockage local pour offline

#### 📡 GPS :

- **Capture automatique** au première ouverture
- **Bouton "Capturer position"** pour update
- **Formate :** Latitude, Longitude (WGS84)
- **Précision :** ± 5m acceptable

#### 🆕 Nouvelle localité :

- Nom (obligatoire)
- GPS (obligatoire)
- Description (optionnel)
- **Expédition à l'admin** pour validation
- **Statut :** En attente / Approuvée / Rejetée

#### 📊 Autres paramètres :

| Paramètre | Type | Source |
|-----------|------|--------|
| Opérateur | Texte | Utilisateur + Admin |
| Projet | Liste déroulante | Admin |
| Date/Heure | Sys | Automatique |

### 3.2 Écran de configuration

**Ordre d'affichage :**
1. Sélection Wilaya
2. Sélection Moughataa
3. Sélection Commune
4. Sélection/Création Localité
5. Capture GPS
6. Sélection Opérateur
7. Sélection Projet
8. Bouton "Confirmer"

---

## 🏠 4. DASHBOARD

### Éléments affichés :

```
┌─────────────────────────────┐
│ 👤 Nom Utilisateur          │
│ 📍 Localité: Localité X     │
│ 📊 Projet: Projet Y         │
│ 📅 Dernier sync: HH:MM      │
├─────────────────────────────┤
│ 🔵 Déclenchement            │
│ 🟢 Certification FDAL       │
│ 🟡 État des lieux Localité │
│ 🟠 État des lieux Ménage    │
│ 🔵 Dernier suivi Localité   │
│ 🟢 Dernier suivi Ménage     │
│ 🟡 Inventaire               │
│ 🟠 Programmation travaux    │
│ 🔴 Travaux réceptionnés     │
│ 📊 Rapports                 │
├─────────────────────────────┤
│ ⚙️ Paramètres               │
│ 🚪 Déconnexion              │
└─────────────────────────────┘
```

### Logique d'affichage :

- **Cartes cliquables** avec icône couleur
- **Indicateur statut** : Complété / En cours / À faire
- **Nombre de réponses** pour chaque formulaire
- **Bouton refresh** pour sync avec serveur

---

## 📊 5. LES 9 OPÉRATIONS (CŒUR DE L'APP)

### Structure commune à tous les formulaires

```json
{
  "formulaire_id": "unique_id",
  "date": "YYYY-MM-DD HH:MM",
  "localite_id": "uuid",
  "gps": {
    "latitude": 0.0,
    "longitude": 0.0,
    "precisio": 5.5
  },
  "questions": [],
  "reponses": [],
  "photos": [],
  "remarques": "",
  "statut": "brouillon|complète|validée|envoyée",
  "date_creation": "timestamp",
  "date_modification": "timestamp"
}
```

---

### 🔵 OPÉRATION 1: DÉCLENCHEMENT

**Objectif :** Initier une visite / intervention

#### Champs :

| Champ | Type | Obligatoire | Remarques |
|-------|------|-------------|-----------|
| Date | Date | ✅ | Pré-remplie (auj) |
| GPS | Géolocalisation | ✅ | Bouton capturer |
| Localité | Liste | ✅ | Dropdown |
| Remarques | Texte | ❌ | Long texte |

#### Validation avant envoi :
- ✅ Date renseignée
- ✅ GPS capturé
- ✅ Localité sélectionnée

---

### 🟢 OPÉRATION 2: CERTIFICATION FDAL

**Objectif :** Vérifier la certification FDAL (Fonds de Développement d'Assainissement Local)

#### Champs :

| Champ | Type | Condition |
|-------|------|-----------|
| Date | Date | Obligatoire |
| GPS | Géolocalisation | Obligatoire |
| Certification FDAL | Oui/Non | Obligatoire |
| Raison (si Non) | Checkboxes | **Conditionnel** ➜ SI NON |

#### Raisons possibles (si NON) :

- ☐ Pas de fonds disponibles
- ☐ Fonds mobilisés ailleurs
- ☐ Administration en retard
- ☐ Autre (spécifier)

#### Logique métier :
```
SI Certification = OUI
  → Afficher message "FDAL confirmée"
  
SI Certification = NON
  → Afficher checkboxes des raisons
  → Texte libre (Autre)
```

---

### 🟡 OPÉRATION 3: ÉTAT DES LIEUX LOCALITÉ

**Objectif :** Inventaire général de la localité

#### Champs :

| Champ | Type | Exemple |
|-------|------|---------|
| Date | Date | 2026-03-30 |
| GPS | Géolocalisation | Cap GPS |
| Nombre de ménages | Nombre | 1-10000 |
| État général | Liste | Bon / Moyen / Mauvais |
| Accès eau | Oui/Non | - |
| Accès électricité | Oui/Non | - |
| Route accès | État | Bonne / Mauvaise / Inexistante |
| Notes terrain | Texte long | Observations |

#### Photos :
- **Minimum :** 2 (avant/après)
- **Format :** JPG/PNG
- **Métadonnées :** GPS auto-ajouté

---

### 🟠 OPÉRATION 4: ÉTAT DES LIEUX MÉNAGE

**Objectif :** Détails sur les équipements ménagers sanitaires

#### Champs principaux :

| Champ | Type | Obligatoire |
|-------|------|-------------|
| Nombre ménages visités | Nombre | ✅ |
| **Existence latrines** | **Oui/Non** | **✅** |
| Dispositif lavage mains | Checkbox | ✅ |
| Eau savon | Oui/Non | ❌ |
| Qualité latrine | État | ❌ |

#### ⚠️ LOGIQUE DYNAMIQUE CRUCIALE :

```
SI Existence latrines = OUI
  → Afficher FORMULAIRE A (détails techniques)
      - Type latrine
      - Fosse septique (Oui/Non)
      - Enfouissement (Oui/Non)
      - État d'entretien
      - Photos détaillées
      
SI Existence latrines = NON
  → Afficher FORMULAIRE B (problèmes)
      - Raison absence
      - Risques sanitaires identifiés
      - Photos problèmes
      - Recommandations
```

---

### 🔵 OPÉRATION 5: DERNIER SUIVI LOCALITÉ

**Objectif :** Suivi temporel du dernier passage

#### Champs :

| Champ | Type |
|-------|------|
| Date dernier suivi | Date |
| GPS dernier suivi | Géolocalisation |
| Changements depuis dernier suivi | Texte |
| Nombre actions complétées | Nombre |
| État général | Liste |

---

### 🟢 OPÉRATION 6: DERNIER SUIVI MÉNAGE

**Objectif :** Situation des ménages à la visite précédente

#### Champs :

| Champ | Type | Dynamique |
|-------|------|-----------|
| Nombre ménages | Nombre | - |
| **Latrines présentes** | **Oui/Non** | **✅** |
| État d'entretien | Liste | Si OUI → visibilité |
| Accès eau potable | Oui/Non | - |
| Dispositif lavage | Checkbox | - |

#### Logique :
```
Même dynamique que Opération 4
```

---

### 🟡 OPÉRATION 7: INVENTAIRE

**Objectif :** Inventaire des ressources et accès assainissement

#### Champs obligatoires :

| Champ | Type |
|-------|------|
| Date inventaire | Date |
| Nombre points d'eau | Nombre |
| **Accès assainissement** | **Oui/Non** |
| Nombre latrines publiques | Nombre |
| État général infrastructure | État |

#### ⚠️ LOGIQUE DYNAMIQUE :

```
SI Accès assainissement = OUI
  → FORMULAIRE A
      - Type assainissement
      - Nombre points collecte
      - État infrastructure
      - Coûts maintenance
      
SI Accès assainissement = NON
  → FORMULAIRE B
      - Raisons absence
      - Risques identifiés
      - Coûts estimation pour création
      - Priorité action
```

---

### 🟠 OPÉRATION 8: PROGRAMMATION DES TRAVAUX

**Status :** ⚠️ Déjà implémentée → DOIT ÊTRE ISOLÉE EN MODULE SÉPARÉ

#### Points clés :
- 📦 Module réutilisable
- 🔗 Lié à Opération 5 (suivi)
- 📅 Planification future
- 💰 Budget
- 👥 Ressources

#### Champs :

| Champ | Type |
|-------|------|
| Date travaux programmés | Date |
| Description travaux | Texte |
| Budget estimé | Nombre |
| Équipe assignée | Liste |
| Matériaux requis | Liste |
| Dates étapes | Dates multiples |

---

### 🔴 OPÉRATION 9: TRAVAUX RÉCEPTIONNÉS

**Objectif :** Validation des travaux complétés

#### Champs :

| Champ | Type | Obligatoire |
|-------|------|-------------|
| Date réception | Date | ✅ |
| Nombre travaux complétés | Nombre | ✅ |
| Photos avant/après | Photos x2+ | ✅ |
| Qualité générale | État (1-5) | ✅ |
| Rapport inspection | Texte | ✅ |
| Validation responsable | Signature | ✅ |
| Budget final | Nombre | ✅ |

#### Critères acceptation :
- ✅ Photos claires (x2 minimum)
- ✅ Rapport complété
- ✅ Signature responsable
- ✅ Budget ≤ estimé (+10% tolérance)

---

## 🧩 6. TYPES DE CHAMPS DISPONIBLES

Tous les formulaires utilisent exclusivement :

```
├─ Texte court (max 100 car)
├─ Texte long (max 5000 car)
├─ Nombre (entier / décimal)
├─ Oui / Non (boolean)
├─ Date (format YYYY-MM-DD)
├─ Date/Heure (format YYYY-MM-DD HH:MM)
├─ GPS (latitude, longitude, précision)
├─ Photo(s) (JPG/PNG compressé)
├─ Liste déroulante (dropdown unique)
├─ Lists multiples (checkboxes)
├─ État/Évaluation (bon/moyen/mauvais ou 1-5)
└─ Signature (dessin ou image)
```

---

## 🔁 7. LOGIQUE MÉTIER IMPORTANTE

### 7.1 Formulaires dynamiques

**Concept :** Champs visibles/masqués selon conditions

#### Exemple :
```
SI {champ_oui_non} == "OUI"
  → Afficher [autre_champ_A, autre_champ_B, autre_champ_C]
SINON
  → Afficher [autre_champ_D, autre_champ_E]
```

### 7.2 Validation

**Avant envoi :**
1. ✅ Tous champs obligatoires remplis
2. ✅ GPS capturé (coordonnées valides)
3. ✅ Date cohérente (≥ dernière date)
4. ✅ Pas de doublon (même localité + même date)
5. ✅ Photos de bonne qualité (min 100KB)

**Après envoi :**
- 📤 Confirmation utilisateur
- 🔄 Sync serveur
- ✅ Notification succès/erreur

### 7.3 Gestion des erreurs

| Erreur | Action |
|--------|--------|
| Champ requête manquant | ❌ Bloquer envoi + Message |
| GPS invalide | ❌ Bloquer + "Capturer GPS" |
| Date future | ⚠️ Avertissement + Confirmation |
| Pas de connexion | 💾 Sauvegarder brouillon |
| Doublon détecté | ❌ Proposer édition existant |

---

## 📤 8. SYSTÈME D'ENVOI & SYNCHRONISATION

### Statuts d'un formulaire :

```
Brouillon
  ↓ (utilisateur clique "Compléter")
Complété
  ↓ (utilisateur clique "Avant d'envoyer")
Validé (prêt envoi)
  ↓ (connexion internet + sync)
Envoyé
  ↓ (serveur confirme)
Archivé
```

### Politiques Offline :

- ✅ Remplissage complet **SANS connexion**
- ✅ Sauvegarde auto chaque 30 sec
- 🔄 Sync auto quand connexion revient
- ⚠️ Conflit = utilisateur choisit (garder local / prendre serveur)

---

## 🎨 9. DESIGN & UX

### 9.1 Codes couleur

```
🟢 VERT      = Complété / Valide / Succès
🟡 JAUNE     = En cours / À vérifier
🔴 ROUGE     = Erreur / Blocage / Attention
⚫ GRIS      = Inactif / Facultatif
🔵 BLEU      = Info / Lien / Bouton primaire
```

### 9.2 Principes UX

- **Mobile first** : Responsive 100%
- **Offline first** : Fonctionne sans internet
- **Grande lisibilité** : Fonts ≥ 14pt
- **Boutons gros** : Min 48x48 dp
- **Pas de scroll** : Max 1 écran par formulaire
- **Indicateur prog** : % complétion visible
- **Icônes standards** : 📷 📍 📅 ✅ ❌

### 9.3 Navigation

```
Dashboard (hub central)
├─ Formulaire 1
│  ├─ Sous-formulaire A (si condition)
│  │  └─ Photos
│  └─ Sous-formulaire B
├─ Formulaire 2
├─ Formulaire 3
...
├─ Rapports
└─ Paramètres
```

### 9.4 Barres d'appui

- **Top bar :** Logo + Localité + Temps
- **Bottom bar :** Navigation formulaires
- **FAB (Floating Action Button) :** "Capturer GPS" contextuel

---

## 🧠 10. ERREURS CRITIQUES À ÉVITER

### ❌ ERREURS DROPDOWNS

```dart
// ❌ MAL : Doublons possibles
[
  "Option 1",
  "Option 1",  // DOUBLON!
  "Option 2"
]

// ✅ BON : Valeurs uniques
[
  "option_1",
  "option_2",
  "option_3"
]

// ❌ MAL : Value inexistant
DropdownMenuItem(
  value: "inexistant",  // NOT in items list!
  child: Text("Option")
)

// ✅ BON : Value dans items
items: [
  DropdownMenuItem(value: "val1", child: Text("Opt1"))
]
```

### ❌ ERREURS DONNÉES

```
❌ GPS vide
❌ GPS invalide (lat/lon > 90/-90)
❌ Date > auj.hui
❌ Date < dernière visite
❌ Texte vide sur champ obligatoire
❌ Nombre < 0
❌ Photos > 5MB
❌ Doublon (même localité + même date)
```

### ❌ ERREURS ARCHITECTURE

```
❌ Services non découplés
❌ BLoCs imbriqués
❌ Dépendances circulaires
❌ États non immutables
❌ Tests inexistants
❌ Documentation absente
```

---

## 📊 11. DONNÉES & RAPPORTS

### Tableaux de bord (Dashboard Rapports) :

#### 11.1 Résumé par site

```
Localité: XXX
├─ Total visites: 15
├─ Complétées: 12
├─ En cours: 2
├─ Échouées: 1
├─ Taux complétion: 80%
└─ Dernière visite: 2026-03-30 14:35
```

#### 11.2 Indicateurs clés

```
Nombre de plaintes: 5
Nombre d'accidents: 2
Nombre travaux complétés: 8
Budget total engagé: 450,000 MRU
Taux satisfaction: 87%
Avancement global: 65%
```

#### 11.3 Graphiques

- 📈 Progression par mois
- 🥧 Répartition par état (bon/mayen/mauvais)
- 📊 Taux complétion par opérateur
- 💰 Budget engagé vs estimé

### Export données :

- ✅ PDF (rapport complet)
- ✅ CSV (données brutes)
- ✅ Excel (analyse détaillée)
- ✅ JSON (intégration systèmes)

---

## 🚀 12. ARCHITECTURE TECHNIQUE

### 12.1 Stack recommandé

```
Frontend:      Flutter 3.x + Dart
Backend:       Node.js / Python / Java
Database:      PostgreSQL (serveur) + SQLite (local)
Auth:          JWT + Refresh tokens
Storage:       AWS S3 / Google Cloud Storage
Maps:          Google Maps API
```

### 12.2 Structure dossiers Flutter

```
lib/
├─ main.dart
├─ config/
│  ├─ app_constants.dart
│  ├─ app_theme.dart
│  └─ routes.dart
├─ data/
│  ├─ models/
│  │  ├─ formulaire_model.dart
│  │  ├─ localite_model.dart
│  │  └─ ...
│  ├─ datasources/
│  │  ├─ local_datasource.dart
│  │  └─ remote_datasource.dart
│  └─ repositories/
│     ├─ formulaire_repository.dart
│     └─ ...
├─ domain/
│  ├─ entities/
│  └─ usecases/
├─ presentation/
│  ├─ bloc/ (ou Provider)
│  ├─ pages/
│  │  ├─ login_page.dart
│  │  ├─ dashboard_page.dart
│  │  ├─ formulaires/
│  │  │  ├─ declenchement_page.dart
│  │  │  ├─ certification_page.dart
│  │  │  └─ ...
│  │  └─ ...
│  └─ widgets/
│     ├─ custom_dropdown.dart
│     ├─ gps_widget.dart
│     ├─ photo_upload_widget.dart
│     └─ ...
├─ services/
│  ├─ auth_service.dart
│  ├─ sync_service.dart
│  ├─ gps_service.dart
│  └─ ...
└─ utils/
   ├─ validators.dart
   └─ helpers.dart
```

### 12.3 Modèles données

```dart
// Formulaire générique
class Formulaire {
  String id;
  String type; // "declenchement", "certification", etc.
  DateTime date;
  GpsLocation gps;
  Map<String, dynamic> questions;
  Map<String, dynamic> reponses;
  List<Photo> photos;
  String remarques;
  String statut; // "brouillon", "complète", "validée", "envoyée"
  DateTime dateCreation;
  DateTime dateModification;
}

// Localité
class Localite {
  String id;
  String nom;
  String wilaya;
  String moughataa;
  String commune;
  GpsLocation gps;
  DateTime dateCreation;
}

// GPS
class GpsLocation {
  double latitude;
  double longitude;
  double precision;
}
```

---

## ✅ 13. CHECKLIST DE VALIDATION

Avant de considérer l'app complète :

- ✅ Authentification fonctionnelle
- ✅ Paramétrage initial complet
- ✅ Dashboard affiche tous les formulaires
- ✅ Les 9 opérations implémentées
- ✅ Logique dynamique testée (Oui/Non)
- ✅ Photos uploadables et stockables
- ✅ Validation avant envoi
- ✅ Sync offline/online fonctionne
- ✅ Rapports générents
- ✅ GPS fonctionne
- ✅ Aucun doublon dans dropdowns
- ✅ Tests unitaires à 80%+ (critiques)
- ✅ Tests UI sur 2-3 formulaires clés
- ✅ Documentation complète
- ✅ Déploiement iOS/Android

---

## 🎯 PROMPT FINAL POUR IA (RECONSTRUCTION COMPLÈTE)

```
Build a complete Flutter mobile application for sanitation data collection (PIAM).

REQUIREMENTS:

1. AUTHENTICATION
   - Login screen with username/password
   - Date/time validation
   - JWT + refresh tokens
   - Secure storage (flutter_secure_storage)

2. INITIAL SETUP
   - Cascading dropdowns (Wilaya → Moughataa → Commune → Localité)
   - GPS capture with permission handling
   - Option to add new location
   - Operator and project selection

3. DASHBOARD
   - User info display
   - 9 form cards with status indicators
   - Quick stats summary

4. 9 QUESTIONNAIRE MODULES
   (See detailed specs for each)
   
   All must include:
   - Date field (mandatory)
   - GPS capture (mandatory)
   - Dynamic questions
   - Conditional logic (Yes/No branching)
   - Photo upload (min 2, max 10)
   - Remarks field
   - Validation before submit

5. FORM MANAGEMENT
   - Status tracking (draft/complete/validated/sent)
   - Auto-save every 30 seconds
   - Offline support
   - Sync when online
   - Conflict resolution

6. DATA MODELS
   - Use immutable classes (freezed package)
   - Implement equatable for comparison
   - JSON serialization

7. ARCHITECTURE
   - Clean Architecture (Entity/UseCase/Repository)
   - BLoC or Provider for state management
   - Dependency injection (get_it)
   - Repository pattern for data access

8. DATABASE
   - SQLite for local storage (sqflite)
   - Remote API integration (REST/GraphQL)
   - Update local after successful sync

9. UI/UX
   - Material Design 3
   - Mobile-first responsive
   - Color-coded status (green/yellow/red)
   - Min font 14pt, buttons 48x48dp
   - Bottom navigation

10. VALIDATION
    - No dropdown duplicates
    - Valid GPS coordinates
    - No future dates
    - Mandatory fields before submit
    - Photo quality check

11. TESTING
    - Unit tests for models & services
    - Widget tests for critical forms
    - Mock data providers

12. ERROR HANDLING
    - Network errors
    - GPS unavailable
    - Offline scenarios
    - Validation errors with user feedback

DESIGN NOTES:
- Green = completed
- Yellow = in progress
- Red = error/attention
- Bottom bar navigation
- Top bar with location/time

OUTPUT:
- Full project structure
- All 9 form screens coded
- State management setup
- Database layer
- API integration skeleton
- Tests included
```

---

## 📝 NOTES FINALES

### Points critiques à ne PAS oublier :

1. **Formulaires dynamiques** = Logique If/Else stricte
2. **Dropdowns** = Pas de doublons, values valides
3. **Offline-first** = Sync auto quand connexion revient
4. **Validation** = Avant CHAQUE envoi
5. **Photos** = Metadata GPS auto-ajoutée
6. **Tests** = Au moins sur 3 formulaires clés
7. **Documentation** = Dans le code + guides externos

### Prochaines étapes recommandées :

1. ✅ Générer Data Models complets
2. ✅ Créer Repository layer
3. ✅ Implémenter BLoCs
4. ✅ Coder formulaires écran par écran
5. ✅ Ajouter tests
6. ✅ Setup CI/CD
7. ✅ Déploiement beta

---

**Document validé et prêt pour reconstruction complète** ✅
