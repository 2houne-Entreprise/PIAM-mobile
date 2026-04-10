import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class Niveau2OrganisationChantier extends StatefulWidget {
  static const String routeName = '/niveau2';
  const Niveau2OrganisationChantier({super.key});

  @override
  State<Niveau2OrganisationChantier> createState() =>
      _Niveau2OrganisationChantierState();
}

class _Niveau2OrganisationChantierState
    extends State<Niveau2OrganisationChantier> {
  final DatabaseService _dbService = DatabaseService();

  final _personnelForm = GlobalKey<FormState>();

  final _nomPersonnelController = TextEditingController();
  String _fonctionPersonnel = 'Chef de travaux';
  final _dateArriveeController = TextEditingController();
  String _provenancePersonnel = 'De la Wilaya';
  bool _contratTravail = false;
  bool _premiersSecours = false;
  final _masqueNbController = TextEditingController();
  bool _casque = false;
  bool _gants = false;
  bool _chaussures = false;
  bool _gilet = false;
  final _remarquePersonnelController = TextEditingController();

  final _equipementNomController = TextEditingController();
  final _equipementRemarqueController = TextEditingController();

  // Equipe de contrôle prédéfinie (B)
  final List<Map<String, dynamic>> _equipementChecklist = [
    {
      'nom': 'Bétonnière de capacité 250-500l en bon état',
      'date': '',
      'remarque': '',
      'etat': 'Bon état',
    },
    {'nom': 'Bâches à eau', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {
      'nom': 'Lot d’échafaudage',
      'date': '',
      'remarque': '',
      'etat': 'Bon état',
    },
    {
      'nom': 'Panneaux de coffrage',
      'date': '',
      'remarque': '',
      'etat': 'Bon état',
    },
    {'nom': 'Poste à soudure', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {
      'nom': 'Groupe électrogène',
      'date': '',
      'remarque': '',
      'etat': 'Bon état',
    },
    {
      'nom': 'Vibrateur pour béton',
      'date': '',
      'remarque': '',
      'etat': 'Bon état',
    },
    {'nom': 'Etais', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {'nom': 'Serre-joints', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {'nom': 'Pelles', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {'nom': 'Pioches', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {'nom': 'Brouettes', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {'nom': 'Seaux à béton', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {'nom': 'Règle', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {'nom': 'Niveau', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {'nom': 'Taloche', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {
      'nom': 'Tamis pour gravier',
      'date': '',
      'remarque': '',
      'etat': 'Bon état',
    },
    {
      'nom': 'Compresseur + marteau piqueur',
      'date': '',
      'remarque': '',
      'etat': 'Bon état',
    },
    {'nom': 'Vibro-pondeuse', 'date': '', 'remarque': '', 'etat': 'Bon état'},
    {
      'nom':
          'Corde pour délimitation du chantier, casques, gants, bottes, blouses, etc.',
      'date': '',
      'remarque': '',
      'etat': 'Bon état',
    },
  ];

  final List<Map<String, dynamic>> _materiauxChecklist = [
    {
      'nom': 'Ciment',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
    {
      'nom': 'Fer',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
    {
      'nom': 'Gravier',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
    {
      'nom': 'Sable',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
    {
      'nom': 'Menuiserie',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
    {
      'nom': 'Plomberie',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
    {
      'nom': 'Revêtement',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
    {
      'nom': 'Toiture',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
    {
      'nom': 'Peinture',
      'date': '',
      'quantite': '',
      'qualite': 'Satisfaisant',
      'recommandation': 'Augmenter la quantité',
    },
  ];

  final _materiauxNomController = TextEditingController();
  final _materiauxQuantiteController = TextEditingController();

  @override
  void dispose() {
    _nomPersonnelController.dispose();
    _dateArriveeController.dispose();
    _masqueNbController.dispose();
    _remarquePersonnelController.dispose();
    _equipementNomController.dispose();
    _equipementRemarqueController.dispose();
    _materiauxNomController.dispose();
    _materiauxQuantiteController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _paramInit;

  @override
  void initState() {
    super.initState();
    _loadParametrageInitial();
  }

  Future<void> _loadParametrageInitial() async {
    final param = await _dbService.getParametreUtilisateur();
    if (mounted) setState(() => _paramInit = param);
  }

  Future<void> _savePersonnel() async {
    if (!_personnelForm.currentState!.validate()) return;
    final activeLocaliteId = _paramInit?['localite_id'];
    if (activeLocaliteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez d\'abord effectuer le paramétrage initial')));
      return;
    }

    final data = {
      'nom': _nomPersonnelController.text.trim(),
      'fonction': _fonctionPersonnel,
      'dateArrivee': _dateArriveeController.text.trim(),
      'provenance': _provenancePersonnel,
      'contratTravail': _contratTravail ? 'Oui' : 'Non',
      'premiersSecours': _premiersSecours ? 'Oui' : 'Non',
      'masqueNb': int.tryParse(_masqueNbController.text) ?? 0,
      'casque': _casque ? 'Oui' : 'Non',
      'gants': _gants ? 'Oui' : 'Non',
      'chaussures': _chaussures ? 'Oui' : 'Non',
      'gilet': _gilet ? 'Oui' : 'Non',
      'remarque': _remarquePersonnelController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _dbService.upsertQuestionnaire(
      type: 'organisation_chantier_personnel',
      localiteId: activeLocaliteId,
      dataMap: data,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personnel ajouté')));
  }

  Future<void> _saveEquipementsChecklist() async {
    final activeLocaliteId = _paramInit?['localite_id'];
    if (activeLocaliteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez d\'abord effectuer le paramétrage initial')));
      return;
    }

    final data = _equipementChecklist.map((item) => {
      'nom': item['nom'],
      'etat': item['etat'],
      'remarque': item['remarque'],
      'date': item['date'],
    }).toList();

    await _dbService.upsertQuestionnaire(
      type: 'organisation_chantier_equipements',
      localiteId: activeLocaliteId,
      dataMap: {'items': data},
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checklist équipements sauvegardée')));
  }

  Future<void> _saveMateriauxChecklist() async {
    final activeLocaliteId = _paramInit?['localite_id'];
    if (activeLocaliteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez d\'abord effectuer le paramétrage initial')));
      return;
    }

    final data = _materiauxChecklist.map((item) => {
      'nom': item['nom'],
      'quantite': int.tryParse(item['quantite']?.toString() ?? '') ?? 0,
      'qualite': item['qualite'],
      'recommandation': item['recommandation'],
      'date': item['date'],
    }).toList();

    await _dbService.upsertQuestionnaire(
      type: 'organisation_chantier_materiaux',
      localiteId: activeLocaliteId,
      dataMap: {'items': data},
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checklist matériaux sauvegardée')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Niveau 2 - Organisation du chantier'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/niveau3'),
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            label: const Text(
              'Niveau 3',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExpansionTile(
            title: const Text('A) Personnel en place'),
            iconColor: Colors.green,
            collapsedIconColor: Colors.black54,
            children: [
              Form(
                key: _personnelForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nomPersonnelController,
                      label: 'Nom',
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      'Fonction',
                      _fonctionPersonnel,
                      [
                        'Chef de travaux',
                        'Maçons',
                        'Manœuvre',
                        'Menuisier',
                        'Peintre',
                        'Carreleur',
                      ],
                      (val) => setState(
                        () => _fonctionPersonnel = val ?? _fonctionPersonnel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _dateArriveeController,
                      label: 'Date arrivée (jj/mm/aaaa)',
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      'Provenance',
                      _provenancePersonnel,
                      ['De la Wilaya', 'Hors wilaya'],
                      (val) => setState(
                        () =>
                            _provenancePersonnel = val ?? _provenancePersonnel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Contrat de travail'),
                      value: _contratTravail,
                      onChanged: (v) => setState(() => _contratTravail = v),
                    ),
                    SwitchListTile(
                      title: const Text('Formé aux premiers secours'),
                      value: _premiersSecours,
                      onChanged: (v) => setState(() => _premiersSecours = v),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _masqueNbController,
                      label: 'Nb de masques remis',
                      keyboardType: TextInputType.number,
                    ),
                    SwitchListTile(
                      title: const Text('Casque remis'),
                      value: _casque,
                      onChanged: (v) => setState(() => _casque = v),
                    ),
                    SwitchListTile(
                      title: const Text('Gants remis'),
                      value: _gants,
                      onChanged: (v) => setState(() => _gants = v),
                    ),
                    SwitchListTile(
                      title: const Text('Chaussures remis'),
                      value: _chaussures,
                      onChanged: (v) => setState(() => _chaussures = v),
                    ),
                    SwitchListTile(
                      title: const Text('Gilet haute visibilité remis'),
                      value: _gilet,
                      onChanged: (v) => setState(() => _gilet = v),
                    ),
                    _buildTextField(
                      controller: _remarquePersonnelController,
                      label: 'Remarque',
                      required: false,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _savePersonnel,
                      child: const Text('Enregistrer Personnel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('B) Contrôle des équipements'),
            iconColor: Colors.green,
            collapsedIconColor: Colors.black54,
            children: [
              Column(
                children: _equipementChecklist.asMap().entries.map((entry) {
                  final item = entry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nom'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            initialValue: item['date'],
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => setState(() => item['date'] = v),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: item['etat'],
                            decoration: const InputDecoration(
                              labelText: 'Etat',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Bon état', 'Moyen', 'Défectueux']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(
                              () => item['etat'] = v ?? item['etat'],
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            initialValue: item['remarque'],
                            decoration: const InputDecoration(
                              labelText: 'Remarque',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) =>
                                setState(() => item['remarque'] = v),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveEquipementsChecklist,
                child: const Text('Enregistrer contrôles équipements'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('C) Contrôle des matériaux'),
            iconColor: Colors.green,
            collapsedIconColor: Colors.black54,
            children: [
              Column(
                children: _materiauxChecklist.asMap().entries.map((entry) {
                  final item = entry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nom'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            initialValue: item['date'],
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => setState(() => item['date'] = v),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            initialValue: item['quantite'],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantité',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) =>
                                setState(() => item['quantite'] = v),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: item['qualite'],
                            decoration: const InputDecoration(
                              labelText: 'Qualité',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Satisfaisant', 'Non satisfaisant']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(
                              () => item['qualite'] = v ?? item['qualite'],
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: item['recommandation'],
                            decoration: const InputDecoration(
                              labelText: 'Recommandation',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                [
                                      'Augmenter la quantité',
                                      'Améliorer la qualité',
                                      'A remplacer',
                                    ]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => setState(
                              () => item['recommandation'] =
                                  v ?? item['recommandation'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveMateriauxChecklist,
                child: const Text('Enregistrer contrôles matériaux'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/niveau3'),
                child: const Text('Accéder au Niveau 3 - Contrôle des travaux'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Champ requis';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
