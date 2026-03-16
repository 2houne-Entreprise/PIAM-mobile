import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkDetailScreen extends StatefulWidget {
  final String section;

  const WorkDetailScreen({super.key, required this.section});

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  String status = 'En cours';
  final Map<String, dynamic> formData = {};
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      status = _prefs.getString('${widget.section}_status') ?? 'En cours';
      // Load all form data
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('${widget.section}_')) {
          final value = _prefs.get(key);
          if (value != null) {
            formData[key.replaceFirst('${widget.section}_', '')] = value;
          }
        }
      }
    });
  }

  Future<void> _saveData() async {
    await _prefs.setString('${widget.section}_status', status);
    for (final entry in formData.entries) {
      final key = '${widget.section}_${entry.key}';
      final value = entry.value.toString();
      await _prefs.setString(key, value);
    }
  }

  // Define fields for each section
  Map<String, List<Map<String, dynamic>>> getSectionFields() {
    return {
      'Installation du chantier': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
      ],
      'Implantation et terrassement': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {'type': 'date', 'label': 'Date d\'implantation de l\'ouvrage'},
        {'type': 'text', 'label': 'Coordonnées GPS (X)'},
        {'type': 'text', 'label': 'Coordonnées GPS (Y)'},
        {'type': 'date', 'label': 'Date de démarrage des fouilles'},
        {'type': 'date', 'label': 'Date de fin des fouilles'},
        {
          'type': 'radio',
          'label': 'Les fouilles sont conformes au plan',
          'options': ['Oui', 'Non'],
        },
        {'type': 'text', 'label': 'Remarque'},
        {'type': 'photo', 'label': 'Photo'},
      ],
      'Béton en fondation et maçonnerie en fondation': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {'type': 'subsection', 'label': 'A priori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label': 'Origine des agglomérés',
          'options': ['Achat', 'confection par entreprise'],
        },
        {
          'type': 'radio',
          'label': 'Le nombre d\'agglomérés pleins requis est disponible',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'La durée de séchage des agglomérés pleins a été respectée',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'La qualité des agglomérés pleins est bonne',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Le fer est de qualité',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Le ferraillage respecte les dimensions et l\'espacement requis entre les barres de fer',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Le dosage du béton pour le coulage des dalles est respecté',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les moules de coffrage des dalles respectent les dimensions',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Le remblai au niveau du trottoir est compacté',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Le coffrage des marches d\'accès est conforme au plan',
          'options': ['Oui', 'Non'],
        },
        {'type': 'photo', 'label': 'Photo'},
        {'type': 'subsection', 'label': 'A posteriori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label':
              'Le béton de propreté au fond de la fosse respecte au moins 5 cm d\'épaisseur',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Les murs sont rectilignes et perpendiculaires',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les murs de séparation des fosses sont à bonne distance et étanches et recouvert d\'enduit des 2 côtés (pas de communication possible entre les fosses)',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les murs extérieurs de la fosse sont bien ajourés, permettant l\'infiltration des liquides',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'La maçonnerie des fosses dépasse le terrain naturel conformément au plan',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Les dalles respectent les dimensions requises',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Les surfaces des dalles sont bien lisses',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les trous pour la défécation sont placés conformément au plan',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les dalles de vidange disposent d\'un trou pour le conduit d\'aération',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les regards pour la vidange sont intégrés à la dalle de vidange',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Les marches d\'accès sont conformes au plan',
          'options': ['Oui', 'Non'],
        },
        {'type': 'photo', 'label': 'Photo'},
      ],
      'Béton et maçonnerie en élévation': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {'type': 'subsection', 'label': 'A priori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label': 'Origine des agglomérés creux',
          'options': ['Achat', 'confection par entreprise'],
        },
        {
          'type': 'radio',
          'label': 'Le nombre d\'agglos creux requis a été confectionné',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'La durée de séchage des agglos creux a été respectée',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'La qualité des agglos creux est bonne',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Le fer est de qualité',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Le ferraillage des poteaux respecte les dimensions et l\'espacement requis entre les barres de fer',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Le coffrage des poteaux est bien perpendiculaire au sol',
          'options': ['Oui', 'Non'],
        },
        {'type': 'subsection', 'label': 'A posteriori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label':
              'Les murs sont rectilignes et perpendiculaires et reposent bien sur les murs de la fosse',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les murs de séparation des cabines sont d\'une hauteur suffisante (1,80 m)',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Les marches d\'accès sont conformes au plan',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Les conduits d\'aération sont bien solidaires des murs',
          'options': ['Oui', 'Non'],
        },
        {'type': 'photo', 'label': 'Photo'},
      ],
      'Dalles de plancher (toit)': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {'type': 'subsection', 'label': 'A priori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label':
              'Le ferraillage de la dalle du toit respecte les dimensions et l\'espacement requis entre les barres de fer',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'La fourniture de la structure métallique est complète avec les IPN, les cornières et les divers éléments de la charpente',
          'options': ['Oui', 'Non'],
        },
        {'type': 'subsection', 'label': 'A posteriori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label':
              'La toiture est légèrement inclinée permettant l\'évacuation des eaux de pluie',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'La pose de la structure métallique est bien solide et ne présente pas de faiblesse (Tôle fixée aux IPN avec vis et écrou)',
          'options': ['Oui', 'Non'],
        },
        {'type': 'photo', 'label': 'Photo'},
      ],
      'Enduits': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {
          'type': 'radio',
          'label':
              'Les murs intérieurs et extérieurs sont enduits avec une surface bien lisse',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Les enduits adhèrent bien aux murs',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'La tyrolienne est appliquée sur les murs extérieurs',
          'options': ['Oui', 'Non'],
        },
      ],
      'Menuiserie': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {'type': 'subsection', 'label': 'A priori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label':
              'Les portes sont conformes au CPT (à valider obligatoirement par le MOE avant pose)',
          'options': ['Oui', 'Non'],
        },
        {'type': 'subsection', 'label': 'A posteriori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label':
              'Les portes sont posées, s\'ouvrent et se ferment facilement',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Le système de fermeture des portes (intérieur et extérieur) est bien fonctionnel',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les fenêtres d\'aération sont installées dans chaque cabine',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Des barres de soutien sont fixées dans les cabines destinées aux PMR (personnes à mobilité réduite)',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Un porte manteau est fixé dans chaque cabine destinée aux filles',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Une poubelle est installée à la sortie des latrines',
          'options': ['Oui', 'Non'],
        },
      ],
      'Plomberie': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {'type': 'subsection', 'label': 'A priori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label': 'La cuvette est conforme au CPT',
          'options': ['Oui', 'Non'],
        },
        {'type': 'subsection', 'label': 'A posteriori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label':
              'La cuvette est solidement intégrée à la dalle de défécation',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les conduits d\'aération sont obturés par un grillage anti-mouche',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les couvercles des regards sont en place sur les dalles de vidange',
          'options': ['Oui', 'Non'],
        },
      ],
      'Peinture': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {
          'type': 'radio',
          'label': 'Les murs intérieurs sont peints',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Les murs extérieurs sont peints',
          'options': ['Oui', 'Non'],
        },
      ],
      'Revêtement': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {
          'type': 'radio',
          'label':
              'Le revêtement (carrelage et plinthe) est posé dans toutes les cabines',
          'options': ['Oui', 'Non'],
        },
      ],
      'Dispositif de lave-mains (DLM)': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {'type': 'subsection', 'label': 'A priori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label':
              'L\'emplacement prévu pour le DLM se situe à moins de 5 m du bloc de latrines',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'L\'emplacement prévu dispose d\'un puisard pour recueillir les eaux usées',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Le dispositif de lave-mains respecte le cahier des charges',
          'options': ['Oui', 'Non'],
        },
        {'type': 'subsection', 'label': 'A posteriori'},
        {'type': 'date', 'label': 'Date'},
        {
          'type': 'radio',
          'label': 'Le dispositif de lave-mains respecte le cahier des charges',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Le DLM est fonctionnel (absence de fuite)',
          'options': ['Oui', 'Non'],
        },
        {'type': 'photo', 'label': 'Photo'},
      ],
      'Garde-fou': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {
          'type': 'radio',
          'label':
              'Les garde-fous sont installés solidement conformément au plan',
          'options': ['Oui', 'Non'],
        },
      ],
      'Suivi du PGES': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {'type': 'subsection', 'label': 'Avant les travaux'},
        {
          'type': 'radio',
          'label':
              'Existence d\'un plan de gestion des déchets (stockage, transport, traitement)',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Implantation des latrines à une distance d\'au moins 30 m d\'un puits / 5 m d\'un robinet',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'number',
          'label':
              'Tenue de séance de sensibilisation des ouvriers sur les maladies respiratoires et sur les risques d\'accident (Nb d\'ouvriers sensibilisés)',
        },
        {
          'type': 'radio',
          'label':
              'Tenue d\'une séance d\'information avant le démarrage des travaux en présence des responsables de sites, des femmes fréquentant le site et de l\'équipe de l\'Entreprise : durée et consistance des travaux, circulation sur le chantier, IST, harcèlement et MGP',
          'options': ['Oui', 'Non'],
        },
        {'type': 'subsection', 'label': 'Pendant les travaux'},
        {
          'type': 'radio',
          'label': 'Trousse de premier secours présente sur le chantier',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Eau potable disponible sur le chantier en quantité suffisante pour toute l\'équipe',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Présence d\'un registre travailleurs complet et à jour',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'number',
          'label':
              'Nb d\'ouvriers présents sur le chantier au moment du contrôle',
        },
        {'type': 'number', 'label': 'Nb d\'ouvriers portant des masques'},
        {'type': 'number', 'label': 'Nb d\'ouvriers portant des EPI'},
        {
          'type': 'radio',
          'label':
              'Etablissement d\'un périmètre de sécurité autour des fosses avec barrières de sécurité ou matériel de balisage',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'number',
          'label': 'Nb d\'accidents enregistrés depuis dernière visite',
        },
        {'type': 'subsection', 'label': 'Stockage des matériaux'},
        {
          'type': 'radio',
          'label':
              'Zone de stockage des matériaux protégée des risques de fuite (dalle en béton ou bâche selon les cas)',
          'options': ['Oui', 'Non'],
        },
        {'type': 'subsection', 'label': 'Etat du matériel de chantier'},
        {
          'type': 'radio',
          'label': 'Véhicule',
          'options': ['Fonctionnel', 'Non fonctionnel'],
        },
        {
          'type': 'radio',
          'label': 'Bétonnière',
          'options': ['Fonctionnel', 'Non fonctionnel'],
        },
        {'type': 'subsection', 'label': 'Gestion des déchets'},
        {
          'type': 'radio',
          'label':
              'Stockage des déchets de chantier dans une zone balisée et sécurisée',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les déchets sont triés sur place selon les consignes données',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label': 'Constat de brulage des déchets',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Les déchets sont évacués régulièrement selon le plan de gestion',
          'options': ['Oui', 'Non'],
        },
        {
          'type': 'radio',
          'label':
              'Aucun déchet n\'est abandonné sur le site à la fin du chantier',
          'options': ['Oui', 'Non'],
        },
        {'type': 'subsection', 'label': 'Gestion des sols'},
        {
          'type': 'radio',
          'label': 'Etalement des déblais restants sur le terrain',
          'options': ['Oui', 'Non'],
        },
      ],
      'Mécanisme de réclamation': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {
          'type': 'number',
          'label': 'Nombre de plaintes liées aux nuisances de chantier',
        },
        {
          'type': 'number',
          'label': 'Nombre de plaintes de violence basée sur le genre',
        },
        {'type': 'text', 'label': 'Remarque'},
      ],
      'Évaluation de la progression': [
        {
          'type': 'radio',
          'label': 'Statut',
          'options': ['Achevé', 'En cours'],
        },
        {
          'type': 'radio',
          'label': 'Évaluation de la progression',
          'options': ['Satisfaisant', 'Non satisfaisant'],
        },
        {
          'type': 'dropdown',
          'label': 'Recommandation principale',
          'options': [
            'Mobiliser la main-d\'œuvre requise',
            'Fournir les matériaux manquants',
            'Accélérer les travaux',
            'Corriger les défauts',
            'Autre (préciser)',
          ],
        },
      ],
    };
  }

  Color getStatusColor() {
    return status == 'Achevé' ? Colors.green : Colors.yellow;
  }

  Widget buildField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field['label'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: (field['options'] as List<String>).map((option) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: formData[field['label']] ?? '',
                    onChanged: (value) async {
                      setState(() {
                        formData[field['label']] = value;
                      });
                      await _saveData();
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        );
      case 'text':
        return TextField(
          decoration: InputDecoration(labelText: field['label']),
          controller: TextEditingController(
            text: formData[field['label']] ?? '',
          ),
          onChanged: (value) async {
            formData[field['label']] = value;
            await _saveData();
          },
        );
      case 'number':
        return TextField(
          decoration: InputDecoration(labelText: field['label']),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: formData[field['label']] ?? '',
          ),
          onChanged: (value) async {
            formData[field['label']] = value;
            await _saveData();
          },
        );
      case 'date':
        return TextField(
          decoration: InputDecoration(labelText: field['label']),
          readOnly: true,
          controller: TextEditingController(
            text: formData[field['label']] ?? '',
          ),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              setState(() {
                formData[field['label']] = picked.toString().split(' ')[0];
              });
              await _saveData();
            }
          },
        );
      case 'dropdown':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: field['label']),
          value: formData[field['label']],
          items: (field['options'] as List<String>).map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) async {
            setState(() {
              formData[field['label']] = value;
            });
            await _saveData();
          },
        );
      case 'photo':
        return ElevatedButton(
          onPressed: () async {
            // Simulate photo upload
            formData[field['label']] =
                'Photo ajoutée le ${DateTime.now().toString().split(' ')[0]}';
            await _saveData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo ajoutée (simulé)')),
            );
          },
          child: Text(field['label']),
        );
      case 'subsection':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            field['label'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields =
        getSectionFields()[widget.section] ??
        [
          {
            'type': 'radio',
            'label': 'Statut',
            'options': ['Achevé', 'En cours'],
          },
          {'type': 'text', 'label': 'Remarque'},
        ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section),
        backgroundColor: getStatusColor(),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await _saveData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données sauvegardées')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: getStatusColor().withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statut:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: ['Achevé', 'En cours'].map((option) {
                        return Expanded(
                          child: RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: status,
                            onChanged: (value) async {
                              setState(() {
                                status = value!;
                              });
                              await _saveData();
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: fields
                    .where(
                      (field) =>
                          field['type'] != 'radio' ||
                          field['label'] != 'Statut',
                    )
                    .map(
                      (field) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: buildField(field),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
