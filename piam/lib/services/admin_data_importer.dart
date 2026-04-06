import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class AdminDataImporter {
  final Database db;
  AdminDataImporter(this.db);

  Future<void> importAll() async {
    await _importWilayas();
    await _importMoughataa();
    await _importCommunes();
    await _importLocalites();
  }

  Future<void> _importWilayas() async {
    final data = await rootBundle.loadString('assets/data/wilayas.json');
    final List<dynamic> list = json.decode(data);
    for (final w in list) {
      await db.insert('wilayas', {
        'id': w['id'],
        'intitule': w['nom'],
        'intitule_fr': w['nom'],
        'code': w['id'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _importMoughataa() async {
    final data = await rootBundle.loadString('assets/data/moughataa.json');
    final List<dynamic> list = json.decode(data);
    for (final m in list) {
      await db.insert('moughatas', {
        'id': m['id'],
        'intitule': m['nom'],
        'intitule_fr': m['nom'],
        'wilaya_id': m['wilaya_id'],
        'code': m['id'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _importCommunes() async {
    final data = await rootBundle.loadString('assets/data/communes.json');
    final List<dynamic> list = json.decode(data);
    for (final c in list) {
      await db.insert('communes_ref', {
        'id': c['id'],
        'intitule': c['nom'],
        'intitule_fr': c['nom'],
        'moughata_id': c['moughataa_id'],
        'wilaya_id': null, // Peut être rempli si besoin
        'code': c['id'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _importLocalites() async {
    final data = await rootBundle.loadString('assets/data/localites.json');
    final List<dynamic> list = json.decode(data);
    for (final l in list) {
      await db.insert('localites_ref', {
        'id': l['id'],
        'intitule': l['nom'],
        'intitule_fr': l['nom'],
        'commune_id': l['commune_id'],
        'latitude': l['latitude'],
        'longitude': l['longitude'],
        'code': l['id'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
