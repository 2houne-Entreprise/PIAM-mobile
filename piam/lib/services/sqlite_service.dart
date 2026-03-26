import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/reference_data.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();

  SQLiteService._internal();

  factory SQLiteService() => _instance;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'piam_controle_latrines.db');

    _db = await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    await _ensureAppConfigTable(_db!);
    await _ensureReferenceDataSeeded(_db!);
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE project (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 name TEXT NOT NULL,
 company TEXT NOT NULL,
 wilaya TEXT,
 createdAt TEXT NOT NULL
);
''');
    await db.execute('''
CREATE TABLE chantier (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 projectId INTEGER NOT NULL,
 description TEXT,
 updatedAt TEXT NOT NULL,
 FOREIGN KEY(projectId) REFERENCES project(id)
);
''');
    await db.execute('''
CREATE TABLE controle_travaux (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 projectId INTEGER NOT NULL,
 section TEXT NOT NULL,
 status INTEGER NOT NULL,
 checkedAt TEXT NOT NULL,
 details TEXT,
 FOREIGN KEY(projectId) REFERENCES project(id)
);
''');
    await db.execute('''
CREATE TABLE photo_gps (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 projectId INTEGER NOT NULL,
 path TEXT NOT NULL,
 latitude REAL NOT NULL,
 longitude REAL NOT NULL,
 accuracy REAL NOT NULL,
 takenAt TEXT NOT NULL,
 FOREIGN KEY(projectId) REFERENCES project(id)
);
''');
    await db.execute('''
CREATE TABLE sync_queue (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 entityType TEXT NOT NULL,
 entityId INTEGER NOT NULL,
 status TEXT NOT NULL,
 createdAt TEXT NOT NULL
);
''');
    await _ensureAppConfigTable(db);
    await db.execute('''
CREATE TABLE personnel (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 projectId INTEGER NOT NULL,
 nom TEXT NOT NULL,
 fonction TEXT NOT NULL,
 dateArrivee TEXT,
 provenance TEXT,
 contratTravail TEXT,
 premiersSecours TEXT,
 masqueNb INTEGER,
 casque TEXT,
 gants TEXT,
 chaussures TEXT,
 gilet TEXT,
 remarque TEXT,
 createdAt TEXT NOT NULL,
 FOREIGN KEY(projectId) REFERENCES project(id)
);
''');
    await db.execute('''
CREATE TABLE equipement (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 projectId INTEGER NOT NULL,
 nom TEXT NOT NULL,
 etat TEXT,
 remarque TEXT,
 createdAt TEXT NOT NULL,
 FOREIGN KEY(projectId) REFERENCES project(id)
);
''');
    await db.execute('''
CREATE TABLE materiaux (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 projectId INTEGER NOT NULL,
 nom TEXT NOT NULL,
 quantite INTEGER,
 qualite TEXT,
 recommandation TEXT,
 createdAt TEXT NOT NULL,
 FOREIGN KEY(projectId) REFERENCES project(id)
);
''');

    await db.execute('''
CREATE TABLE donnees_generales (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 projectId INTEGER NOT NULL,
 wilayaId INTEGER,
 moughataaId INTEGER,
 communeId INTEGER,
 localiteId INTEGER,
 codeAnsade TEXT,
 etablissement TEXT,
 infrastructureId INTEGER,
 infrastructureType TEXT,
 infrastructureCode TEXT,
 intituleProjet TEXT,
 marcheTravaux TEXT,
 numeroMarche TEXT,
 nomEntreprise TEXT,
 delaiMarche TEXT,
 dateDemarrageMarche TEXT,
 marcheControleTravaux TEXT,
 numeroMarcheControle TEXT,
 bureauControle TEXT,
 nomControleur TEXT,
 latrinesArealiser TEXT,
 typeLatrinesArealiser TEXT,
 toit TEXT,
 nbBlocs INTEGER,
 nbCabines INTEGER,
 nbDLM INTEGER,
 autresTravaux TEXT,
 autrePreciser TEXT,
 destructionAnciennes TEXT,
 constructionMur TEXT,
 codeMesre TEXT,
 codeMs TEXT,
 effectif INTEGER,
 nbPotentiels INTEGER,
 createdAt TEXT NOT NULL,
 FOREIGN KEY(projectId) REFERENCES project(id)
);
''');

    await _createReferenceTables(db);
    await _createReferenceIndexes(db);

    await _seedReferenceDataFromDart(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createReferenceTables(db);
      await _seedReferenceDataFromDart(db);
    }

    if (oldVersion < 3) {
      await _createReferenceTables(db);
      await _seedReferenceDataFromDart(db);
    }

    if (oldVersion < 4) {
      await _ensureDonneesGeneralesColumns(db);
    }

    if (oldVersion < 5) {
      await _createReferenceIndexes(db);
    }

    if (oldVersion < 6) {
      await _ensureDonneesGeneralesColumns(db);
    }

    if (oldVersion < 7) {
      await _createReferenceTables(db);
      await db.delete('wilayas');
      await db.delete('moughatas');
      await db.delete('communes_ref');
      await db.delete('localites_ref');
      await db.delete('infrastructures_ref');
      await _seedReferenceDataFromDart(db);
    }
  }

  Future<void> _ensureDonneesGeneralesColumns(Database db) async {
    await _addColumnIfMissing(db, 'donnees_generales', 'wilayaId', 'INTEGER');
    await _addColumnIfMissing(
      db,
      'donnees_generales',
      'moughataaId',
      'INTEGER',
    );
    await _addColumnIfMissing(db, 'donnees_generales', 'communeId', 'INTEGER');
    await _addColumnIfMissing(db, 'donnees_generales', 'localiteId', 'INTEGER');
    await _addColumnIfMissing(db, 'donnees_generales', 'codeAnsade', 'TEXT');
    await _addColumnIfMissing(db, 'donnees_generales', 'etablissement', 'TEXT');
    await _addColumnIfMissing(
      db,
      'donnees_generales',
      'infrastructureId',
      'INTEGER',
    );
    await _addColumnIfMissing(
      db,
      'donnees_generales',
      'infrastructureType',
      'TEXT',
    );
    await _addColumnIfMissing(
      db,
      'donnees_generales',
      'infrastructureCode',
      'TEXT',
    );
    await _addColumnIfMissing(db, 'donnees_generales', 'codeMesre', 'TEXT');
    await _addColumnIfMissing(db, 'donnees_generales', 'codeMs', 'TEXT');
    await _addColumnIfMissing(db, 'donnees_generales', 'effectif', 'INTEGER');
    await _addColumnIfMissing(
      db,
      'donnees_generales',
      'nbPotentiels',
      'INTEGER',
    );
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final cols = await db.rawQuery('PRAGMA table_info($table)');
    final exists = cols.any((c) => c['name']?.toString() == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<void> _createReferenceTables(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS wilayas (
 id INTEGER PRIMARY KEY,
 code INTEGER,
 intitule TEXT NOT NULL,
 intitule_fr TEXT
);
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS moughatas (
 id INTEGER PRIMARY KEY,
 code INTEGER,
 intitule TEXT NOT NULL,
 intitule_fr TEXT,
 wilaya_id INTEGER NOT NULL
);
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS communes_ref (
 id INTEGER PRIMARY KEY,
 code INTEGER,
 intitule TEXT NOT NULL,
 intitule_fr TEXT,
 moughata_id INTEGER NOT NULL,
 wilaya_id INTEGER NOT NULL
);
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS localites_ref (
 id INTEGER PRIMARY KEY,
 code INTEGER,
 intitule TEXT NOT NULL,
 intitule_fr TEXT,
 code_ansade TEXT,
 wilaya_id INTEGER NOT NULL,
 moughata_id INTEGER NOT NULL,
 commune_id INTEGER NOT NULL
);
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS infrastructures_ref (
 id INTEGER PRIMARY KEY,
 infra_publ TEXT,
 code_infra_publ TEXT,
 intitule_infra_publ TEXT NOT NULL,
 wilaya_id INTEGER NOT NULL,
 moughata_id INTEGER NOT NULL,
 commune_id INTEGER NOT NULL,
 localite_id INTEGER NOT NULL
);
''');
  }

  Future<void> _createReferenceIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_moughatas_wilaya_id ON moughatas(wilaya_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_communes_ref_moughata_id ON communes_ref(moughata_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_localites_ref_commune_id ON localites_ref(commune_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_localites_ref_code_ansade ON localites_ref(code_ansade)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_infrastructures_ref_localite_id ON infrastructures_ref(localite_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_infrastructures_ref_localite_type ON infrastructures_ref(localite_id, infra_publ)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_donnees_generales_geo ON donnees_generales(wilayaId, moughataaId, communeId, localiteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_donnees_generales_infra_id ON donnees_generales(infrastructureId)',
    );
  }

  Future<void> _ensureAppConfigTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS app_config (
 key TEXT PRIMARY KEY,
 value TEXT
);
''');
  }

  Future<void> _ensureReferenceDataSeeded(Database db) async {
    await _createReferenceTables(db);
    await _createReferenceIndexes(db);

    final wilayasCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM wilayas'),
        ) ??
        0;

    if (wilayasCount == 0) {
      await _seedReferenceDataFromDart(db);
    }
  }

  Future<void> _seedReferenceDataFromDart(Database db) async {
    await db.transaction((txn) async {
      for (final row in ReferenceData.wilayas) {
        await txn.insert(
          'wilayas',
          Map<String, dynamic>.from(row),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    await db.transaction((txn) async {
      for (final row in ReferenceData.moughatas) {
        await txn.insert(
          'moughatas',
          Map<String, dynamic>.from(row),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    await db.transaction((txn) async {
      for (final row in ReferenceData.communes) {
        await txn.insert(
          'communes_ref',
          Map<String, dynamic>.from(row),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    await db.transaction((txn) async {
      for (final row in ReferenceData.localites) {
        await txn.insert(
          'localites_ref',
          Map<String, dynamic>.from(row),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    await db.transaction((txn) async {
      for (final row in ReferenceData.infrastructures) {
        await txn.insert(
          'infrastructures_ref',
          Map<String, dynamic>.from(row),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getWilayas() async {
    final db = await database;
    var rows = await db.query('wilayas', orderBy: 'intitule ASC');
    if (rows.isEmpty) {
      await _ensureReferenceDataSeeded(db);
      rows = await db.query('wilayas', orderBy: 'intitule ASC');
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> getMoughatas(int wilayaId) async {
    final db = await database;
    var rows = await db.query(
      'moughatas',
      where: 'wilaya_id = ?',
      whereArgs: [wilayaId],
      orderBy: 'intitule ASC',
    );
    if (rows.isEmpty) {
      await _ensureReferenceDataSeeded(db);
      rows = await db.query(
        'moughatas',
        where: 'wilaya_id = ?',
        whereArgs: [wilayaId],
        orderBy: 'intitule ASC',
      );
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> getCommunes(int moughataId) async {
    final db = await database;
    var rows = await db.query(
      'communes_ref',
      where: 'moughata_id = ?',
      whereArgs: [moughataId],
      orderBy: 'intitule ASC',
    );
    if (rows.isEmpty) {
      await _ensureReferenceDataSeeded(db);
      rows = await db.query(
        'communes_ref',
        where: 'moughata_id = ?',
        whereArgs: [moughataId],
        orderBy: 'intitule ASC',
      );
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> getLocalites(int communeId) async {
    final db = await database;
    var rows = await db.query(
      'localites_ref',
      where: 'commune_id = ?',
      whereArgs: [communeId],
      orderBy: 'intitule ASC',
    );
    if (rows.isEmpty) {
      await _ensureReferenceDataSeeded(db);
      rows = await db.query(
        'localites_ref',
        where: 'commune_id = ?',
        whereArgs: [communeId],
        orderBy: 'intitule ASC',
      );
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> getInfrastructures(
    int localiteId, {
    List<String>? infrastructureTypes,
  }) async {
    final db = await database;
    if (infrastructureTypes == null || infrastructureTypes.isEmpty) {
      return db.query(
        'infrastructures_ref',
        where: 'localite_id = ?',
        whereArgs: [localiteId],
        orderBy: 'intitule_infra_publ ASC',
      );
    }

    final placeholders = List.filled(infrastructureTypes.length, '?').join(',');
    final args = <Object?>[
      localiteId,
      ...infrastructureTypes.map((e) => e.toUpperCase()),
    ];

    return db.query(
      'infrastructures_ref',
      where: 'localite_id = ? AND UPPER(TRIM(infra_publ)) IN ($placeholders)',
      whereArgs: args,
      orderBy: 'intitule_infra_publ ASC',
    );
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setConfigValue(String key, String value) async {
    final db = await database;
    await db.insert('app_config', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getConfigValue(String key) async {
    final db = await database;
    final rows = await db.query(
      'app_config',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value']?.toString();
  }

  Future<void> setCurrentProjectId(int projectId) async {
    await setConfigValue('currentProjectId', projectId.toString());
  }

  Future<int?> getCurrentProjectId() async {
    final value = await getConfigValue('currentProjectId');
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<int?> getLatestProjectId() async {
    final db = await database;
    final rows = await db.query(
      'project',
      columns: ['id'],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }
}
