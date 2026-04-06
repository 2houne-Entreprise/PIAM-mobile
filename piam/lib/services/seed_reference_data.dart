import '../data/reference_data.dart';
import 'database_service.dart';

/// Utilitaire pour remplir la base locale à partir des données Dart statiques.
Future<void> seedDatabaseFromReferenceData() async {
  final db = DatabaseService();

  // Wilayas
  for (final wilaya in ReferenceData.wilayas) {
    await db.insertWilaya({
      'id': wilaya['id'],
      'nom': wilaya['intitule_fr'] ?? wilaya['intitule'],
      'code': wilaya['code'],
    });
  }

  // Moughataas
  for (final moughataa in ReferenceData.moughatas) {
    await db.insertMoughataa({
      'id': moughataa['id'],
      'nom': moughataa['intitule_fr'] ?? moughataa['intitule'],
      'code': moughataa['code'],
      'wilaya_id': moughataa['wilaya_id'],
    });
  }

  // Communes
  for (final commune in ReferenceData.communes) {
    // Correction : toujours utiliser la clé 'moughataa_id' pour la base
    final moughataaId = commune['moughataa_id'] ?? commune['moughata_id'];
    await db.insertCommune({
      'id': commune['id'],
      'nom': commune['intitule_fr'] ?? commune['intitule'],
      'code': commune['code'],
      'moughataa_id': moughataaId,
      'wilaya_id': commune['wilaya_id'],
    });
  }
}

/// Supprime complètement la base locale (pour repartir sur une base propre)
Future<void> resetDatabase() async {
  final db = await DatabaseService().database;
  await db.delete('communes');
  await db.delete('moughataas');
  await db.delete('wilayas');
  // Optionnel : supprimer aussi les localites et parametre_utilisateur si besoin
  // await db.delete('localites');
  // await db.delete('parametre_utilisateur');
}
