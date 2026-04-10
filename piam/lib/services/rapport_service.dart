import 'dart:convert';
import 'database_service.dart';
import 'calcul_avancement_service.dart';

class RapportService {
  final DatabaseService _db = DatabaseService();

  dynamic _safeJsonDecode(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    try {
      return jsonDecode(source);
    } catch (e) {
      // Tente de récupérer de vieux formats ou logge l'erreur
      return null;
    }
  }

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
    final db = await _db.database;
    
    // Récupérer les infos globales du premier projet pour l'en-tête (cas simplifié)
    // Dans l'idéal, on filtrerait par marché.
    final List<Map<String, dynamic>> projects = await db.query('questionnaires', where: 'type = ?', whereArgs: ['identification']);
    Map<String, dynamic> headerInfo = {
      'intituleProjet': '-',
      'sourceFinancement': '-', // Champ à ajouter ou inférer
      'numeroMarche': '-',
      'nomEntreprise': '-',
      'delaiMarche': '-',
      'dateDemarrage': '-',
    };

    if (projects.isNotEmpty) {
      try {
        final firstProj = _safeJsonDecode(projects.first['data_json']) ?? {};
        headerInfo['intituleProjet'] = firstProj['intituleProjet'] ?? '-';
        headerInfo['numeroMarche'] = firstProj['numeroMarche'] ?? '-';
        headerInfo['nomEntreprise'] = firstProj['nomEntreprise'] ?? '-';
        headerInfo['delaiMarche'] = firstProj['delaiMarche']?.toString() ?? '-';
      } catch (e) {
        print('Error parsing header project: $e');
      }
    }

    final List<Map<String, dynamic>> tableauAvancement = [];

    // Indicateurs PGES cumulés
    int totalSites = 0;
    int sitesAvecPlanDechets = 0;
    int sitesDistancePuits = 0;
    int sitesSensibilisation = 0;
    int sitesSeanceInfo = 0;
    int totalEmployes = 0;
    int employesFormesSecours = 0;
    int employesLocaux = 0;
    int employesContrat = 0;
    int employesMasques = 0;
    int employesGants = 0;
    int employesChaussures = 0;
    int employesGiletCount = 0;

    int totalAccidents = 0;
    int sitesAvecAccident = 0;
    int totalPlaintesNuisance = 0;
    int sitesAvecPlainteNuisance = 0;
    int totalPlaintesVBG = 0;
    int sitesAvecPlainteVBG = 0;

    int sitesTrousseSecours = 0;
    int sitesEauPotable = 0;
    int totalOuvriersPresents = 0;
    int totalOuvriersMasques = 0;
    int totalOuvriersEPI = 0;
    int sitesPerimetreSecurite = 0;
    int sitesStockageProtege = 0;
    int sitesStockageBalise = 0;
    int sitesTriDechets = 0;
    int sitesBrulageDechets = 0;
    int sitesEvacuationReguliere = 0;
    int sitesEvacuationFin = 0;
    int sitesEtalementDeblais = 0;

    // Récupérer toutes les localités uniques ayant des données
    final List<Map<String, dynamic>> localites = await db.rawQuery('SELECT DISTINCT localite_id FROM questionnaires WHERE localite_id IS NOT NULL');

    for (var loc in localites) {
      try {
        final localiteId = loc['localite_id'];
        totalSites++;

        // Charger les différentes sections pour cette localité
        final identification = await _db.getQuestionnaire(type: 'identification', localiteId: localiteId) ?? {};
        
        // Récupérer le dernier check du Niveau 3
        final List<Map<String, dynamic>> lvl3History = await db.query(
          'questionnaires',
          where: 'type = ? AND localite_id = ?',
          whereArgs: ['controle_travaux', localiteId],
          orderBy: 'date_modification DESC',
          limit: 1
        );

        Map<String, dynamic> lastLvl3 = {};
        if (lvl3History.isNotEmpty) {
          lastLvl3 = _safeJsonDecode(lvl3History.first['data_json']) ?? {};
        }

        final projectName = identification['projectName'] ?? identification['intituleProjet'] ?? 'Site $localiteId';
        final typeLatrines = identification['typeLatrines'] ?? 'Semi-enterrée';
        final typeSite = identification['typeSite'] ?? 'Autre';
        final nbBeneficiaires = _toInt(identification['nbBeneficiaires']);
        final nbBlocs = _toInt(identification['nbBlocs']);
        final nbCabines = _toInt(identification['nbCabines']);
        final nbCabinesRehabilitees = _toInt(identification['nbCabinesRehabilitees']);
        
        // Avancement
        final avancement = CalculAvancementService.calculerAvancement(jsonEncode(lastLvl3), typeLatrines);

        // Section B - PGES (Avant les travaux)
        final sec13Avant = (lastLvl3['section13']?['avant'] as List?) ?? [];
        if (_isYes(_findQuestionResponse(sec13Avant, 'plan de gestion des déchets'))) sitesAvecPlanDechets++;
        if (_isYes(_findQuestionResponse(sec13Avant, 'distance d’au moins 30 m'))) sitesDistancePuits++;
        if (_isYes(_findQuestionResponse(sec13Avant, 'sensibilisation des ouvriers'))) sitesSensibilisation++;
        if (_isYes(_findQuestionResponse(sec13Avant, 'séance d’information avant le démarrage'))) sitesSeanceInfo++;

        // Section B - PGES (Pendant les travaux)
        final sec13Pendant = (lastLvl3['section13']?['pendant'] as List?) ?? [];
        if (_isYes(_findQuestionResponse(sec13Pendant, 'Trousse de premier secours'))) sitesTrousseSecours++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'Eau potable disponible'))) sitesEauPotable++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'périmètre de sécurité'))) sitesPerimetreSecurite++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'Zone de stockage des matériaux protégée'))) sitesStockageProtege++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'Stockage des déchets de chantier dans une zone balisée'))) sitesStockageBalise++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'déchets sont triés sur place'))) sitesTriDechets++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'Constat de brulage des déchets'))) sitesBrulageDechets++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'déchets sont évacués régulièrement'))) sitesEvacuationReguliere++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'Aucun déchet n’est abandonné'))) sitesEvacuationFin++;
        if (_isYes(_findQuestionResponse(sec13Pendant, 'Etalement des déblais'))) sitesEtalementDeblais++;

        // Cumuls
        final accidentsCount = _toInt(_findQuestionResponse(sec13Pendant, 'accidents enregistrés'));
        totalAccidents += accidentsCount;
        if (accidentsCount > 0) sitesAvecAccident++;

        final sec14 = (lastLvl3['section14'] as List?) ?? [];
        final plaintesNuisance = _toInt(_findQuestionResponse(sec14, 'nuisance du chantier'));
        totalPlaintesNuisance += plaintesNuisance;
        if (plaintesNuisance > 0) sitesAvecPlainteNuisance++;

        final plaintesVBG = _toInt(_findQuestionResponse(sec14, 'violences basées sur le genre'));
        totalPlaintesVBG += plaintesVBG;
        if (plaintesVBG > 0) sitesAvecPlainteVBG++;

        final ouvriersPresent = _toInt(_findQuestionResponse(sec13Pendant, 'ouvriers présents'));
        totalOuvriersPresents += ouvriersPresent;
        totalOuvriersMasques += _toInt(_findQuestionResponse(sec13Pendant, 'ouvriers portant des masques'));
        totalOuvriersEPI += _toInt(_findQuestionResponse(sec13Pendant, 'ouvriers portant des EPI'));

        // Chargement Niveau 4 (Réception)
        final reception = await _db.getQuestionnaire(type: 'reception', localiteId: localiteId) ?? {};
        final dtRecepTech = reception['reception_technique']?['date'] ?? '-';
        final dtRecepProv = reception['reception_provisoire']?['date'] ?? '-';

        tableauAvancement.add({
          'localiteId': localiteId,
          'nomSite': projectName,
          'typeSite': typeSite,
          'nbBeneficiaires': nbBeneficiaires,
          'nbBlocs': nbBlocs,
          'nbCabines': nbCabines,
          'nbCabinesRehabilitees': nbCabinesRehabilitees,
          'avancement': avancement,
          'dtRecepTech': dtRecepTech,
          'dtRecepProv': dtRecepProv,
        });
      } catch (e) {
        print('Error processing locality in report: $e');
        // Continue with next locality
      }
    }

    // Agrégation pour synthèse par type
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
      'pges': {
        'sitesPlanDechetsPct': totalSites > 0 ? (sitesAvecPlanDechets / totalSites * 100) : 0.0,
        'sitesDistancePuitsPct': totalSites > 0 ? (sitesDistancePuits / totalSites * 100) : 0.0,
        'sitesSensibilisationPct': totalSites > 0 ? (sitesSensibilisation / totalSites * 100) : 0.0,
        'sitesSeanceInfoPct': totalSites > 0 ? (sitesSeanceInfo / totalSites * 100) : 0.0,
        'accidentsTotal': totalAccidents,
        'sitesAvecAccidentPct': totalSites > 0 ? (sitesAvecAccident / totalSites * 100) : 0.0,
        'plaintesNuisanceTotal': totalPlaintesNuisance,
        'sitesAvecPlainteNuisancePct': totalSites > 0 ? (sitesAvecPlainteNuisance / totalSites * 100) : 0.0,
        'plaintesVBGTotal': totalPlaintesVBG,
        'sitesAvecPlainteVBGPct': totalSites > 0 ? (sitesAvecPlainteVBG / totalSites * 100) : 0.0,
        'tauxMasquesPct': totalOuvriersPresents > 0 ? (totalOuvriersMasques / totalOuvriersPresents * 100) : 0.0,
        'tauxEPIPct': totalOuvriersPresents > 0 ? (totalOuvriersEPI / totalOuvriersPresents * 100) : 0.0,
        // ... etc pour tous les champs
      }
    };
  }

  Future<Map<String, dynamic>> genererFicheSynthese(int localiteId) async {
    final db = await _db.database;
    
    // Identification
    final identification = await _db.getQuestionnaire(type: 'identification', localiteId: localiteId) ?? {};
    
    // Dernier Suivi (Niveau 3)
    final List<Map<String, dynamic>> lvl3History = await db.query(
      'questionnaires',
      where: 'type = ? AND localite_id = ?',
      whereArgs: ['controle_travaux', localiteId],
      orderBy: 'date_modification DESC'
    );
    
    Map<String, dynamic> lastLvl3 = {};
    int cumulAccidents = 0;
    int cumulPlaintesNuisance = 0;
    int cumulPlaintesVBG = 0;

    for (var row in lvl3History) {
      final data = jsonDecode(row['data_json']);
      if (lastLvl3.isEmpty) lastLvl3 = data;
      
      final sec13P = (data['section13']?['pendant'] as List?) ?? [];
      cumulAccidents += _toInt(_findQuestionResponse(sec13P, 'accidents enregistrés'));
      
      final sec14 = (data['section14'] as List?) ?? [];
      cumulPlaintesNuisance += _toInt(_findQuestionResponse(sec14, 'nuisance du chantier'));
      cumulPlaintesVBG += _toInt(_findQuestionResponse(sec14, 'violences basées sur le genre'));
    }

    final typeLatrines = identification['typeLatrines'] ?? 'Semi-enterrée';
    final avancement = CalculAvancementService.calculerAvancement(jsonEncode(lastLvl3), typeLatrines);

    return {
      'identification': identification,
      'lastLvl3': lastLvl3,
      'avancement': avancement,
      'cumuls': {
        'accidents': cumulAccidents,
        'plaintesNuisance': cumulPlaintesNuisance,
        'plaintesVBG': cumulPlaintesVBG,
      }
    };
  }
}
