### Où sont stockées mes données ?
Toutes les données saisies sont enregistrées localement sur votre appareil (base SQLite, table `questionnaires`, colonne `data_json`). Vous pouvez utiliser l'application sans connexion internet. La synchronisation avec le serveur est automatique dès qu'une connexion est disponible.

### Que se passe-t-il si je perds la connexion ?
Vous pouvez continuer à remplir et sauvegarder tous les formulaires. Rien n'est perdu : les données restent sur votre appareil et seront envoyées automatiquement dès que la connexion revient.
# ❓ FAQ - Application PIAM

## Questions générales

### Qu'est-ce que PIAM ?
**PIAM** signifie **Programme d'Investissement dans les Aménagements Municipaux**. C'est une application mobile développée pour faciliter le contrôle qualité des chantiers de construction de latrines publiques en Afrique.

### Qui utilise cette application ?
- Agents de contrôle qualité
- Ingénieurs de chantier
- Superviseurs de projets
- Équipes de maîtrise d'ouvrage

### Sur quelles plateformes l'application est-elle disponible ?
- **Android** : Version 8.0 (API 26) et supérieure
- **iOS** : Version 12.0 et supérieure

## Installation et configuration

### Comment installer l'application ?
1. Téléchargez l'APK depuis le serveur PIAM
2. Activez l'installation d'applications inconnues
3. Installez l'application
4. Accordez les permissions demandées

### Quelles permissions sont nécessaires ?
- **Localisation** : Pour géolocaliser les chantiers
- **Caméra** : Pour prendre des photos
- **Stockage** : Pour sauvegarder les données

### L'application fonctionne-t-elle hors ligne ?
Oui, l'application fonctionne en mode hors ligne. Les données sont sauvegardées localement et synchronisées automatiquement lorsque la connexion internet est disponible.

## Utilisation de l'application

### Comment se connecter ?
1. Saisissez votre nom d'utilisateur
2. Saisissez votre mot de passe
3. Appuyez sur "SE CONNECTER"
4. L'application mémorise vos identifiants pour les connexions futures

### Qu'est-ce que les "niveaux" de contrôle ?
L'application organise le contrôle en 3 niveaux logiques :

- **Niveau 1** : Données générales du projet
- **Niveau 2** : Organisation du chantier
- **Niveau 3** : Contrôle détaillé des travaux

### Comment naviguer entre les niveaux ?
L'application suit un flux linéaire :
1. Connexion → Paramétrage
2. Niveau 1 → Niveau 2 → Niveau 3
3. Synchronisation des données

### Que signifie "A priori" et "A posteriori" ?
- **A priori** : Contrôle effectué avant la réalisation des travaux
- **A posteriori** : Contrôle effectué après la réalisation des travaux

## Fonctionnalités

### Comment utiliser le GPS ?
1. Assurez-vous d'être en extérieur
2. L'application récupère automatiquement vos coordonnées
3. Vérifiez la précision avant de sauvegarder

### Comment prendre des photos ?
1. Appuyez sur le bouton caméra
2. Prenez la photo
3. Ajoutez une légende si nécessaire
4. La photo est automatiquement géolocalisée

### Comment sauvegarder mes données ?
- **Automatique** : L'application sauvegarde automatiquement à chaque section
- **Manuel** : Utilisez le bouton "Sauvegarder" flottant
- **Synchronisation** : Les données sont synchronisées en arrière-plan

### Puis-je modifier des données déjà saisies ?
Oui, vous pouvez modifier les données tant que vous n'avez pas quitté l'écran. Utilisez le bouton "Modifier" ou resaisissez directement dans les champs.

## Problèmes techniques

### L'application se ferme brusquement
**Causes possibles :**
- Mémoire insuffisante : Fermez les autres applications
- Version Android trop ancienne : Mettez à jour votre système
- Application corrompue : Réinstallez l'application

### Le GPS ne fonctionne pas
**Solutions :**
- Vérifiez les permissions dans les paramètres
- Activez la localisation haute précision
- Sortez à l'extérieur pour améliorer le signal
- Redémarrez l'application

### Les données ne se sauvegardent pas
**Vérifications :**
- Espace de stockage disponible (>100MB)
- Permissions de stockage accordées
- Application à jour
- Redémarrage de l'appareil

### L'application est lente
**Optimisations :**
- Fermez les applications en arrière-plan
- Libérez de l'espace de stockage
- Mettez à jour l'application
- Redémarrez l'appareil

### Erreur de synchronisation
**Résolutions :**
- Vérifiez la connexion internet
- Attendez la synchronisation automatique
- Forcez la synchronisation manuelle
- Contactez le support si persistant

## Données et confidentialité

### Où sont stockées mes données ?
- **Locale** : Base de données SQLite sur l'appareil
- **Cloud** : Serveur sécurisé PIAM (lors de synchronisation)
- **Sécurisé** : Chiffrement des données sensibles

### Mes données sont-elles sécurisées ?
Oui, l'application utilise :
- Chiffrement des identifiants (Flutter Secure Storage)
- Base de données locale chiffrée
- Transmission sécurisée (HTTPS)
- Gestion des permissions strictes

### Puis-je exporter mes données ?
Oui, l'application permet :
- Export PDF des rapports
- Export Excel des données
- Sauvegarde locale des photos
- Synchronisation cloud

### Combien de temps les données sont-elles conservées ?
- **Locale** : Indéfiniment (espace disponible)
- **Cloud** : Selon la politique de rétention PIAM
- **Photos** : Stockées localement et synchronisées

## Maintenance et support

### Comment mettre à jour l'application ?
- **Automatique** : Via Google Play Store/App Store
- **Manuel** : Téléchargement depuis le serveur PIAM
- **Notification** : L'application signale les mises à jour

### Qui contacter en cas de problème ?
- **Support technique** : support@piam.org
- **Téléphone** : +225 XX XX XX XX
- **Local** : Bureau technique PIAM

### L'application est-elle gratuite ?
Oui, l'application est gratuite pour les agents autorisés du programme PIAM.

## Développement

### Comment contribuer au projet ?
1. Clonez le repository Git
2. Créez une branche feature
3. Développez votre fonctionnalité
4. Tests unitaires et validation
5. Pull request pour revue

### Quelles technologies sont utilisées ?
- **Framework** : Flutter 3.35.3
- **Language** : Dart 3.9.2
- **Database** : SQLite
- **GPS** : Geolocator
- **Storage** : Hive, Secure Storage

### Comment exécuter les tests ?
```bash
# Tests unitaires
flutter test

# Analyse du code
flutter analyze

# Build de production
flutter build apk --release
```

## Glossaire technique

### API
**Application Programming Interface** - Interface de programmation permettant la communication entre l'application et les services externes.

### APK
**Android Package Kit** - Format de fichier pour les applications Android.

### Clean Architecture
Approche architecturale séparant l'application en couches indépendantes (UI, Business Logic, Data).

### CRUD
**Create, Read, Update, Delete** - Opérations de base sur les données.

### GPS
**Global Positioning System** - Système de géolocalisation par satellite.

### JSON
**JavaScript Object Notation** - Format de données structuré pour l'échange d'informations.

### SDK
**Software Development Kit** - Ensemble d'outils pour développer des applications.

### SQLite
Base de données relationnelle embarquée, ne nécessitant pas de serveur.

### State Management
Gestion de l'état de l'application (données, UI, navigation).

### Widget
Composant d'interface utilisateur dans Flutter.

## Conseils d'utilisation

### Bonnes pratiques
1. **Sauvegarde régulière** : Sauvegardez après chaque section importante
2. **Photos de qualité** : Prenez des photos bien éclairées et nettes
3. **Coordonnées précises** : Vérifiez le GPS avant de valider
4. **Remarques détaillées** : Notez les anomalies avec précision

### Organisation du travail
1. **Préparation** : Liste de contrôle et outils nécessaires
2. **Méthode** : Contrôle systématique section par section
3. **Documentation** : Photos et mesures des problèmes
4. **Communication** : Expliquez les remarques à l'équipe chantier

### Sécurité sur chantier
- Portez l'équipement de protection individuel (EPI)
- Respectez les zones dangereuses
- Ne dérangez pas les travaux en cours
- Signalez les risques identifiés

---

**FAQ - Version 1.0**
*Dernière mise à jour : Mars 2026*

**Vous n'avez pas trouvé la réponse à votre question ?**
Contactez le support technique : support@piam.org