import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/reference_data.dart';

class DatabaseService {
  /// Initialise toutes les tables administratives depuis les données statiques
  /// de la classe [ReferenceData] intégrées dans le code.
  /// C'est la méthode recommandée car elle ne dépend d'aucun fichier externe.
  Future<void> seedFromReferenceData() async {
    final db = await database;

    // Wilayas
    for (final item in ReferenceData.wilayas) {
      await db.insert('wilayas', {
        'id': item['id'],
        'nom': item['intitule_fr'] ?? item['intitule'],
        'code': item['code']?.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Moughataas
    for (final item in ReferenceData.moughatas) {
      await db.insert('moughataas', {
        'id': item['id'],
        'nom': item['intitule_fr'] ?? item['intitule'],
        'wilaya_id': item['wilaya_id'],
        'code': item['code']?.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Communes
    for (final item in ReferenceData.communes) {
      await db.insert('communes', {
        'id': item['id'],
        'nom': item['intitule_fr'] ?? item['intitule'],
        'moughataa_id': item['moughata_id'],
        'code': item['code']?.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Localités
    for (final item in ReferenceData.localites) {
      await db.insert('localites', {
        'id': item['id'],
        'nom': item['intitule_fr'] ?? item['intitule'],
        'commune_id': item['commune_id'],
        'moughataa_id': item['moughata_id'],
        'wilaya_id': item['wilaya_id'],
        'gps_lat': item['gps_lat'],
        'gps_lng': item['gps_lng'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Initialise les wilayas à partir d'un JSON (liste d'objets).
  Future<void> seedWilayas(String jsonData) async {
    final db = await database;
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      await db.insert('wilayas', {
        'id': item['id'],
        'nom': item['nom'],
        'code': item['code'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Initialise les moughataas à partir d'un JSON (liste d'objets).
  Future<void> seedMoughataas(String jsonData) async {
    final db = await database;
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      await db.insert('moughataas', {
        'id': item['id'],
        'nom': item['nom'],
        'wilaya_id': item['wilaya_id'],
        'code': item['code'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Initialise les communes à partir d'un JSON (liste d'objets).
  Future<void> seedCommunes(String jsonData) async {
    final db = await database;
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      await db.insert('communes', {
        'id': item['id'],
        'nom': item['nom'],
        'moughataa_id': item['moughataa_id'],
        'code': item['code'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Initialise les localités à partir d'un JSON (liste d'objets).
  Future<void> seedLocalites(String jsonData) async {
    final db = await database;
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      await db.insert('localites', {
        'id': item['id'],
        'nom': item['nom'],
        'commune_id': item['commune_id'],
        'gps_lat': item['latitude'],
        'gps_lng': item['longitude'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Obsolète, conservé pour compatibilité temporaire
  Future<void> seedWilayasMoughataasCommunes(String jsonData) async {
    // Si le JSON contient la clé 'wilayas', on utilise l'ancienne logique
    // Sinon on suppose que c'est juste la liste des wilayas
    final data = json.decode(jsonData);
    if (data is Map && data.containsKey('wilayas')) {
      final db = await database;
      for (final wilaya in data['wilayas']) {
        final wilayaId = await db.insert('wilayas', {
          'nom': wilaya['nom_fr'] ?? wilaya['nom'],
          'code': wilaya['code'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        // ... reste de l'ancienne logique si nécessaire ...
      }
    } else {
      await seedWilayas(jsonData);
    }
  }

  /// Helper statique pour charger le JSON depuis un asset Flutter (ex: assets/data/wilayas.json)
  static Future<String> loadWilayasJsonFromAsset(String assetPath) async {
    // Utilise rootBundle dans ton code Flutter pour charger le fichier
    // Exemple d'appel : await DatabaseService.loadWilayasJsonFromAsset('assets/data/wilayas.json');
    throw UnimplementedError(
      'À implémenter dans le code Flutter avec rootBundle.loadString',
    );
  }

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'piam.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migration : supprime et recrée les tables administratives
        // afin d'intégrer les nouvelles données de ReferenceData
        await db.execute('DROP TABLE IF EXISTS localites');
        await db.execute('DROP TABLE IF EXISTS communes');
        await db.execute('DROP TABLE IF EXISTS moughataas');
        await db.execute('DROP TABLE IF EXISTS wilayas');
        await db.execute('DROP TABLE IF EXISTS parametre_utilisateur');
        await db.execute('DROP TABLE IF EXISTS questionnaires');
        await _onCreate(db, newVersion);
      },
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    // --- Base administrative ---
    await db.execute('''CREATE TABLE wilayas (
      id INTEGER PRIMARY KEY,
      nom TEXT NOT NULL,
      code TEXT
    )''');
    await db.execute('''CREATE TABLE moughataas (
      id INTEGER PRIMARY KEY,
      nom TEXT NOT NULL,
      wilaya_id INTEGER,
      code TEXT,
      FOREIGN KEY(wilaya_id) REFERENCES wilayas(id)
    )''');
    await db.execute('''CREATE TABLE communes (
      id INTEGER PRIMARY KEY,
      nom TEXT NOT NULL,
      moughataa_id INTEGER,
      code TEXT,
      FOREIGN KEY(moughataa_id) REFERENCES moughataas(id)
    )''');
    await db.execute('''CREATE TABLE localites (
      id INTEGER PRIMARY KEY,
      nom TEXT NOT NULL,
      commune_id INTEGER,
      moughataa_id INTEGER,
      wilaya_id INTEGER,
      gps_lat REAL,
      gps_lng REAL,
      FOREIGN KEY(commune_id) REFERENCES communes(id),
      FOREIGN KEY(moughataa_id) REFERENCES moughataas(id),
      FOREIGN KEY(wilaya_id) REFERENCES wilayas(id)
    )''');
    // --- Base opérationnelle ---
    await db.execute('''CREATE TABLE parametre_utilisateur (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      wilaya_id INTEGER,
      moughataa_id INTEGER,
      commune_id INTEGER,
      localite_id INTEGER,
      gps_lat REAL,
      gps_lng REAL,
      date TEXT
    )''');
    await db.execute('''CREATE TABLE questionnaires (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      data_json TEXT NOT NULL,
      date TEXT,
      user_id TEXT,
      localite_id INTEGER,
      sync_status TEXT DEFAULT 'local',
      photo_path TEXT
    )''');
  }

  // Méthodes principales
  Future<int> insertWilaya(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'wilayas',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertMoughataa(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'moughataas',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertCommune(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'communes',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertLocalite(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'localites',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertParametreUtilisateur(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'parametre_utilisateur',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertQuestionnaire(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'questionnaires',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWilayas() async {
    final db = await database;
    return await db.query('wilayas');
  }

  Future<List<Map<String, dynamic>>> getMoughataas(int wilayaId) async {
    final db = await database;
    return await db.query(
      'moughataas',
      where: 'wilaya_id = ?',
      whereArgs: [wilayaId],
    );
  }

  Future<List<Map<String, dynamic>>> getCommunes(int moughataaId) async {
    final db = await database;
    return await db.query(
      'communes',
      where: 'moughataa_id = ?',
      whereArgs: [moughataaId],
    );
  }

  Future<List<Map<String, dynamic>>> getLocalites(int communeId) async {
    final db = await database;
    return await db.query(
      'localites',
      where: 'commune_id = ?',
      whereArgs: [communeId],
    );
  }

  Future<Map<String, dynamic>?> getParametreUtilisateur() async {
    final db = await database;
    final res = await db.query(
      'parametre_utilisateur',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getQuestionnaires({
    String? syncStatus,
  }) async {
    final db = await database;
    if (syncStatus != null) {
      return await db.query(
        'questionnaires',
        where: 'sync_status = ?',
        whereArgs: [syncStatus],
      );
    }
    return await db.query('questionnaires');
  }

  Future<int> updateQuestionnaireSyncStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'questionnaires',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('parametre_utilisateur');
    await db.delete('questionnaires');
  }

  Future<Object?> getInfrastructures(
    int localiteId, {
    List<String>? infrastructureTypes,
  }) async {
    return null;
  }

  Future<Object?> insert(String s, Map<String, String> projectData) async {
    return null;
  }

  Future<void> setCurrentProjectId(Object? projectId) async {}

  Future<Object?> query(String s) async {}
}
