import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();

  SQLiteService._internal();

  factory SQLiteService() => _instance;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'piam_controle_latrines.db');

    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
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
 createdAt TEXT NOT NULL,
 FOREIGN KEY(projectId) REFERENCES project(id)
);
''');
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
}
