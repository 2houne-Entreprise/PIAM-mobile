import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/reference_data.dart';

/// Service principal d'accès à la base de données SQLite locale.
///
/// Utilise le pattern Singleton pour garantir une seule instance.
/// Toutes les méthodes sont async et retournent des [Future].
class DatabaseService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  // ── Persistance Web (Chrome) ──────────────────────────────────────────────
  static const String _keyParametrage = 'piam_parametrage';
  static const String _keyQuestionnaires = 'piam_questionnaires';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // ── Initialisation de la base ──────────────────────────────────────────────

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'piam.db');
    _db = await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Tables administratives (géo) ────────────────────────────────────────
    await db.execute('''
      CREATE TABLE wilayas (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL,
        code TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE moughataas (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL,
        wilaya_id INTEGER,
        code TEXT,
        FOREIGN KEY(wilaya_id) REFERENCES wilayas(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE communes (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL,
        moughataa_id INTEGER,
        code TEXT,
        FOREIGN KEY(moughataa_id) REFERENCES moughataas(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE localites (
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
      )
    ''');

    // ── Table de paramétrage utilisateur ────────────────────────────────────
    await db.execute('''
      CREATE TABLE parametre_utilisateur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wilaya_id INTEGER,
        moughataa_id INTEGER,
        commune_id INTEGER,
        localite_id INTEGER,
        gps_lat REAL,
        gps_lng REAL,
        date TEXT
      )
    ''');

    // ── Table des questionnaires (formulaires) ───────────────────────────────
    // IMPORTANT : data_json stocke du JSON valide (via jsonEncode, pas .toString())
    // La contrainte UNIQUE(type, localite_id) permet le upsert (un seul enregistrement
    // par formulaire et par localité).
    await db.execute('''
      CREATE TABLE questionnaires (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        data_json TEXT NOT NULL,
        date_creation TEXT,
        date_modification TEXT,
        user_id TEXT,
        localite_id INTEGER,
        sync_status TEXT DEFAULT 'local',
        status TEXT DEFAULT 'completed', -- 'draft', 'completed', 'synced'
        photo_path TEXT,
        UNIQUE(type, localite_id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Recrée toutes les tables proprement à chaque mise à jour de version
    for (final table in [
      'questionnaires',
      'parametre_utilisateur',
      'localites',
      'communes',
      'moughataas',
      'wilayas',
    ]) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }
    await _onCreate(db, newVersion);
  }

  // ── Seed des données de référence ─────────────────────────────────────────

  /// Peuple les tables administratives depuis les données statiques de [ReferenceData].
  Future<void> seedFromReferenceData() async {
    if (kIsWeb) return;
    final db = await database;

    for (final item in ReferenceData.wilayas) {
      await db.insert(
        'wilayas',
        {
          'id': item['id'],
          'nom': item['intitule_fr'] ?? item['intitule'],
          'code': item['code']?.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (final item in ReferenceData.moughatas) {
      await db.insert(
        'moughataas',
        {
          'id': item['id'],
          'nom': item['intitule_fr'] ?? item['intitule'],
          'wilaya_id': item['wilaya_id'],
          'code': item['code']?.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (final item in ReferenceData.communes) {
      await db.insert(
        'communes',
        {
          'id': item['id'],
          'nom': item['intitule_fr'] ?? item['intitule'],
          'moughataa_id': item['moughata_id'],
          'code': item['code']?.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (final item in ReferenceData.localites) {
      await db.insert(
        'localites',
        {
          'id': item['id'],
          'nom': item['intitule_fr'] ?? item['intitule'],
          'commune_id': item['commune_id'],
          'moughataa_id': item['moughata_id'],
          'wilaya_id': item['wilaya_id'],
          'gps_lat': item['gps_lat'],
          'gps_lng': item['gps_lng'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // ── Géo (lecture) ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getWilayas() async {
    if (kIsWeb) {
      return ReferenceData.wilayas.map((e) => <String, dynamic>{
        'id': e['id'],
        'nom': e['intitule_fr'] ?? e['intitule'],
        'code': e['code']?.toString(),
      }).toList()..sort((a, b) => (a['nom'] as String).compareTo(b['nom'] as String));
    }
    final db = await database;
    return db.query('wilayas', orderBy: 'nom');
  }

  Future<List<Map<String, dynamic>>> getMoughataas(int wilayaId) async {
    if (kIsWeb) {
      return ReferenceData.moughatas.where((e) => e['wilaya_id'] == wilayaId).map((e) => <String, dynamic>{
        'id': e['id'],
        'nom': e['intitule_fr'] ?? e['intitule'],
        'wilaya_id': e['wilaya_id'],
        'code': e['code']?.toString(),
      }).toList()..sort((a, b) => (a['nom'] as String).compareTo(b['nom'] as String));
    }
    final db = await database;
    return db.query(
      'moughataas',
      where: 'wilaya_id = ?',
      whereArgs: [wilayaId],
      orderBy: 'nom',
    );
  }

  Future<List<Map<String, dynamic>>> getCommunes(int moughataaId) async {
    if (kIsWeb) {
      return ReferenceData.communes.where((e) => e['moughata_id'] == moughataaId).map((e) => <String, dynamic>{
        'id': e['id'],
        'nom': e['intitule_fr'] ?? e['intitule'],
        'moughataa_id': e['moughata_id'],
        'code': e['code']?.toString(),
      }).toList()..sort((a, b) => (a['nom'] as String).compareTo(b['nom'] as String));
    }
    final db = await database;
    return db.query(
      'communes',
      where: 'moughataa_id = ?',
      whereArgs: [moughataaId],
      orderBy: 'nom',
    );
  }

  Future<List<Map<String, dynamic>>> getLocalites(int communeId) async {
    if (kIsWeb) {
      return ReferenceData.localites.where((e) => e['commune_id'] == communeId).map((e) => <String, dynamic>{
        'id': e['id'],
        'nom': e['intitule_fr'] ?? e['intitule'],
        'commune_id': e['commune_id'],
        'moughataa_id': e['moughata_id'],
        'wilaya_id': e['wilaya_id'],
        'gps_lat': e['gps_lat'],
        'gps_lng': e['gps_lng'],
      }).toList()..sort((a, b) => (a['nom'] as String).compareTo(b['nom'] as String));
    }
    final db = await database;
    return db.query(
      'localites',
      where: 'commune_id = ?',
      whereArgs: [communeId],
      orderBy: 'nom',
    );
  }

  // ── Géo (écriture) ────────────────────────────────────────────────────────

  Future<int> insertWilaya(Map<String, dynamic> data) async {
    if (kIsWeb) return 1;
    final db = await database;
    return db.insert('wilayas', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertMoughataa(Map<String, dynamic> data) async {
    if (kIsWeb) return 1;
    final db = await database;
    return db.insert('moughataas', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertCommune(Map<String, dynamic> data) async {
    if (kIsWeb) return 1;
    final db = await database;
    return db.insert('communes', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertLocalite(Map<String, dynamic> data) async {
    if (kIsWeb) return 1;
    final db = await database;
    return db.insert('localites', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Paramétrage utilisateur ───────────────────────────────────────────────

  Future<int> insertParametreUtilisateur(Map<String, dynamic> data) async {
    if (kIsWeb) {
      final p = await _prefs;
      await p.setString(_keyParametrage, jsonEncode(data));
      return 1;
    }
    final db = await database;
    return db.insert(
      'parametre_utilisateur',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getParametreUtilisateur() async {
    if (kIsWeb) {
      final p = await _prefs;
      final jsonStr = p.getString(_keyParametrage);
      if (jsonStr == null) return null;
      try {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final res = await db.query(
      'parametre_utilisateur',
      orderBy: 'id DESC',
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  // ── Questionnaires / Formulaires ──────────────────────────────────────────

  /// Sauvegarde (insère ou met à jour) un formulaire identifié par son [type]
  /// et sa [localiteId].
  ///
  /// C'est la méthode RECOMMANDÉE pour sauvegarder les formulaires.
  /// Elle garantit qu'il n'y a qu'une seule entrée par (type, localité).
  ///
  /// [type]      : ex. 'dernier_suivi_localite', 'etat_lieux_localite', etc.
  /// [localiteId]: l'id de la localité concernée
  /// [dataMap]   : Map<String, dynamic> des données du formulaire
  /// [status]    : 'draft', 'completed', 'synced'
  /// [userId]    : optionnel, identifiant de l'utilisateur
  Future<void> upsertQuestionnaire({
    required String type,
    required int? localiteId,
    required Map<String, dynamic> dataMap,
    String status = 'completed',
    dynamic userId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final dataJson = jsonEncode(dataMap);

    if (kIsWeb) {
      final p = await _prefs;
      final existingStr = p.getString(_keyQuestionnaires) ?? '[]';
      final List<dynamic> list = jsonDecode(existingStr);
      
      final idx = list.indexWhere(
        (q) => q['type'] == type && q['localite_id'] == localiteId,
      );

      // Pour le web, on génère un ID basé sur le timestamp s'il n'existe pas
      final existingId = idx >= 0 ? list[idx]['id'] : DateTime.now().millisecondsSinceEpoch;

      final entry = {
        'id': existingId,
        'type': type,
        'data_json': dataJson,
        'date_modification': now,
        'date_creation': idx >= 0 ? list[idx]['date_creation'] : now,
        'user_id': userId?.toString(),
        'localite_id': localiteId,
        'sync_status': status == 'synced' ? 'synced' : 'local',
        'status': status,
      };
      if (idx >= 0) {
        list[idx] = entry;
      } else {
        list.add(entry);
      }
      await p.setString(_keyQuestionnaires, jsonEncode(list));
      debugPrint('[DatabaseService] Web: Questionnaire "$type" sauvegardé (status: $status)');
      return;
    }

    final db = await database;

    final String whereClause = localiteId == null 
        ? 'type = ? AND localite_id IS NULL' 
        : 'type = ? AND localite_id = ?';
    final List<dynamic> whereArgs = [type];
    if (localiteId != null) whereArgs.add(localiteId);

    final existing = await db.query(
      'questionnaires',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (existing.isNotEmpty) {
      // Si on update un draft vers completed, ou si on continue un draft
      await db.update(
        'questionnaires',
        {
          'data_json': dataJson,
          'date_modification': now,
          'user_id': userId?.toString(),
          'status': status,
          'sync_status': status == 'synced' ? 'synced' : 'local',
        },
        where: whereClause,
        whereArgs: whereArgs,
      );
    } else {
      await db.insert('questionnaires', {
        'type': type,
        'data_json': dataJson,
        'date_creation': now,
        'date_modification': now,
        'user_id': userId?.toString(),
        'localite_id': localiteId,
        'status': status,
        'sync_status': status == 'synced' ? 'synced' : 'local',
      });
    }
  }

  /// Charge les données d'un formulaire depuis la base de données.
  ///
  /// Retourne la [Map] des données du formulaire, ou `null` si aucune
  /// donnée n'a été enregistrée pour ce couple (type, localité).
  ///
  /// [type]      : ex. 'dernier_suivi_localite'
  /// [localiteId]: l'id de la localité
  Future<Map<String, dynamic>?> getQuestionnaire({
    required String type,
    required int? localiteId,
    String? niveau,
  }) async {
    // ── INTERCEPTION HIVE (Drafts) ──────────────────────────────────────────
    try {
      if (Hive.isBoxOpen('form_drafts')) {
        final box = Hive.box('form_drafts');
        final key = type; // Clé simplifiée (type uniquement)
        
        final draftData = box.get(key);
        if (draftData != null) {
          // On a trouvé un brouillon récent dans Hive
          final Map<String, dynamic> hiveMap = Map<String, dynamic>.from(draftData);
          hiveMap['_status'] = 'draft';
          debugPrint('[DatabaseService] Chargement du draft depuis Hive pour $key');
          return hiveMap;
        }
      }
    } catch (e) {
      debugPrint('[DatabaseService] Erreur lors de la lecture depuis Hive : $e');
    }
    // ──────────────────────────────────────────────────────────────────────

    if (kIsWeb) {
      final p = await _prefs;
      final existingStr = p.getString(_keyQuestionnaires) ?? '[]';
      final List<dynamic> list = jsonDecode(existingStr);
      
      final match = list.where(
        (q) => q['type'] == type && q['localite_id'] == localiteId,
      );
      if (match.isEmpty) return null;
      final q = match.first as Map<String, dynamic>;
      final dataJson = q['data_json'] as String?;
      if (dataJson == null || dataJson.isEmpty) return null;
      try {
        final innerData = jsonDecode(dataJson) as Map<String, dynamic>;
        innerData['_status'] = q['status'];
        innerData['_id'] = q['id'];
        return innerData;
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    final String whereClause = localiteId == null 
        ? 'type = ? AND localite_id IS NULL' 
        : 'type = ? AND localite_id = ?';
    final List<dynamic> whereArgs = [type];
    if (localiteId != null) whereArgs.add(localiteId);

    final res = await db.query(
      'questionnaires',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date_modification DESC',
      limit: 1,
    );

    if (res.isEmpty) return null;

    final result = Map<String, dynamic>.from(res.first);
    final dataJson = result['data_json'] as String?;
    if (dataJson == null || dataJson.isEmpty) return null;

    try {
      final innerData = jsonDecode(dataJson) as Map<String, dynamic>;
      // Fusionner les métadonnées (statut, etc.) avec les données du formulaire si besoin
      innerData['_status'] = result['status'];
      innerData['_id'] = result['id'];
      return innerData;
    } catch (e) {
      return null;
    }
  }

  /// Retourne tous les questionnaires, avec filtre optionnel sur le statut sync.
  Future<List<Map<String, dynamic>>> getQuestionnaires({
    String? syncStatus,
    String? type,
  }) async {
    if (kIsWeb) {
      final p = await _prefs;
      final existingStr = p.getString(_keyQuestionnaires) ?? '[]';
      final List<dynamic> list = jsonDecode(existingStr);
      return list.map((e) => e as Map<String, dynamic>).where((q) {
        final matchStatus =
            syncStatus == null || q['sync_status'] == syncStatus;
        final matchType = type == null || q['type'] == type;
        return matchStatus && matchType;
      }).toList();
    }
    final db = await database;

    final conditions = <String>[];
    final args = <dynamic>[];
    if (syncStatus != null) {
      conditions.add('sync_status = ?');
      args.add(syncStatus);
    }
    if (type != null) {
      conditions.add('type = ?');
      args.add(type);
    }
    final where = conditions.isEmpty ? null : conditions.join(' AND ');

    return db.query(
      'questionnaires',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date_modification DESC',
    );
  }

  Future<int> updateQuestionnaireSyncStatus(int id, String status) async {
    if (kIsWeb) {
      final p = await _prefs;
      final existingStr = p.getString(_keyQuestionnaires) ?? '[]';
      final List<dynamic> list = jsonDecode(existingStr);
      for (var i = 0; i < list.length; i++) {
        if (list[i]['id'] == id) {
          list[i]['sync_status'] = status;
          await p.setString(_keyQuestionnaires, jsonEncode(list));
          return 1;
        }
      }
      return 0;
    }
    final db = await database;
    return db.update(
      'questionnaires',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Utilitaires ───────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    if (kIsWeb) {
      final p = await _prefs;
      await p.remove(_keyParametrage);
      await p.remove(_keyQuestionnaires);
      return;
    }
    final db = await database;
    await db.delete('parametre_utilisateur');
    await db.delete('questionnaires');
  }

  /// S'assure que le champ [data_json] d'une map est une chaîne JSON valide.
  /// Corrige le bug où .toString() était utilisé à la place de jsonEncode().
  Map<String, dynamic> _ensureJsonEncoded(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);
    if (result.containsKey('data_json') && result['data_json'] is Map) {
      result['data_json'] = jsonEncode(result['data_json']);
    }
    return result;
  }

  // ── Méthodes conservées pour compatibilité ────────────────────────────────

  Future<Object?> getInfrastructures(
    int localiteId, {
    List<String>? infrastructureTypes,
  }) async => null;

  Future<Object?> insert(String s, Map<String, dynamic> projectData) async =>
      null;

  Future<void> setCurrentProjectId(Object? projectId) async {}

  Future<Object?> query(String s) async {}

  // ── Seed (méthodes JSON) ──────────────────────────────────────────────────

  Future<void> seedWilayas(String jsonData) async {
    if (kIsWeb) return;
    final db = await database;
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      await db.insert(
        'wilayas',
        {
          'id': item['id'],
          'nom': item['nom'],
          'code': item['code'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> seedMoughataas(String jsonData) async {
    if (kIsWeb) return;
    final db = await database;
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      await db.insert(
        'moughataas',
        {
          'id': item['id'],
          'nom': item['nom'],
          'wilaya_id': item['wilaya_id'],
          'code': item['code'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> seedCommunes(String jsonData) async {
    if (kIsWeb) return;
    final db = await database;
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      await db.insert(
        'communes',
        {
          'id': item['id'],
          'nom': item['nom'],
          'moughataa_id': item['moughataa_id'],
          'code': item['code'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> seedLocalites(String jsonData) async {
    if (kIsWeb) return;
    final db = await database;
    final List<dynamic> data = json.decode(jsonData);
    for (final item in data) {
      await db.insert(
        'localites',
        {
          'id': item['id'],
          'nom': item['nom'],
          'commune_id': item['commune_id'],
          'gps_lat': item['latitude'],
          'gps_lng': item['longitude'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
