import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/database_service.dart';

class Niveau3ControleTravaux extends StatefulWidget {
  static const String routeName = '/niveau3';

  const Niveau3ControleTravaux({super.key});

  @override
  State<Niveau3ControleTravaux> createState() => _Niveau3ControleTravauxState();
}

class _Niveau3ControleTravauxState extends State<Niveau3ControleTravaux> {
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _sectionStatus = {
    'section1': 'En cours',
    'section2': 'En cours',
    'section3': 'En cours',
    'section4': 'En cours',
    'section5': 'En cours',
    'section6': 'En cours',
    'section7': 'En cours',
    'section8': 'En cours',
    'section9': 'En cours',
    'section10': 'En cours',
    'section11': 'En cours',
    'section12': 'En cours',
  };

  final Map<String, String?> _photos = {
    'section2': null,
    'section3Apriori': null,
    'section3Aposteriori': null,
    'section4': null,
    'section5': null,
    'section11': null,
  };

  final Map<String, Map<String, String>?> _photosGps = {
    'section2': null,
    'section3Apriori': null,
    'section3Aposteriori': null,
    'section4': null,
    'section5': null,
    'section11': null,
  };

  final TextEditingController _implantDateController = TextEditingController();
  final TextEditingController _gpsXController = TextEditingController();
  final TextEditingController _gpsYController = TextEditingController();
  final TextEditingController _fouillesDebutController =
      TextEditingController();
  final TextEditingController _fouillesFinController = TextEditingController();
  final TextEditingController _sec2RemarqueController = TextEditingController();
  String _fouillesConformes = 'Oui';

  final TextEditingController _sec3AprioriDateController =
      TextEditingController();
  final TextEditingController _sec3AposterioriDateController =
      TextEditingController();
  final TextEditingController _sec4AprioriDateController =
      TextEditingController();
  final TextEditingController _sec4AposterioriDateController =
      TextEditingController();
  final TextEditingController _sec5AprioriDateController =
      TextEditingController();
  final TextEditingController _sec5AposterioriDateController =
      TextEditingController();
  final TextEditingController _sec7AprioriDateController =
      TextEditingController();
  final TextEditingController _sec7AposterioriDateController =
      TextEditingController();
  final TextEditingController _sec8AprioriDateController =
      TextEditingController();
  final TextEditingController _sec8AposterioriDateController =
      TextEditingController();
  final TextEditingController _sec11AprioriDateController =
      TextEditingController();
  final TextEditingController _sec11AposterioriDateController =
      TextEditingController();
  final TextEditingController _autreRecommandationController =
      TextEditingController();

  String _appreciationAvancement = 'Satisfaisant';
  String _recommandation = 'Mobiliser le personnel requis';

  final List<Map<String, dynamic>> _sec3APriori = [
    {
      'question': 'Origine des agglomérés',
      'response': 'Achat',
      'remark': '',
      'choices': ['Achat', 'Confection par entreprise'],
    },
    {
      'question': 'Le nombre d’agglomérés pleins requis est disponible',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'La durée de séchage des agglomérés pleins a été respectée',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'La qualité des agglomérés pleins est bonne',
      'response': 'Oui',
      'remark': '',
    },
    {'question': 'Le fer est de qualité', 'response': 'Oui', 'remark': ''},
    {
      'question':
          'Le ferraillage respecte les dimensions et l’espacement requis entre les barres de fer',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Le dosage du béton pour le coulage des dalles est respecté',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les moules de coffrage des dalles respectent les dimensions',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Le remblai au niveau du trottoir est compacté',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Le coffrage des marches d’accès est conforme au plan',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec3APosteriori = [
    {
      'question':
          'Le béton de propreté au fond de la fosse respecte au moins 5 cm d’épaisseur',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les murs sont rectilignes et perpendiculaires',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Les murs de séparation des fosses sont à bonne distance et étanches et recouverts d’enduit des 2 côtés',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Les murs extérieurs de la fosse sont bien ajourés, permettant l’infiltration des liquides',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'La maçonnerie des fosses dépasse le terrain naturel conformément au plan',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les dalles respectent les dimensions requises',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les surfaces des dalles sont bien lisses',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Les trous pour la défécation sont placés conformément au plan',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Les dalles de vidange disposent d’un trou pour le conduit d’aération',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Les regards pour la vidange sont intégrés à la dalle de vidange',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les marches d’accès sont conformes au plan',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec4APriori = [
    {
      'question': 'Origine des agglomérés creux',
      'response': 'Achat',
      'remark': '',
      'choices': ['Achat', 'Confection par entreprise'],
    },
    {
      'question': 'Le nombre d’agglos creux requis a été confectionné',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'La durée de séchage des agglos creux a été respectée',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'La qualité des agglos creux est bonne',
      'response': 'Oui',
      'remark': '',
    },
    {'question': 'Le fer est de qualité', 'response': 'Oui', 'remark': ''},
    {
      'question':
          'Le ferraillage des poteaux respecte les dimensions et l’espacement requis entre les barres de fer',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Le coffrage des poteaux est bien perpendiculaire au sol',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec4APosteriori = [
    {
      'question':
          'Les murs sont rectilignes et perpendiculaires et reposent bien sur les murs de la fosse',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Les murs de séparation des cabines sont d’une hauteur suffisante (1,80 m)',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les marches d’accès sont conformes au plan',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les conduits d’aération sont bien solidaires des murs',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec5APriori = [
    {
      'question':
          'Le ferraillage de la dalle du toit respecte les dimensions et l’espacement requis entre les barres de fer',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'La fourniture de la structure métallique est complète avec les IPN, les cornières et les divers éléments de la charpente',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec5APosteriori = [
    {
      'question':
          'La toiture est légèrement inclinée permettant l’évacuation des eaux de pluie',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'La pose de la structure métallique est bien solide et ne présente pas de faiblesse',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec6 = [
    {
      'question':
          'Les murs intérieurs et extérieurs sont enduits avec une surface bien lisse',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les enduits adhèrent bien aux murs',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'La tyrolienne est appliquée sur les murs extérieurs',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec7APriori = [
    {
      'question':
          'Les portes sont conformes au CPT (à valider obligatoirement par le MOE avant pose)',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec7APosteriori = [
    {
      'question': 'Les portes sont posées, s’ouvrent et se ferment facilement',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Le système de fermeture des portes (intérieur et extérieur) est bien fonctionnel',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les fenêtres d’aération sont installées dans chaque cabine',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Des barres de soutien sont fixées dans les cabines destinées aux PMR',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Un porte manteau est fixé dans chaque cabine destinée aux filles',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Une poubelle est installée à la sortie des latrines',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec8APriori = [
    {
      'question': 'La cuvette est conforme au CPT',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec8APosteriori = [
    {
      'question': 'La cuvette est solidement intégrée à la dalle de défécation',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Les conduits d’aération sont obturés par un grillage anti-mouche',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'Les couvercles des regards sont en place sur les dalles de vidange',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec9 = [
    {
      'question': 'Les murs intérieurs sont peints',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Les murs extérieurs sont peints',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec10 = [
    {
      'question':
          'Le revêtement (carrelage et plinthe) est posé dans toutes les cabines',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec11APriori = [
    {
      'question':
          'L’emplacement prévu pour le DLM se situe à moins de 5 m du bloc de latrines',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question':
          'L’emplacement prévu dispose d’un puisard pour recueillir les eaux usées',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Le dispositif de lave-mains respecte le cahier des charges',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec11APosteriori = [
    {
      'question': 'Le dispositif de lave-mains respecte le cahier des charges',
      'response': 'Oui',
      'remark': '',
    },
    {
      'question': 'Le DLM est fonctionnel (absence de fuite)',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec12 = [
    {
      'question':
          'Les garde-fous sont installés solidement conformément au plan',
      'response': 'Oui',
      'remark': '',
    },
  ];

  final List<Map<String, dynamic>> _sec13Avant = [
    {
      'question':
          'Existence d’un plan de gestion des déchets (stockage, transport, traitement)',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question':
          'Implantation des latrines à une distance d’au moins 30 m d’un puits / 5 m d’un robinet',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question':
          'Tenue de séance de sensibilisation des ouvriers sur les maladies respiratoires et sur les risques d’accident',
      'response': '',
      'type': 'number',
      'responseLabel': 'Nb d’ouvriers sensibilisés',
      'showRemark': false,
    },
    {
      'question':
          'Tenue d’une séance d’information avant le démarrage des travaux en présence des responsables de sites, des femmes fréquentant le site et de l’équipe de l’entreprise',
      'response': 'Oui',
      'showRemark': false,
    },
  ];

  final List<Map<String, dynamic>> _sec13Pendant = [
    {
      'question': 'Trousse de premier secours présente sur le chantier',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question':
          'Eau potable disponible sur le chantier en quantité suffisante pour toute l’équipe',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question': 'Présence d’un registre travailleurs complet et à jour',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question':
          'Nb d’ouvriers présents sur le chantier au moment du contrôle',
      'response': '',
      'type': 'number',
      'responseLabel': 'Nb',
      'showRemark': false,
    },
    {
      'question': 'Nb d’ouvriers portant des masques',
      'response': '',
      'type': 'number',
      'responseLabel': 'Nb',
      'showRemark': false,
    },
    {
      'question': 'Nb d’ouvriers portant des EPI',
      'response': '',
      'type': 'number',
      'responseLabel': 'Nb',
      'showRemark': false,
    },
    {
      'question':
          'Etablissement d’un périmètre de sécurité autour des fosses avec barrières de sécurité ou matériel de balisage',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question': 'Nb d’accidents enregistrés depuis dernière visite',
      'response': '',
      'type': 'number',
      'responseLabel': 'Nb',
      'showRemark': false,
    },
    {
      'question':
          'Zone de stockage des matériaux protégée des risques de fuite',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question': 'Véhicule',
      'response': 'Fonctionnel',
      'choices': ['Fonctionnel', 'Non fonctionnel'],
      'showRemark': false,
    },
    {
      'question': 'Bétonnière',
      'response': 'Fonctionnel',
      'choices': ['Fonctionnel', 'Non fonctionnel'],
      'showRemark': false,
    },
    {
      'question':
          'Stockage des déchets de chantier dans une zone balisée et sécurisée',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question':
          'Les déchets sont triés sur place selon les consignes données',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question': 'Constat de brulage des déchets',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question':
          'Les déchets sont évacués régulièrement selon le plan de gestion',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question':
          'Aucun déchet n’est abandonné sur le site à la fin du chantier',
      'response': 'Oui',
      'showRemark': false,
    },
    {
      'question': 'Etalement des déblais restants sur le terrain',
      'response': 'Oui',
      'showRemark': false,
    },
  ];

  final List<Map<String, dynamic>> _sec14 = [
    {
      'question':
          'Nb de plaintes enregistrées pour nuisance du chantier depuis le dernier passage',
      'response': '',
      'type': 'number',
      'remark': '',
    },
    {
      'question':
          'Nb de plaintes enregistrées pour violences basées sur le genre depuis le dernier passage',
      'response': '',
      'type': 'number',
      'remark': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  /// Charge les données sauvegardées et restaure tous les contrôleurs et listes
  Future<void> _loadDraft() async {
    final param = await _dbService.getParametreUtilisateur();
    final localiteId = param?['localite_id'];
    if (localiteId == null) return;

    final data = await _dbService.getQuestionnaire(
      type: 'controle_travaux',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    setState(() {
      // Statuts des sections
      final ss = data['sectionStatus'];
      if (ss is Map) {
        ss.forEach((k, v) {
          if (_sectionStatus.containsKey(k)) _sectionStatus[k] = v.toString();
        });
      }

      // Section 2
      final s2 = data['section2'];
      if (s2 is Map) {
        _implantDateController.text = s2['dateImplantation'] ?? '';
        _gpsXController.text = s2['gpsX'] ?? '';
        _gpsYController.text = s2['gpsY'] ?? '';
        _fouillesDebutController.text = s2['dateDebutFouilles'] ?? '';
        _fouillesFinController.text = s2['dateFinFouilles'] ?? '';
        _fouillesConformes = s2['fouillesConformes'] ?? 'Oui';
        _sec2RemarqueController.text = s2['remarque'] ?? '';
        _photos['section2'] = s2['photo'];
        _photosGps['section2'] = (s2['photoGps'] as Map?)?.cast<String, String>();
      }

      // Section 3
      final s3 = data['section3'];
      if (s3 is Map) {
        _sec3AprioriDateController.text = s3['aprioriDate'] ?? '';
        _sec3AposterioriDateController.text = s3['aposterioriDate'] ?? '';
        _restoreQuestionList(_sec3APriori, s3['apriori']);
        _restoreQuestionList(_sec3APosteriori, s3['aposteriori']);
        _photos['section3Apriori'] = (s3['photos'] as Map?)?['apriori'];
        _photos['section3Aposteriori'] = (s3['photos'] as Map?)?['aposteriori'];
      }

      // Section 4
      final s4 = data['section4'];
      if (s4 is Map) {
        _sec4AprioriDateController.text = s4['aprioriDate'] ?? '';
        _sec4AposterioriDateController.text = s4['aposterioriDate'] ?? '';
        _restoreQuestionList(_sec4APriori, s4['apriori']);
        _restoreQuestionList(_sec4APosteriori, s4['aposteriori']);
        _photos['section4'] = s4['photo'];
      }

      // Section 5
      final s5 = data['section5'];
      if (s5 is Map) {
        _sec5AprioriDateController.text = s5['aprioriDate'] ?? '';
        _sec5AposterioriDateController.text = s5['aposterioriDate'] ?? '';
        _restoreQuestionList(_sec5APriori, s5['apriori']);
        _restoreQuestionList(_sec5APosteriori, s5['aposteriori']);
        _photos['section5'] = s5['photo'];
      }

      // Section 6
      _restoreQuestionList(_sec6, data['section6']?['questions']);

      // Section 7
      final s7 = data['section7'];
      if (s7 is Map) {
        _sec7AprioriDateController.text = s7['aprioriDate'] ?? '';
        _sec7AposterioriDateController.text = s7['aposterioriDate'] ?? '';
        _restoreQuestionList(_sec7APriori, s7['apriori']);
        _restoreQuestionList(_sec7APosteriori, s7['aposteriori']);
      }

      // Section 8
      final s8 = data['section8'];
      if (s8 is Map) {
        _sec8AprioriDateController.text = s8['aprioriDate'] ?? '';
        _sec8AposterioriDateController.text = s8['aposterioriDate'] ?? '';
        _restoreQuestionList(_sec8APriori, s8['apriori']);
        _restoreQuestionList(_sec8APosteriori, s8['aposteriori']);
      }

      // Sections 9, 10, 12
      _restoreQuestionList(_sec9, data['section9']?['questions']);
      _restoreQuestionList(_sec10, data['section10']?['questions']);
      _restoreQuestionList(_sec12, data['section12']?['questions']);

      // Section 11
      final s11 = data['section11'];
      if (s11 is Map) {
        _sec11AprioriDateController.text = s11['aprioriDate'] ?? '';
        _sec11AposterioriDateController.text = s11['aposterioriDate'] ?? '';
        _restoreQuestionList(_sec11APriori, s11['apriori']);
        _restoreQuestionList(_sec11APosteriori, s11['aposteriori']);
        _photos['section11'] = s11['photo'];
      }

      // Section 13
      _restoreQuestionList(_sec13Avant, data['section13']?['avant']);
      _restoreQuestionList(_sec13Pendant, data['section13']?['pendant']);

      // Section 14
      _restoreQuestionList(_sec14, data['section14']);

      // Section 15
      final s15 = data['section15'];
      if (s15 is Map) {
        _appreciationAvancement = s15['appreciation'] ?? 'Satisfaisant';
        _recommandation = s15['recommandation'] ?? 'Mobiliser le personnel requis';
        _autreRecommandationController.text = s15['autreRecommandation'] ?? '';
      }
    });
  }

  /// Restaure les réponses et remarques d'une liste de questions depuis les données JSON
  void _restoreQuestionList(List<Map<String, dynamic>> target, dynamic sourceData) {
    if (sourceData == null || sourceData is! List) return;
    final source = sourceData as List;
    for (int i = 0; i < target.length && i < source.length; i++) {
      final s = source[i];
      if (s is Map) {
        if (s.containsKey('response')) target[i]['response'] = s['response'];
        if (s.containsKey('remark')) target[i]['remark'] = s['remark'];
      }
    }
  }

  @override
  void dispose() {
    _implantDateController.dispose();
    _gpsXController.dispose();
    _gpsYController.dispose();
    _fouillesDebutController.dispose();
    _fouillesFinController.dispose();
    _sec2RemarqueController.dispose();
    _sec3AprioriDateController.dispose();
    _sec3AposterioriDateController.dispose();
    _sec4AprioriDateController.dispose();
    _sec4AposterioriDateController.dispose();
    _sec5AprioriDateController.dispose();
    _sec5AposterioriDateController.dispose();
    _sec7AprioriDateController.dispose();
    _sec7AposterioriDateController.dispose();
    _sec8AprioriDateController.dispose();
    _sec8AposterioriDateController.dispose();
    _sec11AprioriDateController.dispose();
    _sec11AposterioriDateController.dispose();
    _autreRecommandationController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto(String sectionKey) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obtention de la position GPS...')),
      );

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Permission GPS refusée')));
        setState(() {
          _photos[sectionKey] = photo.path;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _photos[sectionKey] = photo.path;
        _photosGps[sectionKey] = {
          'lat': position.latitude.toString(),
          'lng': position.longitude.toString(),
        };
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la prise de photo: $error')),
      );
    }
  }

  Widget _buildSectionStatusSelector(String sectionKey) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          const Text(
            'Etat de la section:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text('Achevé'),
            selected: _sectionStatus[sectionKey] == 'Achevé',
            onSelected: (_) =>
                setState(() => _sectionStatus[sectionKey] = 'Achevé'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('En cours'),
            selected: _sectionStatus[sectionKey] == 'En cours',
            onSelected: (_) =>
                setState(() => _sectionStatus[sectionKey] = 'En cours'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPhaseHeader(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _buildTextField('Date', controller),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(Map<String, dynamic> item) {
    final String type = (item['type'] as String?) ?? 'choice';
    final bool showRemark = (item['showRemark'] as bool?) ?? true;

    if (type == 'number' || type == 'text') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['question'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: item['response']?.toString() ?? '',
                keyboardType: type == 'number'
                    ? TextInputType.number
                    : TextInputType.text,
                decoration: InputDecoration(
                  labelText: item['responseLabel'] as String? ?? 'Réponse',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => item['response'] = value,
              ),
              if (showRemark) ...[
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: item['remark']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Remarque',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => item['remark'] = value,
                ),
              ],
            ],
          ),
        ),
      );
    }

    final List<String> options =
        ((item['choices'] as List<dynamic>?)
                    ?.map((value) => value.toString())
                    .toList() ??
                ['Oui', 'Non'])
            .toSet()
            .toList();
    final String currentValue = options.contains(item['response'])
        ? item['response'] as String
        : options.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['question'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: currentValue,
              decoration: const InputDecoration(
                labelText: 'Réponse',
                border: OutlineInputBorder(),
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => item['response'] = value ?? ''),
            ),
            if (showRemark) ...[
              const SizedBox(height: 8),
              TextFormField(
                initialValue: item['remark']?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Remarque',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => item['remark'] = value,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(List<Map<String, dynamic>> questions) {
    return Column(children: questions.map(_buildQuestionItem).toList());
  }

  Widget _buildPhotoField(String photoKey, String label) {
    final photoPath = _photos[photoKey];
    final gps = _photosGps[photoKey];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _takePhoto(photoKey),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Prendre la photo'),
            ),
            if (photoPath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(photoPath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (gps != null) ...[
              const SizedBox(height: 8),
              Text(
                'GPS: ${gps['lat']}, ${gps['lng']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String sectionKey,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        children: [_buildSectionStatusSelector(sectionKey), ...children],
      ),
    );
  }

  Future<void> _saveNiveau3() async {
    final param = await _dbService.getParametreUtilisateur();
    final activeLocaliteId = param?['localite_id'];

    if (activeLocaliteId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord effectuer le paramétrage initial'),
        ),
      );
      return;
    }

    final payload = {
      'sectionStatus': _sectionStatus,
      'section1': {'status': _sectionStatus['section1']},
      'section2': {
        'status': _sectionStatus['section2'],
        'dateImplantation': _implantDateController.text,
        'gpsX': _gpsXController.text,
        'gpsY': _gpsYController.text,
        'dateDebutFouilles': _fouillesDebutController.text,
        'dateFinFouilles': _fouillesFinController.text,
        'fouillesConformes': _fouillesConformes,
        'remarque': _sec2RemarqueController.text,
        'photo': _photos['section2'],
        'photoGps': _photosGps['section2'],
      },
      'section3': {
        'status': _sectionStatus['section3'],
        'aprioriDate': _sec3AprioriDateController.text,
        'aposterioriDate': _sec3AposterioriDateController.text,
        'apriori': _sec3APriori,
        'aposteriori': _sec3APosteriori,
        'photos': {
          'apriori': _photos['section3Apriori'],
          'aposteriori': _photos['section3Aposteriori'],
        },
        'photosGps': {
          'apriori': _photosGps['section3Apriori'],
          'aposteriori': _photosGps['section3Aposteriori'],
        },
      },
      'section4': {
        'status': _sectionStatus['section4'],
        'aprioriDate': _sec4AprioriDateController.text,
        'aposterioriDate': _sec4AposterioriDateController.text,
        'apriori': _sec4APriori,
        'aposteriori': _sec4APosteriori,
        'photo': _photos['section4'],
        'photoGps': _photosGps['section4'],
      },
      'section5': {
        'status': _sectionStatus['section5'],
        'aprioriDate': _sec5AprioriDateController.text,
        'aposterioriDate': _sec5AposterioriDateController.text,
        'apriori': _sec5APriori,
        'aposteriori': _sec5APosteriori,
        'photo': _photos['section5'],
        'photoGps': _photosGps['section5'],
      },
      'section6': {'status': _sectionStatus['section6'], 'questions': _sec6},
      'section7': {
        'status': _sectionStatus['section7'],
        'aprioriDate': _sec7AprioriDateController.text,
        'aposterioriDate': _sec7AposterioriDateController.text,
        'apriori': _sec7APriori,
        'aposteriori': _sec7APosteriori,
      },
      'section8': {
        'status': _sectionStatus['section8'],
        'aprioriDate': _sec8AprioriDateController.text,
        'aposterioriDate': _sec8AposterioriDateController.text,
        'apriori': _sec8APriori,
        'aposteriori': _sec8APosteriori,
      },
      'section9': {'status': _sectionStatus['section9'], 'questions': _sec9},
      'section10': {'status': _sectionStatus['section10'], 'questions': _sec10},
      'section11': {
        'status': _sectionStatus['section11'],
        'aprioriDate': _sec11AprioriDateController.text,
        'aposterioriDate': _sec11AposterioriDateController.text,
        'apriori': _sec11APriori,
        'aposteriori': _sec11APosteriori,
        'photo': _photos['section11'],
        'photoGps': _photosGps['section11'],
      },
      'section12': {'status': _sectionStatus['section12'], 'questions': _sec12},
      'section13': {'avant': _sec13Avant, 'pendant': _sec13Pendant},
      'section14': _sec14,
      'section15': {
        'appreciation': _appreciationAvancement,
        'recommandation': _recommandation,
        'autreRecommandation': _recommandation == 'Autre (à préciser)'
            ? _autreRecommandationController.text
            : '',
      },
      'photos': _photos,
      'photosGps': _photosGps,
    };

    await _dbService.upsertQuestionnaire(
      type: 'controle_travaux',
      localiteId: activeLocaliteId,
      dataMap: payload,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Niveau 3 enregistré avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Niveau 3 - Contrôle des travaux')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Questionnaire de contrôle des travaux',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'Chaque section reprend le formulaire terrain avec état, réponses, remarques, dates de phase et photos obligatoires.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: '1. Installation du chantier',
            sectionKey: 'section1',
            initiallyExpanded: true,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Section de suivi de l’état global de l’installation du chantier.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '2. Implantation et terrassement',
            sectionKey: 'section2',
            children: [
              _buildTextField(
                'Date d’implantation de l’ouvrage',
                _implantDateController,
              ),
              _buildTextField('Coordonnées GPS (X)', _gpsXController),
              _buildTextField('Coordonnées GPS (Y)', _gpsYController),
              _buildTextField(
                'Date de démarrage des fouilles',
                _fouillesDebutController,
              ),
              _buildTextField(
                'Date de fin des fouilles',
                _fouillesFinController,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _fouillesConformes,
                  decoration: const InputDecoration(
                    labelText: 'Les fouilles sont conformes au plan',
                    border: OutlineInputBorder(),
                  ),
                  items: const ['Oui', 'Non']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _fouillesConformes = value ?? 'Oui'),
                ),
              ),
              _buildTextField('Remarque', _sec2RemarqueController, maxLines: 3),
              _buildPhotoField('section2', 'Photo'),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '3. Béton en fondation et maçonnerie en fondation',
            sectionKey: 'section3',
            children: [
              _buildPhaseHeader('A priori', _sec3AprioriDateController),
              _buildQuestionList(_sec3APriori),
              _buildPhotoField('section3Apriori', 'Photo'),
              _buildPhaseHeader('A posteriori', _sec3AposterioriDateController),
              _buildQuestionList(_sec3APosteriori),
              _buildPhotoField('section3Aposteriori', 'Photo'),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '4. Béton et maçonnerie en élévation',
            sectionKey: 'section4',
            children: [
              _buildPhaseHeader('A priori', _sec4AprioriDateController),
              _buildQuestionList(_sec4APriori),
              _buildPhaseHeader('A posteriori', _sec4AposterioriDateController),
              _buildQuestionList(_sec4APosteriori),
              _buildPhotoField('section4', 'Photo'),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '5. Dalles de plancher (toit)',
            sectionKey: 'section5',
            children: [
              _buildPhaseHeader('A priori', _sec5AprioriDateController),
              _buildQuestionList(_sec5APriori),
              _buildPhaseHeader('A posteriori', _sec5AposterioriDateController),
              _buildQuestionList(_sec5APosteriori),
              _buildPhotoField('section5', 'Photo'),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '6. Enduits',
            sectionKey: 'section6',
            children: [_buildQuestionList(_sec6)],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '7. Menuiserie',
            sectionKey: 'section7',
            children: [
              _buildPhaseHeader('A priori', _sec7AprioriDateController),
              _buildQuestionList(_sec7APriori),
              _buildPhaseHeader('A posteriori', _sec7AposterioriDateController),
              _buildQuestionList(_sec7APosteriori),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '8. Plomberie',
            sectionKey: 'section8',
            children: [
              _buildPhaseHeader('A priori', _sec8AprioriDateController),
              _buildQuestionList(_sec8APriori),
              _buildPhaseHeader('A posteriori', _sec8AposterioriDateController),
              _buildQuestionList(_sec8APosteriori),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '9. Peinture',
            sectionKey: 'section9',
            children: [_buildQuestionList(_sec9)],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '10. Revêtement',
            sectionKey: 'section10',
            children: [_buildQuestionList(_sec10)],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '11. Dispositif de lave-mains (DLM)',
            sectionKey: 'section11',
            children: [
              _buildPhaseHeader('A priori', _sec11AprioriDateController),
              _buildQuestionList(_sec11APriori),
              _buildPhaseHeader(
                'A posteriori',
                _sec11AposterioriDateController,
              ),
              _buildQuestionList(_sec11APosteriori),
              _buildPhotoField('section11', 'Photo'),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            title: '12. Garde-fou',
            sectionKey: 'section12',
            children: [_buildQuestionList(_sec12)],
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: const Text(
                '13. Suivi du PGES',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Avant les travaux',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                _buildQuestionList(_sec13Avant),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Pendant les travaux',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                _buildQuestionList(_sec13Pendant),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: const Text(
                '14. Suivi du Mécanisme de Gestion des Plaintes (MGP)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              children: [_buildQuestionList(_sec14)],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: const Text(
                '15. Appréciation du niveau d’avancement',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _appreciationAvancement,
                    decoration: const InputDecoration(
                      labelText: 'Appréciation du niveau d’avancement',
                      border: OutlineInputBorder(),
                    ),
                    items: const ['Satisfaisant', 'Non satisfaisant']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => _appreciationAvancement = value ?? 'Satisfaisant',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _recommandation,
                    decoration: const InputDecoration(
                      labelText: 'Principale recommandation',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        const [
                              'Mobiliser le personnel requis',
                              'Alimenter le chantier en matériaux manquants',
                              'Accélérer les travaux',
                              'Corriger les imperfections constatées',
                              'Autre (à préciser)',
                            ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(
                      () => _recommandation =
                          value ?? 'Mobiliser le personnel requis',
                    ),
                  ),
                ),
                if (_recommandation == 'Autre (à préciser)')
                  _buildTextField(
                    'Préciser la recommandation',
                    _autreRecommandationController,
                    maxLines: 2,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveNiveau3,
            child: const Text('Enregistrer Niveau 3'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/niveau4'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Aller au Niveau 4 - Réception'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
