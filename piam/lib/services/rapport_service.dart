import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'calcul_avancement_service.dart';
import 'questionnaire_api_service.dart';

class RapportService {
  final DatabaseService _db = DatabaseService();
  final QuestionnaireApiService _apiService = QuestionnaireApiService();

  dynamic _safeJsonDecode(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    try {
      return jsonDecode(source);
    } catch (e) {
      return null;
    }
  }

  DateTime? _parseDateFlexible(String? value) {
    if (value == null || value.trim().isEmpty || value == '-') return null;
    final raw = value.trim();

    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

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

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _isYes(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'oui';
  }

  dynamic _findQuestionResponse(List<dynamic> list, String containsText) {
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final question = item['question']?.toString().toLowerCase() ?? '';
      if (question.contains(containsText.toLowerCase())) {
        return item['response'];
      }
    }
    return null;
  }

  /// Récupère les données consolidées pour le "Rapport de Suivi".
  Future<Map<String, dynamic>> genererRapportSuivi() async {
    // --- FALLBACK SQLITE ---
    final db = await _db.database;
    
    // Identification globale (Header) - on prend les données du premier site qui a un Niveau 1 rempli
    final List<Map<String, dynamic>> n1Projects = await db.query(
      'questionnaires', 
      where: 'type = ?', 
      whereArgs: ['controle_travaux_n1'],
      limit: 1
    );
    
    Map<String, dynamic> headerInfo = {
      'intituleProjet': '-',
      'numeroMarche': '-',
      'nomEntreprise': '-',
      'delaiMarche': '-',
      'dateDemarrage': '-',
      'sourceFinancement': 'PIAM / Banque Mondiale',
    };

    if (n1Projects.isNotEmpty) {
      final data = _safeJsonDecode(n1Projects.first['data_json']) ?? {};
      headerInfo['intituleProjet'] = data['intituleProjet'] ?? data['projectName'] ?? '-';
      headerInfo['numeroMarche'] = data['numeroMarche'] ?? '-';
      headerInfo['nomEntreprise'] = data['nomEntrepriseMarche'] ?? data['companyName'] ?? '-';
      headerInfo['delaiMarche'] = data['delaiMarche']?.toString() ?? '-';
      headerInfo['dateDemarrage'] = data['dateDemarrageMarche'] ?? '-';
    }

    final List<Map<String, dynamic>> tableauAvancement = [];
    final List<Map<String, dynamic>> localites = await db.rawQuery(
      'SELECT DISTINCT localite_id FROM questionnaires WHERE localite_id IS NOT NULL'
    );

    // Stats PGES
    int totalSites = 0;
    int sitesPlanDechets = 0;
    int sitesDistancePuits = 0;
    int sitesSensibilisation = 0;
    int sitesPerimetreSecurite = 0;
    int sitesEauPotable = 0;
    double sommeTauxEPI = 0.0;
    int sitesAvecEPI = 0;
    int totalAccidents = 0;
    int totalPlaintesNuisance = 0;

    for (var loc in localites) {
      try {
        final localiteId = loc['localite_id'];
        
        // Données d'identification (Niveau 1)
        final n1 = await _db.getQuestionnaire(type: 'controle_travaux_n1', localiteId: localiteId) ?? {};
        
        // Données de suivi technique (Niveau 3)
        final n3 = await _db.getQuestionnaire(type: 'controle_travaux_n3', localiteId: localiteId) ?? {};

        final typeLatrines = n1['typeLatrines'] ?? 'Semi-enterrée';
        final avancement = CalculAvancementService.calculerAvancement(jsonEncode(n3), typeLatrines);

        final n4 = await _db.getQuestionnaire(type: 'controle_travaux_n4', localiteId: localiteId) ?? {};

        tableauAvancement.add({
          'localiteId': localiteId,
          'nomSite': n1['projectName'] ?? n1['intituleProjet'] ?? 'Site $localiteId',
          'typeSite': n1['typeSite'] ?? 'Autre',
          'nbBeneficiaires': _toInt(n1['nbBeneficiaires']),
          'nbBlocs': _toInt(n1['nbBlocs']),
          'nbCabines': _toInt(n1['nbCabines']),
          'nbCabinesRehabilitees': _toInt(n1['nbCabinesRehabilitees']),
          'avancement': avancement,
          'dtRecepTech': n4['reception_technique']?['date'] ?? '-',
          'dtRecepProv': n4['reception_provisoire']?['date'] ?? '-',
        });

        // --- Logique PGES ---
        totalSites++;
        final avant = (n3['section13']?['avant'] as List?) ?? [];
        final pendant = (n3['section13']?['pendant'] as List?) ?? [];
        final mgp = (n3['section14'] as List?) ?? [];

        if (_isYes(_findQuestionResponse(avant, 'plan de gestion des déchets'))) sitesPlanDechets++;
        if (_isYes(_findQuestionResponse(avant, 'distance d’au moins 30 m'))) sitesDistancePuits++;
        
        final nbSensibilises = _toInt(_findQuestionResponse(avant, 'Nb d’ouvriers sensibilisés'));
        if (nbSensibilises > 0) sitesSensibilisation++;

        if (_isYes(_findQuestionResponse(pendant, 'périmètre de sécurité'))) sitesPerimetreSecurite++;
        if (_isYes(_findQuestionResponse(pendant, 'Eau potable disponible'))) sitesEauPotable++;

        final nbPresents = _toInt(_findQuestionResponse(pendant, 'Nb d’ouvriers présents'));
        final nbEPI = _toInt(_findQuestionResponse(pendant, 'Nb d’ouvriers portant des EPI'));
        if (nbPresents > 0) {
          sommeTauxEPI += (nbEPI / nbPresents) * 100;
          sitesAvecEPI++;
        }

        totalAccidents += _toInt(_findQuestionResponse(pendant, 'accidents enregistrés'));
        totalPlaintesNuisance += _toInt(_findQuestionResponse(mgp, 'nuisance du chantier'));

      } catch (e) {
        debugPrint('Error processing locality in report: $e');
      }
    }

    final Map<String, dynamic> pgesStats = {
      'sitesPlanDechetsPct': totalSites > 0 ? (sitesPlanDechets / totalSites * 100) : 0.0,
      'sitesDistancePuitsPct': totalSites > 0 ? (sitesDistancePuits / totalSites * 100) : 0.0,
      'sitesSensibilisationPct': totalSites > 0 ? (sitesSensibilisation / totalSites * 100) : 0.0,
      'sitesPerimetreSecuritePct': totalSites > 0 ? (sitesPerimetreSecurite / totalSites * 100) : 0.0,
      'sitesEauPotablePct': totalSites > 0 ? (sitesEauPotable / totalSites * 100) : 0.0,
      'tauxEPIPct': sitesAvecEPI > 0 ? (sommeTauxEPI / sitesAvecEPI) : 0.0,
      'accidentsTotal': totalAccidents,
      'plaintesNuisanceTotal': totalPlaintesNuisance,
    };

    final Map<String, Map<String, dynamic>> synthese = {};
    for (final row in tableauAvancement) {
      final type = row['typeSite']?.toString() ?? 'Autre';
      final entry = synthese.putIfAbsent(
        type,
        () => {'type': type, 'cible': 0, 'benef': 0, 'blocs': 0, 'cabines': 0, 'rehabilitees': 0},
      );
      entry['cible'] = (entry['cible'] as int) + 1;
      entry['benef'] = (entry['benef'] as int) + _toInt(row['nbBeneficiaires']);
      entry['blocs'] = (entry['blocs'] as int) + _toInt(row['nbBlocs']);
      entry['cabines'] = (entry['cabines'] as int) + _toInt(row['nbCabines']);
      entry['rehabilitees'] = (entry['rehabilitees'] as int) + _toInt(row['nbCabinesRehabilitees']);
    }

    return {
      'header': headerInfo,
      'tableauAvancement': tableauAvancement,
      'tableauSynthese': synthese.values.toList(),
      'pges': pgesStats,
    };
  }

  /// Traite les données provenant de MySQL pour le rapport de suivi.
  Map<String, dynamic> _processMySqlDataToReport(Map<String, dynamic> apiData) {
    final List<dynamic> cts = apiData['controle_travaux'] ?? [];
    final List<dynamic> qs = apiData['questionnaires'] ?? [];
    final List<Map<String, dynamic>> tableauAvancement = [];
    final Map<int, Map<String, dynamic>> bySite = {};
    
    for (var q in qs) {
      final locId = q['localite_id'];
      if (locId == null) continue;
      final entry = bySite.putIfAbsent(locId, () => {'localite_id': locId});
      entry[q['type']] = _safeJsonDecode(q['data_json']) ?? {};
    }

    for (final locId in bySite.keys) {
      final siteData = bySite[locId]!;
      final iden = siteData['identification'] ?? {};
      final prog = siteData['programmation_travaux'] ?? {};
      final recep = siteData['reception'] ?? {};

      final typeLatrines = iden['typeLatrines'] ?? 'Semi-enterrée';
      final avancement = CalculAvancementService.calculerAvancement(jsonEncode(prog), typeLatrines);

      tableauAvancement.add({
        'localiteId': locId,
        'nomSite': iden['projectName'] ?? iden['intituleProjet'] ?? 'Site $locId',
        'typeSite': iden['typeSite'] ?? 'Autre',
        'nbBeneficiaires': _toInt(iden['nbBeneficiaires']),
        'nbBlocs': _toInt(iden['nbBlocs']),
        'nbCabines': _toInt(iden['nbCabines']),
        'nbCabinesRehabilitees': _toInt(iden['nbCabinesRehabilitees']),
        'avancement': avancement,
        'dtRecepTech': recep['reception_technique']?['date'] ?? '-',
        'dtRecepProv': recep['reception_provisoire']?['date'] ?? '-',
      });
    }

    Map<String, dynamic> headerInfo = {'intituleProjet': '-', 'numeroMarche': '-', 'nomEntreprise': '-', 'delaiMarche': '-', 'dateDemarrage': '-'};
    if (tableauAvancement.isNotEmpty) {
      final firstLocId = tableauAvancement.first['localiteId'];
      final firstIden = bySite[firstLocId]?['identification'] ?? {};
      headerInfo['intituleProjet'] = firstIden['intituleProjet'] ?? firstIden['projectName'] ?? '-';
      headerInfo['numeroMarche'] = firstIden['numeroMarche'] ?? '-';
      headerInfo['nomEntreprise'] = firstIden['nomEntreprise'] ?? '-';
      headerInfo['delaiMarche'] = firstIden['delaiMarche']?.toString() ?? '-';
    }

    final Map<String, Map<String, dynamic>> synthese = {};
    for (final row in tableauAvancement) {
      final type = row['typeSite']?.toString() ?? 'Autre';
      final entry = synthese.putIfAbsent(
        type,
        () => {'type': type, 'cible': 0, 'benef': 0, 'blocs': 0, 'cabines': 0, 'rehabilitees': 0},
      );
      entry['cible'] = (entry['cible'] as int) + 1;
      entry['benef'] = (entry['benef'] as int) + _toInt(row['nbBeneficiaires']);
      entry['blocs'] = (entry['blocs'] as int) + _toInt(row['nbBlocs']);
      entry['cabines'] = (entry['cabines'] as int) + _toInt(row['nbCabines']);
      entry['rehabilitees'] = (entry['rehabilitees'] as int) + _toInt(row['nbCabinesRehabilitees']);
    }

    return {
      'header': headerInfo,
      'tableauAvancement': tableauAvancement,
      'tableauSynthese': synthese.values.toList(),
      'pges': {},
    };
  }

  Future<Map<String, dynamic>> genererFicheSynthese(int localiteId) async {
    final db = await _db.database;
    
    // Identification (Niveau 1)
    final n1 = await _db.getQuestionnaire(type: 'controle_travaux_n1', localiteId: localiteId) ?? {};
    
    // Historique Niveau 3 pour les cumuls
    final List<Map<String, dynamic>> n3History = await db.query(
      'questionnaires',
      where: 'type = ? AND localite_id = ?',
      whereArgs: ['controle_travaux_n3', localiteId],
      orderBy: 'date_modification DESC'
    );
    
    Map<String, dynamic> lastN3 = {};
    int cumulAccidents = 0;
    int cumulPlaintesNuisance = 0;
    int cumulPlaintesVBG = 0;

    for (var row in n3History) {
      final data = jsonDecode(row['data_json']);
      if (lastN3.isEmpty) lastN3 = data;
      
      final pendant = (data['section13']?['pendant'] as List?) ?? [];
      cumulAccidents += _toInt(_findQuestionResponse(pendant, 'accidents enregistrés'));
      
      final mgp = (data['section14'] as List?) ?? [];
      cumulPlaintesNuisance += _toInt(_findQuestionResponse(mgp, 'nuisance du chantier'));
      cumulPlaintesVBG += _toInt(_findQuestionResponse(mgp, 'violences basées sur le genre'));
    }

    final typeLatrines = n1['typeLatrines'] ?? 'Semi-enterrée';
    final avancement = CalculAvancementService.calculerAvancement(jsonEncode(lastN3), typeLatrines);

    return {
      'identification': n1,
      'lastLvl3': lastN3,
      'avancement': avancement,
      'cumuls': {
        'accidents': cumulAccidents,
        'plaintesNuisance': cumulPlaintesNuisance,
        'plaintesVBG': cumulPlaintesVBG,
      }
    };
  }
}
