import 'package:flutter/material.dart';
import '../services/sqlite_service.dart';
import 'niveau2_organisation_chantier.dart';

class Niveau1DonneesGenerales extends StatefulWidget {
  static const String routeName = '/niveau1';
  const Niveau1DonneesGenerales({super.key});

  @override
  State<Niveau1DonneesGenerales> createState() =>
      _Niveau1DonneesGeneralesState();
}

class _Niveau1DonneesGeneralesState extends State<Niveau1DonneesGenerales> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _codeMesreController = TextEditingController();
  final _codeMsController = TextEditingController();
  final _effectifController = TextEditingController();
  final _nbPotentielsController = TextEditingController();

  // Section B
  final _intituleProjetController = TextEditingController();
  final _marcheTravauxController = TextEditingController();
  final _numeroMarcheController = TextEditingController();
  final _nomEntrepriseMarcheController = TextEditingController();
  final _delaiMarcheController = TextEditingController();
  final _dateDemarrageMarcheController = TextEditingController();
  final _marcheControleTravauxController = TextEditingController();
  final _numeroMarcheControleController = TextEditingController();
  final _bureauControleController = TextEditingController();
  final _nomControleurController = TextEditingController();

  // Section C - travaux à réaliser
  final _latrinesArealiserController = TextEditingController();
  String _typeLatrinesArealiser = 'Semi-enterrée';
  String _toit = 'Toit en béton';
  final _nbBlocsController = TextEditingController();
  final _nbCabinesController = TextEditingController();
  final _nbDLMController = TextEditingController();
  final _autresTravauxController = TextEditingController();
  final _autrePreciserController = TextEditingController();

  final SQLiteService _dbService = SQLiteService();

  String? _wilaya;
  String? _moughataa;
  String? _commune;
  String? _localite;
  String _etablissement = 'Ecole fondamentale';
  String _typeLatrines = 'Semi-enterrée';
  bool _destructionAncienne = false;
  bool _constructionMur = false;
  final List<String> _wilayas = ['Nouakchott', 'Nouadhibou', 'Néma'];
  final Map<String, List<String>> _moughataas = {
    'Nouakchott': ['Arafat', 'El Mina', 'Saganeit'],
    'Nouadhibou': ['Nouadhibou'],
    'Néma': ['Néma'],
  };
  final Map<String, List<String>> _communes = {
    'Arafat': ['Commune 1', 'Commune 2'],
    'El Mina': ['Commune 1', 'Commune 2'],
    'Saganeit': ['Commune 1'],
    'Nouadhibou': ['Commune 1'],
    'Néma': ['Commune 1'],
  };
  final Map<String, List<String>> _localites = {
    'Commune 1': ['Localité A', 'Localité B'],
    'Commune 2': ['Localité C'],
  };

  String get _codeANSADE =>
      '${_wilaya?.substring(0, 2) ?? '__'}-${_moughataa?.substring(0, 2) ?? '__'}-${_commune?.substring(0, 2) ?? '__'}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final projectData = {
      'name': _projectNameController.text.trim(),
      'company': _companyNameController.text.trim(),
      'wilaya': _wilaya ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    };

    final projectId = await _dbService.insert('project', projectData);

    await _dbService.insert('donnees_generales', {
      'projectId': projectId,
      'intituleProjet': _intituleProjetController.text.trim(),
      'marcheTravaux': _marcheTravauxController.text.trim(),
      'numeroMarche': _numeroMarcheController.text.trim(),
      'nomEntreprise': _nomEntrepriseMarcheController.text.trim(),
      'delaiMarche': _delaiMarcheController.text.trim(),
      'dateDemarrageMarche': _dateDemarrageMarcheController.text.trim(),
      'marcheControleTravaux': _marcheControleTravauxController.text.trim(),
      'numeroMarcheControle': _numeroMarcheControleController.text.trim(),
      'bureauControle': _bureauControleController.text.trim(),
      'nomControleur': _nomControleurController.text.trim(),
      'latrinesArealiser': _latrinesArealiserController.text.trim(),
      'typeLatrinesArealiser': _typeLatrinesArealiser,
      'toit': _toit,
      'nbBlocs': int.tryParse(_nbBlocsController.text) ?? 0,
      'nbCabines': int.tryParse(_nbCabinesController.text) ?? 0,
      'nbDLM': int.tryParse(_nbDLMController.text) ?? 0,
      'autresTravaux': _autresTravauxController.text.trim(),
      'autrePreciser': _autrePreciserController.text.trim(),
      'destructionAnciennes': _destructionAncienne ? 'Oui' : 'Non',
      'constructionMur': _constructionMur ? 'Oui' : 'Non',
      'createdAt': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Projet sauvegardé (id $projectId)')),
    );
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _companyNameController.dispose();
    _codeMesreController.dispose();
    _codeMsController.dispose();
    _effectifController.dispose();
    _nbPotentielsController.dispose();

    _intituleProjetController.dispose();
    _marcheTravauxController.dispose();
    _numeroMarcheController.dispose();
    _nomEntrepriseMarcheController.dispose();
    _delaiMarcheController.dispose();
    _dateDemarrageMarcheController.dispose();
    _marcheControleTravauxController.dispose();
    _numeroMarcheControleController.dispose();
    _bureauControleController.dispose();
    _nomControleurController.dispose();

    _latrinesArealiserController.dispose();
    _nbBlocsController.dispose();
    _nbCabinesController.dispose();
    _nbDLMController.dispose();
    _autresTravauxController.dispose();
    _autrePreciserController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Niveau 1 - Données générales')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'A. Données administratives',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildDropdown('Wilaya', _wilaya, _wilayas, (val) {
                setState(() {
                  _wilaya = val;
                  _moughataa = null;
                  _commune = null;
                  _localite = null;
                });
              }),
              const SizedBox(height: 8),
              _buildDropdown(
                'Moughataa',
                _moughataa,
                _wilaya != null ? _moughataas[_wilaya] : null,
                (val) {
                  setState(() {
                    _moughataa = val;
                    _commune = null;
                    _localite = null;
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                'Commune',
                _commune,
                _moughataa != null ? _communes[_moughataa] : null,
                (val) {
                  setState(() {
                    _commune = val;
                    _localite = null;
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                'Localité',
                _localite,
                _commune != null ? _localites[_commune] : null,
                (val) {
                  setState(() {
                    _localite = val;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Code ANSADE (auto)',
                  suffixText: _codeANSADE,
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Etablissement public',
                _etablissement,
                [
                  'Ecole fondamentale',
                  'Centre de santé',
                  'Poste de Santé',
                  'Gare routière',
                  'Marché',
                  'Mosquée',
                  'Bâtiment administratif',
                ],
                (val) {
                  setState(() => _etablissement = val ?? _etablissement);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(labelText: 'Nom du site *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise *',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeMesreController,
                decoration: const InputDecoration(
                  labelText: 'Code MESRE',
                  hintText: 'En attendant codification MESRE',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeMsController,
                decoration: const InputDecoration(
                  labelText: 'Code MS',
                  hintText: 'En attendant codification MS',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _effectifController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Effectif de l\'école',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nbPotentielsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nb potentiels d\'usagers',
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'B. Données des marchés',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _intituleProjetController,
                decoration: const InputDecoration(
                  labelText: 'Intitulé du projet',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _marcheTravauxController,
                decoration: const InputDecoration(
                  labelText: 'Marché de travaux',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _numeroMarcheController,
                decoration: const InputDecoration(
                  labelText: 'Numéro du marché',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomEntrepriseMarcheController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _delaiMarcheController,
                decoration: const InputDecoration(
                  labelText: 'Délai du marché (en jours ou mois)',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateDemarrageMarcheController,
                decoration: const InputDecoration(
                  labelText: 'Date de démarrage du marché',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _marcheControleTravauxController,
                decoration: const InputDecoration(
                  labelText: 'Marché de contrôle des travaux',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _numeroMarcheControleController,
                decoration: const InputDecoration(
                  labelText: 'Numéro du marché de contrôle',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bureauControleController,
                decoration: const InputDecoration(
                  labelText: 'Bureau chargé du contrôle',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomControleurController,
                decoration: const InputDecoration(
                  labelText: 'Nom du contrôleur',
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'C. Données relatives aux travaux à réaliser',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                'Type de latrines',
                _typeLatrines,
                ['Semi-enterrée', 'Hors-sol'],
                (val) => setState(() => _typeLatrines = val ?? _typeLatrines),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _destructionAncienne,
                onChanged: (v) {
                  setState(() {
                    _destructionAncienne = v;
                  });
                },
                title: const Text('Destruction des anciennes latrines'),
              ),
              SwitchListTile(
                value: _constructionMur,
                onChanged: (v) {
                  setState(() {
                    _constructionMur = v;
                  });
                },
                title: const Text('Construction mur'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _latrinesArealiserController,
                decoration: const InputDecoration(
                  labelText: 'Latrines à réaliser',
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                'Type de latrines à réaliser',
                _typeLatrinesArealiser,
                ['Semi-enterrée', 'Hors-sol'],
                (val) => setState(
                  () => _typeLatrinesArealiser = val ?? _typeLatrinesArealiser,
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown('Toit', _toit, [
                'Toit en béton',
                'Toit en bac alu',
              ], (val) => setState(() => _toit = val ?? _toit)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nbBlocsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de blocs de latrines à réaliser',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nbCabinesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de cabines à réaliser',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nbDLMController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de dispositifs de lave-mains à installer',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _autresTravauxController,
                decoration: const InputDecoration(labelText: 'Autres travaux'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _autrePreciserController,
                decoration: const InputDecoration(
                  labelText: 'Autre (à préciser)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('ENREGISTRER DONNÉES NIVEAU 1'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(Niveau2OrganisationChantier.routeName),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Aller à Niveau 2 - Organisation Chantier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? current,
    List<String>? items,
    ValueChanged<String?> onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: current,
          hint: Text('Sélectionnez $label'),
          items: items
              ?.map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
