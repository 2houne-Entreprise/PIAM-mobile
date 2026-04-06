import 'dart:convert';

class CalculAvancementService {
  // Grille pour Modèle Semi-enterré
  static const Map<String, double> _baremeSemiEnterre = {
    'sec1': 6.0, // Installation de chantier
    'sec2': 13.0, // Implantation et terrassement
    'sec3': 27.0, // Béton en fondation et maçonnerie en fondation
    'sec4': 13.0, // Béton et maçonnerie en élévation
    'sec5': 5.0, // Dalles de plancher (toit)
    'sec6': 10.0, // Enduits
    'sec7': 10.0, // Menuiserie
    'sec8': 3.0, // Plomberie
    'sec9': 3.0, // Peinture
    'sec10': 6.0, // Revêtement
    'sec11': 4.0, // DLM
    'sec12':
        0.0, // Garde-fous (non applicable pour semi-enterré ou = 0 selon tableau)
  };

  // Grille pour Modèle Hors-sol
  static const Map<String, double> _baremeHorsSol = {
    'sec1': 6.0, // Installation de chantier
    'sec2': 6.0, // Implantation et terrassement
    'sec3': 25.0, // Béton en fondation et maçonnerie en fondation
    'sec4': 13.0, // Béton et maçonnerie en élévation
    'sec5': 5.0, // Dalles de plancher (toit)
    'sec6': 11.0, // Enduits
    'sec7': 11.0, // Menuiserie
    'sec8': 5.0, // Plomberie
    'sec9': 3.0, // Peinture
    'sec10': 6.0, // Revêtement
    'sec11': 4.0, // DLM
    'sec12': 5.0, // Garde-fous (5%)
  };

  /// Calcule l'avancement global d'un projet en fonction du type de latrine
  /// et des données du JSON du 'Niveau 3'.
  static double calculerAvancement(
    String jsonControleTravaux,
    String typeLatrine,
  ) {
    if (jsonControleTravaux.isEmpty) {
      return 0.0;
    }

    final bareme = (typeLatrine == 'Semi-enterrée')
        ? _baremeSemiEnterre
        : _baremeHorsSol;
    double avancementTotal = 0.0;

    try {
      final Map<String, dynamic> donnees = jsonDecode(jsonControleTravaux);

      // Section 1 : Installation du chantier
      if (donnees['section1'] != null) {
        if (donnees['section1']['acheve'] == true) {
          avancementTotal += bareme['sec1']!;
        } else if (donnees['section1']['enCours'] == true) {
          avancementTotal +=
              bareme['sec1']! / 2; // Arbitrairement la moitié si en cours
        }
      }

      // Section 2 : Implantation
      if (donnees['section2'] != null) {
        if (donnees['section2']['fouillesConformes'] == true) {
          avancementTotal += bareme['sec2']!;
        }
      }

      // Pour les autres sections basées sur des listes de "A priori" / "A posteriori"
      // On considère la section complétée si les "A posteriori" sont tous à "Oui".
      avancementTotal += _verifierSectionListe(
        donnees['section3'],
        bareme['sec3']!,
      );
      avancementTotal += _verifierSectionListe(
        donnees['section4'],
        bareme['sec4']!,
      );
      avancementTotal += _verifierSectionListe(
        donnees['section5'],
        bareme['sec5']!,
      );

      // Section 6 : Enduits (juste une liste)
      avancementTotal += _verifierListeSimple(
        donnees['section6'],
        bareme['sec6']!,
      );

      // Section 7 : Menuiserie
      avancementTotal += _verifierSectionListe(
        donnees['section7'],
        bareme['sec7']!,
      );

      // Section 8 : Plomberie
      avancementTotal += _verifierSectionListe(
        donnees['section8'],
        bareme['sec8']!,
      );

      // Section 9 : Peinture (simple)
      avancementTotal += _verifierListeSimple(
        donnees['section9'],
        bareme['sec9']!,
      );

      // Section 10 : Revêtement (simple)
      avancementTotal += _verifierListeSimple(
        donnees['section10'],
        bareme['sec10']!,
      );

      // Section 11 : DLM
      avancementTotal += _verifierSectionListe(
        donnees['section11'],
        bareme['sec11']!,
      );

      // Section 12 : Garde-fous (simple)
      avancementTotal += _verifierListeSimple(
        donnees['section12'],
        bareme['sec12']!,
      );
    } catch (e) {
      print('Erreur calcul avancement: $e');
    }

    return num.parse(avancementTotal.toStringAsFixed(2)).toDouble();
  }

  static double _verifierSectionListe(
    Map<String, dynamic>? sectionData,
    double pointsMaximum,
  ) {
    if (sectionData == null || sectionData['aposteriori'] == null) {
      return 0.0;
    }

    List<dynamic> aposteriori = sectionData['aposteriori'];
    if (aposteriori.isEmpty) {
      return 0.0;
    }

    int totalQuestions = aposteriori.length;
    int reponsesPositives = 0;

    for (var q in aposteriori) {
      if (q['response'] == 'Oui' || q['response'] == true) {
        reponsesPositives++;
      }
    }

    // Calcul proportionnel ou total absolu (ici absolu: doit être tout à "Oui" sinon proportionnel)
    return (reponsesPositives / totalQuestions) * pointsMaximum;
  }

  static double _verifierListeSimple(
    List<dynamic>? sectionList,
    double pointsMaximum,
  ) {
    if (sectionList == null || sectionList.isEmpty) {
      return 0.0;
    }

    int totalQuestions = sectionList.length;
    int reponsesPositives = 0;

    for (var q in sectionList) {
      if (q['response'] == 'Oui' || q['response'] == true) {
        reponsesPositives++;
      }
    }
    return (reponsesPositives / totalQuestions) * pointsMaximum;
  }
}
