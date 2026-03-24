# 👨‍💻 Guide Développeur - Application PIAM

## Table des matières
1. [Architecture technique](#architecture)
2. [Structure du projet](#structure)
3. [Modèles de données](#modeles)
4. [Services](#services)
5. [Interfaces utilisateur](#ui)
6. [Tests](#tests)
7. [Déploiement](#deploiement)
8. [Contribution](#contribution)

## Architecture technique

### Pattern architectural
L'application suit une architecture **Clean Architecture** simplifiée avec séparation des responsabilités :

```
📱 UI Layer (Screens)
    ↕️
🎯 Business Logic (Services)
    ↕️
💾 Data Layer (Models + SQLite)
```

### Technologies
- **Framework** : Flutter 3.35.3
- **Language** : Dart 3.9.2
- **Database** : SQLite (sqflite)
- **Storage** : Hive (NoSQL), Secure Storage
- **GPS** : Geolocator
- **Connectivity** : Connectivity Plus

## Structure du projet

### Arborescence détaillée
```
piam/
├── android/                    # Configuration Android
├── ios/                       # Configuration iOS
├── lib/                       # Code source principal
│   ├── main.dart             # Point d'entrée
│   ├── screens/              # Interfaces utilisateur
│   │   ├── login_screen.dart
│   │   ├── parametrage_screen.dart
│   │   ├── niveau1_donnees_generales.dart
│   │   ├── niveau2_organisation_chantier.dart
│   │   └── niveau3_controle_travaux.dart
│   ├── models/               # Modèles de données
│   │   ├── chantier.dart
│   │   ├── controle_travaux.dart
│   │   └── photo_gps.dart
│   ├── services/             # Logique métier
│   │   ├── sqlite_service.dart
│   │   ├── gps_service.dart
│   │   └── sync_service.dart
│   └── test/
│       └── widget_test.dart
├── pubspec.yaml              # Dépendances
├── README.md                 # Documentation
└── GUIDE_UTILISATEUR.md      # Guide utilisateur
```

## Modèles de données

### Chantier Model
```dart
class Chantier {
  final int? id;
  final String nomProjet;
  final String localisation;
  final String typeOuvrage;
  final DateTime dateDebut;
  final Map<String, dynamic> caracteristiques;

  Chantier({
    this.id,
    required this.nomProjet,
    required this.localisation,
    required this.typeOuvrage,
    required this.dateDebut,
    required this.caracteristiques,
  });

  // Méthodes fromJson/toJson
  factory Chantier.fromJson(Map<String, dynamic> json) => Chantier(...);
  Map<String, dynamic> toJson() => {...};
}
```

### Structure des données de contrôle
Chaque niveau stocke un JSON structuré :

```json
{
  "projectId": 1,
  "section": "Niveau 3 Controle des travaux",
  "status": 1,
  "checkedAt": "2026-03-24T10:30:00.000Z",
  "details": {
    "section1": {"acheve": true, "enCours": false},
    "section2": {
      "dateImplantation": "2026-03-20",
      "gpsX": "5.3456",
      "gpsY": "-4.1234",
      "fouillesConformes": true
    },
    "section3": {
      "apriori": [...],
      "aposteriori": [...]
    }
  }
}
```

## Services

### SQLiteService
Gestion de la base de données locale :

```dart
class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  Database? _db;

  // Singleton pattern
  factory SQLiteService() => _instance;

  // Initialisation
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Création des tables
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'piam.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }
}
```

### GPSService
Service de géolocalisation :

```dart
class GPSService {
  static Future<bool> requestPermission() async {
    // Vérification et demande de permission
  }

  static Future<Position> getLastPosition() async {
    if (!await requestPermission()) {
      throw Exception('Permission GPS non accordée');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
```

### SyncService
Gestion de la synchronisation :

```dart
class SyncService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void start() {
    _sub = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> statusList) {
        if (statusList.any((status) => status != ConnectivityResult.none)) {
          // Synchronisation des données
          _syncPendingData();
        }
      }
    );
  }

  Future<void> _syncPendingData() async {
    // Logique de synchronisation
  }
}
```

## Interfaces utilisateur

### Structure d'un écran
Chaque écran suit le pattern :

```dart
class ExampleScreen extends StatefulWidget {
  static const String routeName = '/example';

  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final SQLiteService _dbService = SQLiteService();

  // Variables d'état
  bool _isLoading = false;
  Map<String, dynamic> _data = {};

  // Méthodes
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Chargement des données
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    // Sauvegarde des données
    await _dbService.insert('table', _data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Titre')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Widgets de formulaire
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveData,
        child: const Icon(Icons.save),
      ),
    );
  }
}
```

### Composants réutilisables

#### Dropdown personnalisé
```dart
Widget _buildYesNoDropdown(Map<String, dynamic> item) {
  final options = (item['choices'] as List<String>?) ?? ['Oui', 'Non'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(item['question'], style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      DropdownButtonFormField<String>(
        initialValue: item['response'],
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => item['response'] = v ?? item['response']),
      ),
      TextFormField(
        initialValue: item['remark'],
        decoration: const InputDecoration(labelText: 'Remarque'),
        onChanged: (v) => setState(() => item['remark'] = v),
      ),
    ],
  );
}
```

#### Section expansible
```dart
Card(
  child: ExpansionTile(
    title: const Text('Titre de la section'),
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Contenu de la section
          ],
        ),
      ),
    ],
  ),
)
```

## Tests

### Structure des tests
```dart
void main() {
  group('SQLiteService', () {
    late SQLiteService service;

    setUp(() {
      service = SQLiteService();
    });

    test('should insert data correctly', () async {
      final data = {'key': 'value'};
      final result = await service.insert('test_table', data);
      expect(result, greaterThan(0));
    });
  });
}
```

### Tests d'intégration
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('end-to-end test', (tester) async {
    await tester.pumpWidget(const PiamApp());

    // Simulation des interactions utilisateur
    await tester.enterText(find.byType(TextField).first, 'testuser');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Vérifications
    expect(find.text('Paramétrage'), findsOneWidget);
  });
}
```

## Déploiement

### Build Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release --split-per-abi

# Bundle
flutter build appbundle
```

### Build iOS
```bash
# Pour iOS (sur macOS)
flutter build ios --release
```

### Configuration de build
```yaml
# pubspec.yaml
version: 1.0.0+1

environment:
  sdk: ^3.9.2
  flutter: ^3.35.3
```

### Signing Android
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            storeFile file('path/to/keystore.jks')
            storePassword 'store_password'
            keyAlias 'key_alias'
            keyPassword 'key_password'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Contribution

### Workflow Git
```bash
# Créer une branche feature
git checkout -b feature/nouvelle-fonctionnalite

# Commits atomiques
git commit -m "feat: ajouter validation GPS"

# Push et PR
git push origin feature/nouvelle-fonctionnalite
```

### Standards de code

#### Naming conventions
```dart
// Classes
class UserProfile extends StatefulWidget

// Variables privées
String _userName;
final List<String> _items = [];

// Constantes
const String kApiBaseUrl = 'https://api.piam.org';

// Méthodes
void _loadUserData() async
Future<User> fetchUser(int id) async
```

#### Structure des fichiers
```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:piam/services/sqlite_service.dart';

// 2. Constantes
const double kDefaultPadding = 16.0;

// 3. Classe principale
class ExampleScreen extends StatefulWidget {
  // 4. Constructeur
  const ExampleScreen({super.key});

  // 5. State
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

// 6. State class
class _ExampleScreenState extends State<ExampleScreen> {
  // 7. Variables d'instance
  late String _data;

  // 8. Lifecycle methods
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // 9. Private methods
  void _initialize() {
    // Logique d'initialisation
  }

  // 10. Public methods
  void updateData(String newData) {
    setState(() => _data = newData);
  }

  // 11. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UI
    );
  }
}
```

### Code review checklist
- [ ] Tests unitaires présents
- [ ] Analyse statique sans erreur (`flutter analyze`)
- [ ] Formatage du code (`flutter format`)
- [ ] Documentation des méthodes complexes
- [ ] Gestion d'erreur appropriée
- [ ] Performance optimisée
- [ ] Accessibilité respectée

### Gestion des erreurs
```dart
try {
  final result = await apiService.fetchData();
  // Traitement du succès
} on SocketException catch (e) {
  // Erreur réseau
  _showErrorDialog('Problème de connexion');
} on TimeoutException catch (e) {
  // Timeout
  _showErrorDialog('Délai d\'attente dépassé');
} catch (e) {
  // Erreur générique
  _showErrorDialog('Une erreur est survenue');
}
```

## Performance

### Optimisations
- **Lazy loading** : Chargement à la demande
- **Caching** : Cache des données fréquemment utilisées
- **Debouncing** : Éviter les appels répétés
- **Memory management** : Libération des ressources

### Monitoring
```dart
// Performance monitoring
import 'dart:developer';

void _measurePerformance(String operation, Function() action) {
  final stopwatch = Stopwatch()..start();
  action();
  stopwatch.stop();
  log('$operation took ${stopwatch.elapsedMilliseconds}ms');
}
```

## Sécurité

### Stockage sécurisé
```dart
// Utilisation de flutter_secure_storage
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: token);
final token = await storage.read(key: 'token');
```

### Validation des données
```dart
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email requis';
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) {
    return 'Email invalide';
  }
  return null;
}
```

---

**Guide Développeur - Version 1.0**
*Application PIAM - Mars 2026*