# 🏗️ Architecture Technique - Application PIAM

## Vue d'ensemble

L'application PIAM est une application mobile Flutter native qui suit les principes de Clean Architecture pour assurer maintenabilité, testabilité et évolutivité.

## Architecture en couches

### 1. Couche Présentation (UI)
**Responsabilités** : Interface utilisateur, gestion d'état, navigation

#### Structure
```
screens/
├── login_screen.dart              # Authentification
├── parametrage_screen.dart        # Configuration projet
├── niveau1_donnees_generales.dart  # Données générales
├── niveau2_organisation_chantier.dart # Organisation
└── niveau3_controle_travaux.dart   # Contrôle travaux
```

#### Patterns utilisés
- **StatefulWidget** : Gestion d'état local
- **Form validation** : Validation des données utilisateur
- **ExpansionTile** : Interface accordéon pour sections
- **FutureBuilder** : Gestion des états de chargement

### 2. Couche Domaine (Business Logic)
**Responsabilités** : Règles métier, validation, coordination

#### Services métier
```dart
// Injection de dépendances
class ControleTravauxService {
  final SQLiteService _dbService;
  final GPSService _gpsService;

  ControleTravauxService(this._dbService, this._gpsService);

  Future<void> saveControleData(Map<String, dynamic> data) async {
    // Validation métier
    await _validateData(data);

    // Enrichissement avec GPS
    final position = await _gpsService.getLastPosition();
    data['gps'] = {'lat': position.latitude, 'lng': position.longitude};

    // Sauvegarde
    await _dbService.insert('controle_travaux', data);
  }
}
```

### 3. Couche Données (Data)
**Responsabilités** : Persistance, API, cache

#### Base de données SQLite
```sql
-- Tables principales
CREATE TABLE chantier (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom_projet TEXT NOT NULL,
  localisation TEXT,
  type_ouvrage TEXT,
  date_debut DATETIME,
  caracteristiques TEXT, -- JSON
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE controle_travaux (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER,
  section TEXT,
  status INTEGER, -- 0:inactif, 1:actif
  checked_at DATETIME,
  details TEXT, -- JSON structuré
  FOREIGN KEY (project_id) REFERENCES chantier(id)
);

CREATE TABLE photo_gps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  controle_id INTEGER,
  latitude REAL,
  longitude REAL,
  photo_path TEXT,
  timestamp DATETIME,
  FOREIGN KEY (controle_id) REFERENCES controle_travaux(id)
);
```

## Flux de données

### 1. Authentification
```
UI (LoginScreen) → SecureStorage → ParametrageScreen
```

### 2. Saisie de données
```
UI → Validation → Enrichissement GPS → SQLite → Confirmation
```

### 3. Synchronisation
```
SQLite → Vérification connectivité → API REST → Serveur distant
```

## Gestion d'état

### Pattern State Management
L'application utilise un état local simple avec StatefulWidget :

```dart
class _Niveau3ControleTravauxState extends State<Niveau3ControleTravaux> {
  // État local
  final Map<String, dynamic> _formData = {};

  // Mise à jour atomique
  void _updateField(String key, dynamic value) {
    setState(() => _formData[key] = value);
  }

  // Validation et sauvegarde
  Future<void> _saveForm() async {
    if (_isFormValid()) {
      await _dbService.saveData(_formData);
      _showSuccessMessage();
    }
  }
}
```

### Avantages
- ✅ Simple et prévisible
- ✅ Pas de dépendances externes
- ✅ Performance optimale pour formulaires
- ✅ Debug facile

## Persistence des données

### Stratégie multi-niveaux
1. **Mémoire** : État actuel du formulaire
2. **SQLite** : Données validées localement
3. **Hive** : Cache pour données fréquentes
4. **SecureStorage** : Identifiants utilisateur

### Migration de base de données
```dart
// Version management
Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE controle_travaux ADD COLUMN gps_data TEXT');
  }
  if (oldVersion < 3) {
    await db.execute('CREATE TABLE photo_gps (...)');
  }
}
```

## Services externes

### Géolocalisation
```dart
class GPSService {
  static Future<Position> getCurrentPosition() async {
    // Vérification permissions
    final hasPermission = await _checkPermissions();
    if (!hasPermission) throw GPSPermissionDeniedException();

    // Configuration précision
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // mètres
    );

    // Récupération position
    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }
}
```

### Connectivité réseau
```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get status => _statusController.stream;

  void startMonitoring() {
    _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final status = _mapToStatus(results);
        _statusController.add(status);
      }
    );
  }

  ConnectivityStatus _mapToStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) return ConnectivityStatus.wifi;
    if (results.contains(ConnectivityResult.mobile)) return ConnectivityStatus.mobile;
    return ConnectivityStatus.offline;
  }
}
```

## Gestion d'erreurs

### Stratégie globale
```dart
class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    if (error is GPSPermissionDeniedException) {
      _showPermissionDialog(context);
    } else if (error is NetworkException) {
      _showNetworkError(context);
    } else {
      _showGenericError(context, error.toString());
    }
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requise'),
        content: const Text('L\'application a besoin d\'accéder à votre localisation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }
}
```

### Types d'erreurs personnalisés
```dart
class PiamException implements Exception {
  final String message;
  final String? code;

  PiamException(this.message, {this.code});

  @override
  String toString() => 'PiamException: $message${code != null ? ' ($code)' : ''}';
}

class ValidationException extends PiamException {
  ValidationException(String field) : super('Champ $field invalide');
}

class GPSPermissionDeniedException extends PiamException {
  GPSPermissionDeniedException() : super('Permission GPS refusée');
}
```

## Tests et qualité

### Structure des tests
```
test/
├── unit/                    # Tests unitaires
│   ├── services/
│   │   ├── sqlite_service_test.dart
│   │   └── gps_service_test.dart
│   └── models/
│       └── chantier_test.dart
├── integration/             # Tests d'intégration
│   └── screens/
│       └── login_flow_test.dart
└── e2e/                     # Tests end-to-end
    └── user_journey_test.dart
```

### Test unitaire exemple
```dart
void main() {
  group('SQLiteService', () {
    late SQLiteService service;
    late Database db;

    setUp(() async {
      service = SQLiteService();
      db = await service.database;
      // Setup test data
    });

    tearDown(() async {
      // Cleanup
      await db.delete('test_table');
    });

    test('should insert and retrieve data', () async {
      final testData = {'name': 'Test Project', 'status': 1};

      final id = await service.insert('chantier', testData);
      final retrieved = await service.getById('chantier', id);

      expect(retrieved['name'], equals('Test Project'));
      expect(retrieved['status'], equals(1));
    });
  });
}
```

## Performance et optimisation

### Optimisations UI
- **ListView.builder** : Pour listes longues
- **const constructors** : Widgets immuables
- **RepaintBoundary** : Isolation des zones de redessin
- **Image.memory** : Cache des images

### Optimisations données
- **IndexedDB** : Requêtes optimisées
- **Lazy loading** : Chargement progressif
- **Compression** : Données JSON compressées
- **Background sync** : Synchronisation non-bloquante

## Sécurité

### Authentification
- Stockage sécurisé des identifiants
- Token JWT pour API
- Expiration automatique des sessions

### Chiffrement
```dart
class EncryptionService {
  static const String _key = 'your-encryption-key';

  static String encrypt(String data) {
    final key = Key.fromUtf8(_key);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    return encrypter.encrypt(data, iv: iv).base64;
  }

  static String decrypt(String encryptedData) {
    final key = Key.fromUtf8(_key);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    return encrypter.decrypt64(encryptedData, iv: iv);
  }
}
```

## Déploiement et CI/CD

### Pipeline CI/CD
```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.3'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.3'
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

### Configuration de build
```yaml
# pubspec.yaml - Configuration avancée
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/

  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700

dependencies:
  flutter:
    sdk: flutter
  # Core dependencies...
  flutter_secure_storage: ^10.0.0
  sqflite: ^2.2.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  integration_test:
    sdk: flutter
```

## Monitoring et analytics

### Suivi des performances
```dart
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};

  static void startTimer(String key) {
    _timers[key] = Stopwatch()..start();
  }

  static void stopTimer(String key) {
    final timer = _timers[key];
    if (timer != null) {
      timer.stop();
      _logPerformance(key, timer.elapsedMilliseconds);
    }
  }

  static void _logPerformance(String operation, int durationMs) {
    // Log vers service d'analytics
    analytics.logEvent(
      name: 'performance_metric',
      parameters: {
        'operation': operation,
        'duration_ms': durationMs,
      },
    );
  }
}
```

### Gestion des crashes
```dart
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log l'erreur
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  runZonedGuarded(() {
    runApp(const PiamApp());
  }, (error, stackTrace) {
    // Gestion des erreurs non gérées
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
```

## Évolutivité

### Architecture modulaire
- **Feature modules** : Chaque écran = module indépendant
- **Shared services** : Services communs réutilisables
- **Plugin architecture** : Extension via plugins

### Migration future
- **State management** : Migration possible vers BLoC/Provider
- **Backend** : API REST vers GraphQL
- **Offline-first** : Amélioration synchronisation

---

**Architecture Technique - Version 1.0**
*Application PIAM - Mars 2026*