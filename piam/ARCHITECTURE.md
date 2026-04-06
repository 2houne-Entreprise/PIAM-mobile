# 🏗️ ARCHITECTURE COMPLÈTE – APPLICATION PIAM

**Version:** 1.0  
**Date:** 2026-03-30  
**Framework:** Flutter 3.x + Dart  
**Architecture Pattern:** Clean Architecture + BLoC

---

## 🎯 1. PRINCIPES ARCHITECTURAUX

### 1.1 Clean Architecture

```
Presentation Layer (UI)
    ↓ (dépend de)
BLoC/State Management Layer
    ↓ (dépend de)
Domain Layer (UseCases)
    ↓ (dépend de)
Data Layer (Repositories & DataSources)
    ↓ (dépend de)
External Services (API, SQLite, GPS, etc.)
```

### 1.2 Patterns à utiliser

- **BLoC** pour la gestion d'état (ou Provider si préférence)
- **Repository Pattern** pour l'abstraction des données
- **Dependency Injection** (GetIt)
- **Freezed** pour l'immutabilité des modèles
- **JSON serialization** pour persistence

### 1.3 Principes SOLID

- **S**ingle Responsibility: Une classe = Une responsabilité
- **O**pen/Closed: Ouvert à extension, fermé à modification
- **L**iskov Substitution: Respect des contrats d'interface
- **I**nterface Segregation: Interfaces spécifiques
- **D**ependency Inversion: Dépendre d'abstractions

---

## 📁 2. STRUCTURE DES DOSSIERS

```
lib/
├─ main.dart                          # Point d'entrée
├─ bootstrap.dart                     # Initialisation dépendances
│
├─ config/
│  ├─ app_constants.dart              # Constantes
│  ├─ app_theme.dart                  # Thème Material 3
│  ├─ app_strings.dart                # Strings localisées
│  └─ routes.dart                     # Navigation routes
│
├─ data/
│  ├─ datasources/
│  │  ├─ local/
│  │  │  ├─ sqlite_service.dart       # SQLite wrapper
│  │  │  └─ shared_preferences_local.dart
│  │  └─ remote/
│  │     ├─ api_client.dart           # HTTP client
│  │     ├─ api_endpoints.dart        # Endpoints constants
│  │     └─ api_service.dart          # API calls
│  ├─ models/
│  │  ├─ data_models.dart             # Tous les models
│  │  ├─ formulaire_model.dart        # (si séparé)
│  │  ├─ localite_model.dart
│  │  ├─ utilisateur_model.dart
│  │  ├─ gps_location_model.dart
│  │  └─ photo_model.dart
│  └─ repositories/
│     ├─ formulaire_repository.dart   # Interface + implémentation
│     ├─ localite_repository.dart
│     ├─ utilisateur_repository.dart
│     ├─ auth_repository.dart
│     ├─ sync_repository.dart
│     └─ rapports_repository.dart
│
├─ domain/
│  ├─ entities/                       # (Optionnel si same as models)
│  ├─ repositories/
│  │  ├─ formulaire_repository.dart   # Interfaces abstraites
│  │  ├─ localite_repository.dart
│  │  └─ ...
│  └─ usecases/
│     ├─ auth/
│     │  ├─ login_usecase.dart
│     │  ├─ logout_usecase.dart
│     │  ├─ refresh_token_usecase.dart
│     │  └─ verify_datetime_usecase.dart
│     ├─ formulaire/
│     │  ├─ create_formulaire_usecase.dart
│     │  ├─ update_formulaire_usecase.dart
│     │  ├─ get_formulaire_usecase.dart
│     │  ├─ list_formulaires_usecase.dart
│     │  ├─ submit_formulaire_usecase.dart
│     │  └─ validate_formulaire_usecase.dart
│     ├─ localite/
│     │  ├─ get_localites_usecase.dart
│     │  ├─ get_localites_filtered_usecase.dart
│     │  ├─ add_localite_usecase.dart
│     │  └─ get_localite_details_usecase.dart
│     ├─ gps/
│     │  └─ capture_gps_usecase.dart
│     ├─ photo/
│     │  ├─ capture_photo_usecase.dart
│     │  └─ upload_photo_usecase.dart
│     ├─ sync/
│     │  ├─ sync_formulaires_usecase.dart
│     │  ├─ sync_photos_usecase.dart
│     │  └─ handle_sync_conflict_usecase.dart
│     ├─ rapports/
│     │  ├─ generate_rapport_localité_usecase.dart
│     │  ├─ export_rapport_usecase.dart
│     │  └─ get_statistics_usecase.dart
│     └─ parametrage/
│        └─ save_parametrage_usecase.dart
│
├─ presentation/
│  ├─ bloc/
│  │  ├─ auth/
│  │  │  ├─ auth_event.dart
│  │  │  ├─ auth_state.dart
│  │  │  └─ auth_bloc.dart
│  │  ├─ formulaire/
│  │  │  ├─ formulaire_event.dart
│  │  │  ├─ formulaire_state.dart
│  │  │  └─ formulaire_bloc.dart
│  │  ├─ localite/
│  │  │  ├─ localite_event.dart
│  │  │  ├─ localite_state.dart
│  │  │  └─ localite_bloc.dart
│  │  ├─ sync/
│  │  │  ├─ sync_event.dart
│  │  │  ├─ sync_state.dart
│  │  │  └─ sync_bloc.dart
│  │  ├─ gps/
│  │  │  ├─ gps_event.dart
│  │  │  ├─ gps_state.dart
│  │  │  └─ gps_bloc.dart
│  │  └─ camera/
│  │     ├─ camera_event.dart
│  │     ├─ camera_state.dart
│  │     └─ camera_bloc.dart
│  ├─ pages/
│  │  ├─ auth/
│  │  │  ├─ login_page.dart
│  │  │  └─ forgot_password_page.dart
│  │  ├─ parametrage/
│  │  │  ├─ parametrage_page.dart
│  │  │  └─ localite_selection_page.dart
│  │  ├─ dashboard/
│  │  │  ├─ dashboard_page.dart
│  │  │  └─ quick_stats_widget.dart
│  │  ├─ formulaires/
│  │  │  ├─ base_formulaire_page.dart   # Template réutilisable
│  │  │  ├─ declenchement_page.dart
│  │  │  ├─ certification_fdal_page.dart
│  │  │  ├─ etat_lieux_localite_page.dart
│  │  │  ├─ etat_lieux_menage_page.dart
│  │  │  ├─ dernier_suivi_localite_page.dart
│  │  │  ├─ dernier_suivi_menage_page.dart
│  │  │  ├─ inventaire_page.dart
│  │  │  ├─ programmation_travaux_page.dart
│  │  │  └─ travaux_receptiones_page.dart
│  │  ├─ rapports/
│  │  │  ├─ rapports_dashboard_page.dart
│  │  │  ├─ rapport_localite_page.dart
│  │  │  ├─ statistiques_page.dart
│  │  │  └─ export_page.dart
│  │  └─ parametres/
│  │     ├─ settings_page.dart
│  │     ├─ profil_page.dart
│  │     └─ deconnexion_page.dart
│  └─ widgets/
│     ├─ common/
│     │  ├─ app_bar_custom.dart
│     │  ├─ bottom_nav_bar.dart
│     │  ├─ custom_button.dart
│     │  ├─ custom_text_field.dart
│     │  ├─ loading_indicator.dart
│     │  └─ error_dialog.dart
│     ├─ formulaire_widgets/
│     │  ├─ formulaire_card.dart
│     │  ├─ formulaire_status_badge.dart
│     │  ├─ progress_indicator.dart
│     │  └─ sync_indicator.dart
│     ├─ form_fields/
│     │  ├─ custom_dropdown.dart      # Pas de doublons!
│     │  ├─ custom_text_field.dart
│     │  ├─ custom_date_field.dart
│     │  ├─ custom_number_field.dart
│     │  ├─ oui_non_selector.dart
│     │  ├─ gps_widget.dart            # Capture GPS
│     │  ├─ photo_upload_widget.dart   # Capture photos
│     │  ├─ checkbox_list_widget.dart
│     │  ├─ rating_widget.dart         # 1-5 stars
│     │  └─ signature_pad_widget.dart  # Signature
│     └─ conditional/
│        ├─ conditional_field_group.dart  # Affiche/masque basé condition
│        └─ form_branch_widget.dart       # Branche OUI/NON
│
├─ services/
│  ├─ auth_service.dart               # Gestion auth/tokens
│  ├─ gps_service.dart                # Geolocator wrapper
│  ├─ camera_service.dart             # Image picker wrapper
│  ├─ sync_service.dart               # Synchronisation online/offline
│  ├─ notifications_service.dart      # Notifications locales
│  ├─ database_service.dart           # SQLite helper
│  ├─ storage_service.dart            # Secure storage
│  └─ logger_service.dart             # Logging
│
├─ utils/
│  ├─ validators.dart
│  │  ├─ validateEmail()
│  │  ├─ validatePassword()
│  │  ├─ validateGPS()
│  │  ├─ validateDate()
│  │  ├─ validateDropdownValue()
│  │  └─ validateFormulaire()
│  ├─ formatters.dart
│  │  ├─ formatDate()
│  │  ├─ formatGPS()
│  │  ├─ formatMoney()
│  │  └─ formatFileSize()
│  ├─ helpers.dart
│  │  ├─ removeDuplicates()
│  │  ├─ generateId()
│  │  ├─ convertModelToJson()
│  │  └─ mergeConflicts()
│  ├─ exceptions.dart
│  │  ├─ AppException
│  │  ├─ NetworkException
│  │  ├─ DatabaseException
│  │  ├─ ValidationException
│  │  └─ SyncException
│  └─ extensions.dart
│     ├─ String extensions
│     ├─ DateTime extensions
│     ├─ BuildContext extensions
│     └─ List extensions
│
├─ l10n/
│  ├─ arb/
│  │  ├─ app_fr.arb               # Localisations Français
│  │  └─ app_ar.arb               # Localisations Arabe (optionnel)
│  └─ gen/
│     └─ app_localizations.dart   # Generated
│
└─ test/
   ├─ unit/
   │  ├─ validators_test.dart
   │  ├─ formatters_test.dart
   │  └─ models_test.dart
   ├─ bloc/
   │  ├─ auth_bloc_test.dart
   │  ├─ formulaire_bloc_test.dart
   │  └─ ...
   ├─ widget/
   │  ├─ login_page_test.dart
   │  ├─ dashboard_page_test.dart
   │  ├─ etat_lieux_menage_page_test.dart
   │  └─ ...
   └─ fixture/
      ├─ mock_data.dart
      ├─ mock_repositories.dart
      └─ mock_services.dart
```

---

## 🔄 3. FLUX DE DONNÉES

### 3.1 Cycle complet d'une action

```
1. USER INTERACTION
   ↓
2. PAGE CALLS BLoC EVENT
   formulaireBloc.add(CreateFormulaireEvent(...))
   ↓
3. BLoC PROCESSES EVENT
   event → mapEventToState() → emits State
   ↓
4. BLoC CALLS USE CASE
   createFormulaireUseCase(params)
   ↓
5. USE CASE CALLS REPOSITORY
   formulaireRepository.createFormulaire(...)
   ↓
6. REPOSITORY CALLS DATA SOURCE
   localDataSource.saveFormulaire()   (SQLite)
   OU remoteDataSource.submitFormulaire() (API)
   ↓
7. DATA SOURCE PERSISTS/SYNCS
   → SQLite (local) + cache
   → API (remote) si online
   ↓
8. BLoC EMITS NEW STATE
   emit(FormulaireCreatedState(...))
   ↓
9. PAGE REBUILDS WITH NEW STATE
   BlocBuilder → Widget tree updates
   ↓
10. USER SEES RESULT
```

### 3.2 Gestion offline/online

```
USER GOES OFFLINE
        ↓
FORMULAIRE SAVED LOCALLY IN SQLITE
        ↓
SYNC SERVICE MARKS FOR SYNC
        ↓
USER SEES "⚠️ À envoyer"
        ↓
USER GOES ONLINE
        ↓
SYNC SERVICE DETECTS CONNECTION
        ↓
RETRY SEND FORMULAIRE + PHOTOS
        ↓
IF SUCCESS
  → UPDATE STATUS IN SQLITE
  → USER SEES "✅ Envoyée"
        ↓
IF CONFLICT
  → SHOW MERGE DIALOG
  → USER CHOOSES (keep local / take server)
```

---

## ✅ CHECKLIST IMPLÉMENTATION

### Phase 1: Fondation
- [ ] Setup projet Flutter + dépendances
- [ ] Créer structure dossiers
- [ ] Configurer GetIt (DI)
- [ ] Créer models + exceptions
- [ ] Setup SQLite local

### Phase 2: Authentification
- [ ] Créer LoginPage + AuthBloc
- [ ] Implémenter JWT storage
- [ ] Setup refresh token
- [ ] Vérifier date/heure système
- [ ] Tests login

### Phase 3: Paramétrage
- [ ] Créer ParametragePage
- [ ] Dropdowns cascade (Wilaya → Commune)
- [ ] GPS capture widget
- [ ] Créer localite widget
- [ ] Save parametrage local

### Phase 4: Dashboard
- [ ] Créer DashboardPage
- [ ] Afficher 9 formulaires
- [ ] Status badges (brouillon/complet/envoyé)
- [ ] Bouton rapide stats
- [ ] Navigation vers formulaires

### Phase 5: Formulaires (Itération par formulaire)
Pour chaque formulaire:
- [ ] Créer model
- [ ] Créer page/widget
- [ ] Implémenter logique conditionnelle
- [ ] Ajouter validation
- [ ] Tester widget
- [ ] Intégrer à dashboard

### Phase 6: Synchronisation
- [ ] Créer SyncService
- [ ] Détecter connexion/déconnexion
- [ ] Envoyer formulaires en attente
- [ ] Envoyer photos
- [ ] Gestion conflits

### Phase 7: Rapports
- [ ] Créer RapportService
- [ ] Page statistiques
- [ ] Export PDF/CSV/Excel
- [ ] Graphiques

### Phase 8: Tests & Polish
- [ ] Tests unitaires (80%)
- [ ] Tests widgets
- [ ] Intégration offline/online
- [ ] Performance optimization
- [ ] Déploiement beta

---

**Document complet et prêt pour mise en œuvre** ✅
