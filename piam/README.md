# PIAM - Contrôle Latrines Publiques

## 📋 Vue d'ensemble

PIAM est une application mobile Flutter développée pour le contrôle qualité et la supervision des chantiers de construction de latrines publiques. L'application permet aux agents de contrôle de suivre et valider différents aspects des travaux selon une méthodologie structurée en niveaux.

## 📚 Documentation

### Guides utilisateur
- **[Guide Utilisateur Complet](GUIDE_UTILISATEUR.md)** - Instructions détaillées pour utiliser l'application
- **[FAQ](FAQ.md)** - Réponses aux questions fréquentes

### Guides développeur
- **[Guide Développeur](GUIDE_DEVELOPPEUR.md)** - Architecture technique et bonnes pratiques
- **[Architecture Technique](ARCHITECTURE.md)** - Détails techniques de l'application
- **[Configuration](CONFIGURATION.md)** - Setup de l'environnement de développement

## 🎯 Objectif

L'application facilite le contrôle qualité des latrines publiques en permettant :
- La collecte structurée des données de chantier
- Le suivi de l'organisation du personnel et des matériaux
- La validation des travaux selon des critères prédéfinis
- Le stockage sécurisé des données de contrôle

## 🏗️ Architecture de l'application

### Structure des fichiers
```
lib/
├── main.dart                    # Point d'entrée de l'application
├── screens/                     # Interfaces utilisateur
│   ├── login_screen.dart        # Écran de connexion
│   ├── parametrage_screen.dart  # Configuration du projet
│   ├── niveau1_donnees_generales.dart    # Données générales
│   ├── niveau2_organisation_chantier.dart # Organisation chantier
│   └── niveau3_controle_travaux.dart      # Contrôle des travaux
├── models/                      # Modèles de données
│   ├── chantier.dart
│   ├── controle_travaux.dart
│   └── photo_gps.dart
├── services/                    # Services métier
│   ├── sqlite_service.dart      # Base de données locale
│   ├── gps_service.dart         # Service de géolocalisation
│   └── sync_service.dart        # Synchronisation des données
└── test/
    └── widget_test.dart         # Tests unitaires
```

### Technologies utilisées
- **Flutter 3.35.3** : Framework de développement mobile
- **Dart 3.9.2** : Langage de programmation
- **SQLite** : Base de données locale
- **Geolocator** : Services de géolocalisation
- **Hive** : Stockage NoSQL pour la persistance
- **Connectivity Plus** : Vérification de la connectivité réseau

## 📱 Fonctionnalités principales

### 1. Écran de connexion
- Authentification des agents de contrôle
- Stockage sécurisé des identifiants
- Validation des champs obligatoires

### 2. Écran de paramétrage
- Configuration des paramètres du projet
- Définition des caractéristiques de base du chantier

### 3. Niveau 1 - Données générales
- **Informations générales** : Type de latrines, dimensions, matériaux
- **Localisation** : Coordonnées GPS, adresse
- **Contexte** : Destruction anciennes installations, construction mur
- **Équipements** : Type de latrines (semi-enterrée/hors-sol)

### 4. Niveau 2 - Organisation du chantier
- **Personnel** : Nombre d'ouvriers, qualifications, équipements de protection
- **Matériels** : Disponibilité et état des équipements
- **Sécurité** : Mesures de protection, premiers secours
- **Gestion des déchets** : Plan de gestion, tri, évacuation

### 5. Niveau 3 - Contrôle des travaux
Le contrôle est organisé en 15 sections :

#### Section 1 : Installation du chantier
- État d'avancement (Achevé/En cours)

#### Section 2 : Implantation et fouilles
- Date d'implantation, coordonnées GPS
- Dates de début/fin des fouilles
- Conformité des fouilles

#### Section 3-4 : Construction murs et superstructure
- **A priori** : Vérification avant travaux (qualité matériaux, ferraillage)
- **A posteriori** : Contrôle après réalisation (dimensions, étanchéité)

#### Section 5 : Toiture
- Structure métallique, charpente
- Inclinaison pour évacuation eaux

#### Section 6-10 : Finitions intérieures
- Enduits murs, peinture, carrelage
- Cuvette WC, système fermeture

#### Section 11-12 : Équipements annexes
- Dispositif lavage mains (DLM)
- Garde-fous, accès PMR

#### Section 13-15 : Sécurité et gestion
- Plan gestion environnementale (PGES)
- Management participatif local (MGP)
- Appréciation générale et recommandations

## 🔧 Installation et configuration

### Prérequis
- Flutter SDK 3.35.3+
- Dart SDK 3.9.2+
- Android Studio ou VS Code
- Émulateur Android ou appareil physique

### Installation
```bash
# Cloner le repository
git clone <repository-url>
cd piam-mobile/piam

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Permissions requises
L'application nécessite les permissions suivantes :
- **Localisation** : Pour la géolocalisation des chantiers
- **Stockage** : Pour sauvegarder les données localement
- **Caméra** : Pour prendre des photos des travaux

## 📊 Modèle de données

### Tables principales
- **chantier** : Informations générales du projet
- **controle_travaux** : Données de contrôle par niveau
- **photo_gps** : Photos avec géolocalisation

### Structure des données de contrôle
Chaque niveau de contrôle stocke un JSON structuré contenant :
- Identifiant du projet
- Section du contrôle
- Statut (actif/inactif)
- Date de contrôle
- Détails structurés par section

## 🔄 Flux de travail

1. **Connexion** : Authentification de l'agent
2. **Paramétrage** : Configuration du chantier
3. **Niveau 1** : Saisie des données générales
4. **Niveau 2** : Évaluation de l'organisation
5. **Niveau 3** : Contrôle détaillé des travaux
6. **Synchronisation** : Sauvegarde et export des données

## 🛠️ Développement

### Scripts disponibles
```bash
# Analyse du code
flutter analyze

# Tests unitaires
flutter test

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

### Structure du code
- **Clean Architecture** : Séparation claire entre UI, logique métier et données
- **State Management** : Utilisation de StatefulWidget pour la gestion d'état
- **Services** : Injection de dépendances pour les services externes
- **Modèles** : Classes de données immuables

## 📋 Critères de qualité

### Niveau 1 - Données générales
- Dimensions conformes aux normes
- Matériaux de qualité appropriée
- Localisation géographique précise

### Niveau 2 - Organisation
- Personnel qualifié et en nombre suffisant
- Équipements de protection individuels (EPI)
- Plan de gestion des déchets

### Niveau 3 - Travaux
- Respect des plans et spécifications
- Qualité des matériaux et exécution
- Sécurité et accessibilité

## 🔒 Sécurité et confidentialité

- Stockage sécurisé des identifiants utilisateur
- Chiffrement des données sensibles
- Gestion des permissions d'accès
- Synchronisation sécurisée des données

## 📈 Métriques et indicateurs

L'application permet de suivre :
- Taux de conformité par section
- Avancement des travaux
- Nombre d'anomalies détectées
- Recommandations d'amélioration

## 🤝 Contribution

### Processus de développement
1. Créer une branche feature
2. Développer la fonctionnalité
3. Tests unitaires et d'intégration
4. Pull request avec revue de code
5. Merge après validation

### Standards de code
- Respect des conventions Flutter/Dart
- Documentation des fonctions complexes
- Tests pour toute nouvelle fonctionnalité
- Analyse statique sans erreur

## 📞 Support et maintenance

### Contacts
- **Développeur** : Équipe PIAM
- **Support technique** : [contact@piam.org]
- **Documentation** : Ce README

### Maintenance
- Mises à jour régulières des dépendances
- Corrections de bugs prioritaires
- Évolutions fonctionnelles selon besoins terrain

---

**PIAM - Programme d'Investissement dans les Aménagements Municipaux**
*Application mobile pour le contrôle qualité des latrines publiques*

📖 **Documentation complète disponible dans :**
- [Guide Utilisateur](GUIDE_UTILISATEUR.md)
- [Guide Développeur](GUIDE_DEVELOPPEUR.md)
- [Architecture Technique](ARCHITECTURE.md)
- [Configuration](CONFIGURATION.md)
- [FAQ](FAQ.md)
