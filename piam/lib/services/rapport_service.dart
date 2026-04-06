import 'dart:convert';
import 'database_service.dart';
import 'calcul_avancement_service.dart';

class RapportService {
  final DatabaseService _db = DatabaseService();

  DateTime? _parseDateFlexible(String? value) {
    if (value == null || value.trim().isEmpty || value == '-') return null;
    final raw = value.trim();

    final iso = DateTime.tryParse(raw);
    if (iso != null) {
      return iso;
    }

    final slash = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$').firstMatch(raw);
    if (slash != null) {
      final day = int.tryParse(slash.group(1)!);
      final month = int.tryParse(slash.group(2)!);
      final year = int.tryParse(slash.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  int _extractDurationDays(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0;
    final text = raw.toLowerCase();
    final match = RegExp(r'(\d+)').firstMatch(text);
    final number = int.tryParse(match?.group(1) ?? '0') ?? 0;
    if (number <= 0) {
      return 0;
    }

    if (text.contains('mois')) return number * 30;
    if (text.contains('semaine')) return number * 7;
    return number;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _toStringSafe(dynamic value, {String fallback = '-'}) {
    final str = value?.toString().trim();
    if (str == null || str.isEmpty) {
      return fallback;
    }
    return str;
  }

  bool _isYes(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'oui';
  }

  dynamic _findQuestionResponse(List<dynamic> list, String containsText) {
    for (final item in list) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final question = item['question']?.toString().toLowerCase() ?? '';
      if (question.contains(containsText.toLowerCase())) {
        return item['response'];
      }
    }
    return null;
  }

  /// Récupère les données consolidées pour le "Rapport de Suivi".
  Future<Map<String, dynamic>> genererRapportSuivi() async {
    final projects = await _db.query('project') ?? [];
    final List<Map<String, dynamic>> tableauAvancement = [];

    int sitesAvecPlanDechets = 0;
    int sitesAvecTriDechets = 0;
    int sitesAvecRegistre = 0;
    int accidentsTotal = 0;
    int plaintesTotal = 0;
    int ouvriersPresentsTotal = 0;
    int ouvriersEpiTotal = 0;

    for (var p in projects) {
      final projectId = p['id'];
      final projectName = p['name'];

      // Niveau 1 — données générales
      final donneesGenRow =
          (await _db.database.then(
            (db) => db.query(
              'donnees_generales',
              where: 'projectId = ?',
              whereArgs: [projectId],
              orderBy: 'id DESC',
              limit: 1,
            ),
          )) ??
          [];

      String typeLatrines = 'Semi-enterrée';
      int nbBlocs = 0;
      int nbCabines = 0;
      int nbBeneficiaires = 0;
      String autresTravaux = '';
      String typeSite = 'Autre';
      String codeSite = '-';
      String dateRemiseSite = '-';
      String delaiMarche = '-';
      int delaiMarcheJours = 0;

      if (donneesGenRow.isNotEmpty) {
        final row = donneesGenRow.first;
        typeLatrines =
            row['typeLatrinesArealiser']?.toString() ?? 'Semi-enterrée';
        nbBlocs = (row['nbBlocs'] as int?) ?? 0;
        nbCabines = (row['nbCabines'] as int?) ?? 0;
        nbBeneficiaires = _toInt(row['nbPotentiels']);
        autresTravaux = row['autresTravaux']?.toString() ?? '';
        dateRemiseSite = _toStringSafe(row['dateDemarrageMarche']);
        delaiMarche = _toStringSafe(row['delaiMarche']);
        delaiMarcheJours = _extractDurationDays(row['delaiMarche']?.toString());
        typeSite = _toStringSafe(
          row['infrastructureType'],
          fallback: _toStringSafe(row['etablissement'], fallback: 'Autre'),
        );
        codeSite = _toStringSafe(row['infrastructureCode']);
      }

      // Niveau 3 — calcul d'avancement
      final lvl3Row =
          (await _db.database.then(
            (db) => db.query(
              'controle_travaux',
              where: 'projectId = ? AND section = ?',
              whereArgs: [projectId, 'Niveau 3 Controle des travaux'],
              orderBy: 'id DESC',
              limit: 1,
            ),
          )) ??
          [];

      double avancement = 0.0;
      String dateDernierControle = '-';
      List<dynamic> sec13Avant = const [];
      List<dynamic> sec13Pendant = const [];
      List<dynamic> sec14 = const [];

      if (lvl3Row.isNotEmpty) {
        dateDernierControle = lvl3Row.first['checkedAt']?.toString() ?? '-';
        final detailsJson = lvl3Row.first['details']?.toString() ?? '{}';
        avancement = CalculAvancementService.calculerAvancement(
          detailsJson,
          typeLatrines,
        );
        try {
          final details = jsonDecode(detailsJson) as Map<String, dynamic>;
          sec13Avant =
              (details['section13']?['avant'] as List?)?.cast<dynamic>() ??
              const [];
          sec13Pendant =
              (details['section13']?['pendant'] as List?)?.cast<dynamic>() ??
              const [];
          sec14 = (details['section14'] as List?)?.cast<dynamic>() ?? const [];
        } catch (_) {}
      }

      // Niveau 4 — dates de réception
      String dtRecepTech = '-';
      String dtRecepProv = '-';

      final lvl4Row =
          (await _db.database.then(
            (db) => db.query(
              'controle_travaux',
              where: 'projectId = ? AND section = ?',
              whereArgs: [projectId, 'Niveau 4 Reception'],
              orderBy: 'id DESC',
              limit: 1,
            ),
          )) ??
          [];

      if (lvl4Row.isNotEmpty) {
        try {
          final details = lvl4Row.first['details']?.toString() ?? '{}';
          final Map<String, dynamic> lvl4Json = jsonDecode(details);
          dtRecepTech =
              (lvl4Json['reception_technique']?['date'] as String?) ?? '-';
          dtRecepProv =
              (lvl4Json['reception_provisoire']?['date'] as String?) ?? '-';
        } catch (_) {}
      }

      final startDate = _parseDateFlexible(dateRemiseSite);
      final endDate =
          _parseDateFlexible(dtRecepProv != '-' ? dtRecepProv : dtRecepTech) ??
          DateTime.now();
      final delaiConsommeJours = startDate == null
          ? 0
          : endDate.difference(startDate).inDays.clamp(0, 100000);
      final delaiConsommePct = delaiMarcheJours > 0
          ? ((delaiConsommeJours * 100) / delaiMarcheJours)
          : 0.0;
      final retardJours = delaiMarcheJours > 0
          ? (delaiConsommeJours - delaiMarcheJours).clamp(0, 100000)
          : 0;

      final planDechetsResp = _findQuestionResponse(
        sec13Avant,
        'plan de gestion des déchets',
      );
      final triDechetsResp = _findQuestionResponse(
        sec13Pendant,
        'déchets sont triés sur place',
      );
      final registreResp = _findQuestionResponse(
        sec13Pendant,
        'registre travailleurs complet et à jour',
      );
      final ouvriersPresentsResp = _findQuestionResponse(
        sec13Pendant,
        'ouvriers présents sur le chantier',
      );
      final ouvriersEpiResp = _findQuestionResponse(
        sec13Pendant,
        'ouvriers portant des EPI',
      );
      final accidentsResp = _findQuestionResponse(
        sec13Pendant,
        'accidents enregistrés',
      );
      final plaintesNuisanceResp = _findQuestionResponse(
        sec14,
        'plaintes enregistrées pour nuisance',
      );
      final plaintesVbgResp = _findQuestionResponse(
        sec14,
        'violences basées sur le genre',
      );

      if (_isYes(planDechetsResp)) sitesAvecPlanDechets++;
      if (_isYes(triDechetsResp)) sitesAvecTriDechets++;
      if (_isYes(registreResp)) sitesAvecRegistre++;

      accidentsTotal += _toInt(accidentsResp);
      plaintesTotal += _toInt(plaintesNuisanceResp) + _toInt(plaintesVbgResp);
      ouvriersPresentsTotal += _toInt(ouvriersPresentsResp);
      ouvriersEpiTotal += _toInt(ouvriersEpiResp);

      tableauAvancement.add({
        'nomSite': projectName,
        'typeSite': typeSite,
        'codeSite': codeSite,
        'nbBeneficiaires': nbBeneficiaires,
        'nbBlocs': nbBlocs,
        'nbCabines': nbCabines,
        'autre': autresTravaux,
        'dateRemiseSite': dateRemiseSite,
        'dateDernierControle': dateDernierControle,
        'avancement': avancement,
        'delaiMarche': delaiMarche,
        'delaiMarcheJours': delaiMarcheJours,
        'delaiConsommeJours': delaiConsommeJours,
        'delaiConsommePct': double.parse(delaiConsommePct.toStringAsFixed(1)),
        'retardJours': retardJours,
        'dtRecepTech': dtRecepTech,
        'dtRecepProv': dtRecepProv,
      });
    }

    if (tableauAvancement.isEmpty) {
      final db = await _db.database;
      final rows = await db.rawQuery('''
        SELECT
          i.intitule_infra_publ AS nomSite,
          i.infra_publ AS typeSite,
          i.code_infra_publ AS codeSite
        FROM infrastructures_ref i
        ORDER BY i.intitule_infra_publ ASC
      ''');

      for (final row in rows) {
        tableauAvancement.add({
          'nomSite': row['nomSite']?.toString() ?? '-',
          'typeSite': row['typeSite']?.toString() ?? 'Autre',
          'codeSite': row['codeSite']?.toString() ?? '-',
          'nbBlocs': 0,
          'nbCabines': 0,
          'nbBeneficiaires': 0,
          'autre': row['typeSite']?.toString() ?? '',
          'dateRemiseSite': '-',
          'dateDernierControle': '-',
          'avancement': 0.0,
          'delaiMarche': '-',
          'delaiMarcheJours': 0,
          'delaiConsommeJours': 0,
          'delaiConsommePct': 0.0,
          'retardJours': 0,
          'dtRecepTech': '-',
          'dtRecepProv': '-',
        });
      }
    }

    final db = await _db.database;
    final syntheseParTypeRows = await db.rawQuery('''
      SELECT
        COALESCE(TRIM(infra_publ), 'Autre') AS typeSite,
        COUNT(*) AS nbSites
      FROM infrastructures_ref
      GROUP BY COALESCE(TRIM(infra_publ), 'Autre')
      ORDER BY nbSites DESC
    ''');

    final Map<String, Map<String, dynamic>> synthese = {};
    for (final row in tableauAvancement) {
      final type = _toStringSafe(row['typeSite'], fallback: 'Autre');
      final entry = synthese.putIfAbsent(
        type,
        () => {'type': type, 'cible': 0, 'benef': 0, 'blocs': 0, 'cabines': 0},
      );
      entry['cible'] = (entry['cible'] as int) + 1;
      entry['benef'] = (entry['benef'] as int) + _toInt(row['nbBeneficiaires']);
      entry['blocs'] = (entry['blocs'] as int) + _toInt(row['nbBlocs']);
      entry['cabines'] = (entry['cabines'] as int) + _toInt(row['nbCabines']);
    }

    final totalSites = tableauAvancement.length;
    final pges = {
      'sitesPlanDechetsPct': totalSites > 0
          ? double.parse(
              ((sitesAvecPlanDechets * 100) / totalSites).toStringAsFixed(1),
            )
          : 0.0,
      'sitesTriDechetsPct': totalSites > 0
          ? double.parse(
              ((sitesAvecTriDechets * 100) / totalSites).toStringAsFixed(1),
            )
          : 0.0,
      'sitesRegistreTravailleursPct': totalSites > 0
          ? double.parse(
              ((sitesAvecRegistre * 100) / totalSites).toStringAsFixed(1),
            )
          : 0.0,
      'accidentsTotal': accidentsTotal,
      'plaintesTotal': plaintesTotal,
      'tauxEpiPct': ouvriersPresentsTotal > 0
          ? double.parse(
              ((ouvriersEpiTotal * 100) / ouvriersPresentsTotal)
                  .toStringAsFixed(1),
            )
          : 0.0,
    };

    return {
      'tableauAvancement': tableauAvancement,
      'syntheseParType': syntheseParTypeRows,
      'tableauSynthese': synthese.values.toList(),
      'pges': pges,
    };
  }
}
