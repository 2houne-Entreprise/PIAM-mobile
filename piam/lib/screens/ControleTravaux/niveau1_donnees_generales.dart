import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/form_auto_sync_mixin.dart';
import '../../presentation/widgets/app_form_fields.dart';
import 'niveau2_organisation_chantier.dart';
import '../../data/reference_data.dart';

class Niveau1DonneesGenerales extends StatefulWidget {
  static const String routeName = '/niveau1';
  const Niveau1DonneesGenerales({super.key});

  @override
  State<Niveau1DonneesGenerales> createState() =>
      _Niveau1DonneesGeneralesState();
}

class _Niveau1DonneesGeneralesState extends State<Niveau1DonneesGenerales> with FormAutoSyncMixin {
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

  final DatabaseService _dbService = DatabaseService();
  static const String _formType = 'controle_travaux_n1';

  String? _wilaya;
  String? _moughataa;
  String? _commune;
  String? _localite;
  String _etablissement = 'Ecole fondamentale';
  String _typeLatrines = 'Semi-enterrée';
  bool _destructionAncienne = false;
  bool _constructionMur = false;
  List<String> _wilayas = [];
  List<String> _moughataas = [];
  List<String> _communes = [];
  List<String> _localites = [];
  List<String> _sitesInfrastructure = [];

  final Map<String, int> _wilayaIds = {};
  final Map<String, int> _moughataaIds = {};
  final Map<String, int> _communeIds = {};
  final Map<String, int> _localiteIds = {};
  final Map<String, String?> _localiteCodeAnsade = {};
  final Map<String, String> _siteLabelsToName = {};
  final Map<String, int> _siteLabelsToId = {};
  final Map<String, String?> _siteLabelsToType = {};
  final Map<String, String?> _siteLabelsToCode = {};

  String? _siteSelectionne;
  bool _isGeoLoading = true;
  Map<String, dynamic>? _paramInit;
  bool _isLoading = false;

  bool get _isEcole => _etablissement == 'Ecole fondamentale';
  bool get _isStructureSante =>
      _etablissement == 'Centre de santé' || _etablissement == 'Poste de Santé';

  List<String>? _infrastructureTypesForEtablissement() {
    switch (_etablissement) {
      case 'Ecole fondamentale':
        return const ['ECOLE'];
      case 'Centre de santé':
        return const ['CENTRE DE SANTE', 'CENTRE DE SANTÉ'];
      case 'Poste de Santé':
        return const ['POSTE DE SANTE', 'POSTE DE SANTÉ'];
      case 'Gare routière':
        return const ['GARE ROUTIERE', 'GARE ROUTIÈRE'];
      case 'Marché':
        return const ['MARCHE', 'MARCHÉ'];
      case 'Mosquée':
        return const ['MOSQUEE', 'MOSQUÉE'];
      case 'Bâtiment administratif':
        return const ['BATIMENT ADMINISTRATIF', 'BÂTIMENT ADMINISTRATIF'];
      default:
        return null;
    }
  }

  String get _codeANSADE => _localiteCodeAnsade[_localite] ?? '-';

  // (supprimé doublon)

  Future<void> _initializeForm() async {
    await _loadWilayas();
    await _prefillFromConfiguredSite();
  }

  Future<void> _prefillFromConfiguredSite() async {
    // Préremplissage désactivé (getConfigValue n'existe pas dans DatabaseService)
    return;
  }

  Future<void> _loadWilayas() async {
    setState(() {
      _isGeoLoading = true;
    });

    final rows = await _dbService.getWilayas();
    if (!mounted) return;

    setState(() {
      _wilayaIds
        ..clear()
        ..addEntries(
          rows.map((row) {
            final name = (row['intitule_fr']?.toString().isNotEmpty ?? false)
                ? row['intitule_fr'].toString()
                : row['intitule'].toString();
            return MapEntry(name, (row['id'] as int?) ?? 0);
          }),
        );
      _wilayas = _wilayaIds.keys.toList();
      _isGeoLoading = false;
    });
  }

  String? _getWilayaName(dynamic id) {
    if (id == null) return '-';
    final entry = ReferenceData.wilayas.firstWhere(
      (w) => w['id'].toString() == id.toString(),
      orElse: () => {},
    );
    return entry['intitule_fr'] ?? entry['intitule'] ?? '-';
  }

  String? _getMoughataaName(dynamic id) {
    if (id == null) return '-';
    final entry = ReferenceData.moughatas.firstWhere(
      (m) => m['id'].toString() == id.toString(),
      orElse: () => {},
    );
    return entry['intitule_fr'] ?? entry['intitule'] ?? '-';
  }

  String? _getCommuneName(dynamic id) {
    if (id == null) return '-';
    final entry = ReferenceData.communes.firstWhere(
      (c) => c['id'].toString() == id.toString(),
      orElse: () => {},
    );
    return entry['intitule_fr'] ?? entry['intitule'] ?? '-';
  }

  String? _getLocaliteName(dynamic id) {
    if (id == null) return '-';
    final entry = ReferenceData.localites.firstWhere(
      (l) => l['id'].toString() == id.toString(),
      orElse: () => {},
    );
    return entry['intitule_fr'] ?? entry['intitule'] ?? '-';
  }

  // Duplicate build method and misplaced code removed. Only one build method remains.

  Future<void> _loadLocalites(String commune) async {
    final communeId = _communeIds[commune];
    if (communeId == null) return;

    final rows = await _dbService.getLocalites(communeId);
    if (!mounted) return;

    setState(() {
      _localiteCodeAnsade.clear();
      _localiteIds.clear();
      _localites = rows.map((row) {
        final name = (row['intitule_fr']?.toString().isNotEmpty ?? false)
            ? row['intitule_fr'].toString()
            : row['intitule'].toString();
        _localiteIds[name] = (row['id'] as int?) ?? 0;
        _localiteCodeAnsade[name] = row['code_ansade']?.toString();
        return name;
      }).toList();
      _localite = null;
      _sitesInfrastructure = [];
      _siteSelectionne = null;
      _siteLabelsToName.clear();
    });
  }

  Future<void> _loadSitesInfrastructure(String localite) async {
    final localiteId = _localiteIds[localite];
    if (localiteId == null) return;

    final rows = await _dbService.getInfrastructures(
      localiteId,
      infrastructureTypes: _infrastructureTypesForEtablissement(),
    );
    if (!mounted) return;

    setState(() {
      _siteLabelsToName.clear();
      _siteLabelsToId.clear();
      _siteLabelsToType.clear();
      _siteLabelsToCode.clear();
      _sitesInfrastructure = (rows is List)
          ? rows.map<String>((row) {
              final id = (row['id'] as int?) ?? 0;
              final nom = row['intitule_infra_publ']?.toString() ?? '';
              final type = row['infra_publ']?.toString() ?? '';
              final code = row['code_infra_publ']?.toString();
              final label = (code != null && code.isNotEmpty)
                  ? '$nom ($type - $code)'
                  : '$nom ($type)';
              _siteLabelsToName[label] = nom;
              _siteLabelsToId[label] = id;
              _siteLabelsToType[label] = type;
              _siteLabelsToCode[label] = code;
              return label;
            }).toList()
          : [];
      _siteSelectionne = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'projectName': _projectNameController.text.trim(),
      'companyName': _companyNameController.text.trim(),
      'wilaya': _wilaya ?? '',
      'wilayaId': _wilayaIds[_wilaya]?.toString() ?? '',
      'moughataaId': _moughataaIds[_moughataa]?.toString() ?? '',
      'communeId': _communeIds[_commune]?.toString() ?? '',
      'localiteId': _localiteIds[_localite]?.toString() ?? '',
      'codeAnsade': _codeANSADE,
      'etablissement': _etablissement,
      'infrastructureId': _siteLabelsToId[_siteSelectionne]?.toString() ?? '',
      'infrastructureType': _siteLabelsToType[_siteSelectionne]?.toString() ?? '',
      'infrastructureCode': _siteLabelsToCode[_siteSelectionne]?.toString() ?? '',
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
      'codeMesre': _codeMesreController.text.trim(),
      'codeMs': _codeMsController.text.trim(),
      'effectif': int.tryParse(_effectifController.text) ?? 0,
      'nbPotentiels': int.tryParse(_nbPotentielsController.text) ?? 0,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Use current site ID from initial parameters if form hasn't explicitly selected one
    final activeLocaliteId = _localiteIds[_localite] ?? _paramInit?['localite_id'];

    setState(() => _isLoading = true);
    try {
      await saveAndSync(
        type: _formType,
        localiteId: activeLocaliteId,
        dataMap: data,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Projet sauvegardé')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadParametrageInitial();
    
    // Ajout des listeners pour l'auto-save
    _projectNameController.addListener(_triggerAutoSave);
    _companyNameController.addListener(_triggerAutoSave);
    _codeMesreController.addListener(_triggerAutoSave);
    _codeMsController.addListener(_triggerAutoSave);
    _effectifController.addListener(_triggerAutoSave);
    _nbPotentielsController.addListener(_triggerAutoSave);
    _intituleProjetController.addListener(_triggerAutoSave);
    _marcheTravauxController.addListener(_triggerAutoSave);
    _numeroMarcheController.addListener(_triggerAutoSave);
    _nomEntrepriseMarcheController.addListener(_triggerAutoSave);
    _delaiMarcheController.addListener(_triggerAutoSave);
    _dateDemarrageMarcheController.addListener(_triggerAutoSave);
    _marcheControleTravauxController.addListener(_triggerAutoSave);
    _numeroMarcheControleController.addListener(_triggerAutoSave);
    _bureauControleController.addListener(_triggerAutoSave);
    _nomControleurController.addListener(_triggerAutoSave);
    _latrinesArealiserController.addListener(_triggerAutoSave);
    _nbBlocsController.addListener(_triggerAutoSave);
    _nbCabinesController.addListener(_triggerAutoSave);
    _nbDLMController.addListener(_triggerAutoSave);
    _autresTravauxController.addListener(_triggerAutoSave);
    _autrePreciserController.addListener(_triggerAutoSave);
  }

  bool _isRestoring = false;

  void _triggerAutoSave() {
    if (_isRestoring) return;
    
    final activeLocaliteId = _localiteIds[_localite] ?? _paramInit?['localite_id'];
    
    onFieldChanged(
      type: _formType,
      localiteId: activeLocaliteId,
      dataProvider: () => _getFormData(),
    );
  }

  Map<String, dynamic> _getFormData() {
    return {
      'projectName': _projectNameController.text.trim(),
      'companyName': _companyNameController.text.trim(),
      'wilaya': _wilaya ?? '',
      'wilayaId': _wilayaIds[_wilaya]?.toString() ?? '',
      'moughataaId': _moughataaIds[_moughataa]?.toString() ?? '',
      'communeId': _communeIds[_commune]?.toString() ?? '',
      'localiteId': _localiteIds[_localite]?.toString() ?? '',
      'codeAnsade': _codeANSADE,
      'etablissement': _etablissement,
      'infrastructureId': _siteLabelsToId[_siteSelectionne]?.toString() ?? '',
      'infrastructureType': _siteLabelsToType[_siteSelectionne]?.toString() ?? '',
      'infrastructureCode': _siteLabelsToCode[_siteSelectionne]?.toString() ?? '',
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
      'codeMesre': _codeMesreController.text.trim(),
      'codeMs': _codeMsController.text.trim(),
      'effectif': int.tryParse(_effectifController.text) ?? 0,
      'nbPotentiels': int.tryParse(_nbPotentielsController.text) ?? 0,
      'updatedAt': DateTime.now().toIso8601String(),
    };
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

  Future<void> _loadParametrageInitial() async {
    final param = await _dbService.getParametreUtilisateur();
    if (mounted) setState(() => _paramInit = param);
    // Après avoir chargé le paramétrage, charger le brouillon
    await _loadDraft();
  }

  /// Charge les données sauvegardées (brouillon ou complet) et pré-remplit les champs
  Future<void> _loadDraft() async {
    final draft = await _dbService.getQuestionnaire(
      type: _formType,
      localiteId: _paramInit?['localite_id'],
    );
    
    if (draft == null || !mounted) return;

    _isRestoring = true;
    setState(() {
      _projectNameController.text = draft['projectName'] ?? '';
      _companyNameController.text = draft['companyName'] ?? '';
      _codeMesreController.text = draft['codeMesre'] ?? '';
      _codeMsController.text = draft['codeMs'] ?? '';
      _effectifController.text = draft['effectif']?.toString() ?? '';
      _nbPotentielsController.text = draft['nbPotentiels']?.toString() ?? '';
      _intituleProjetController.text = draft['intituleProjet'] ?? '';
      _marcheTravauxController.text = draft['marcheTravaux'] ?? '';
      _numeroMarcheController.text = draft['numeroMarche'] ?? '';
      _nomEntrepriseMarcheController.text = draft['nomEntreprise'] ?? '';
      _delaiMarcheController.text = draft['delaiMarche'] ?? '';
      _dateDemarrageMarcheController.text = draft['dateDemarrageMarche'] ?? '';
      _marcheControleTravauxController.text = draft['marcheControleTravaux'] ?? '';
      _numeroMarcheControleController.text = draft['numeroMarcheControle'] ?? '';
      _bureauControleController.text = draft['bureauControle'] ?? '';
      _nomControleurController.text = draft['nomControleur'] ?? '';
      _latrinesArealiserController.text = draft['latrinesArealiser'] ?? '';
      _nbBlocsController.text = draft['nbBlocs']?.toString() ?? '';
      _nbCabinesController.text = draft['nbCabines']?.toString() ?? '';
      _nbDLMController.text = draft['nbDLM']?.toString() ?? '';
      _autresTravauxController.text = draft['autresTravaux'] ?? '';
      _autrePreciserController.text = draft['autrePreciser'] ?? '';
      if (draft['etablissement'] != null) _etablissement = draft['etablissement'];
      if (draft['typeLatrinesArealiser'] != null) _typeLatrinesArealiser = draft['typeLatrinesArealiser'];
      if (draft['toit'] != null) _toit = draft['toit'];
      _destructionAncienne = draft['destructionAnciennes'] == 'Oui';
      _constructionMur = draft['constructionMur'] == 'Oui';
    });
    _isRestoring = false;
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
                'A. Localisation (Paramétrage initial)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (_paramInit == null)
                const Center(child: CircularProgressIndicator()),
              if (_paramInit != null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wilaya :   9${_paramInit?['wilaya_nom'] ?? _paramInit?['wilaya_id'] ?? '-'}',
                        ),
                        Text(
                          'Moughataa :   9${_paramInit?['moughataa_nom'] ?? _paramInit?['moughataa_id'] ?? '-'}',
                        ),
                        Text(
                          'Commune :   9${_paramInit?['commune_nom'] ?? _paramInit?['commune_id'] ?? '-'}',
                        ),
                        Text(
                          'Localité :   9${_paramInit?['localite_nom'] ?? _paramInit?['localite_id'] ?? '-'}',
                        ),
                        Text(
                          'GPS :   9${_paramInit?['gps_lat'] ?? '-'}, ${_paramInit?['gps_lng'] ?? '-'}',
                        ),
                      ],
                    ),
                  ),
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
                  final newValue = val ?? _etablissement;
                  setState(() => _etablissement = newValue);
                  if (_localite != null) {
                    _loadSitesInfrastructure(_localite!);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Site référencé (optionnel)',
                _siteSelectionne,
                _sitesInfrastructure,
                (val) {
                  setState(() {
                    _siteSelectionne = val;
                    if (val != null) {
                      _projectNameController.text =
                          _siteLabelsToName[val] ?? '';
                    }
                  });
                },
              ),
              if (_localite != null && _sitesInfrastructure.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Aucun site référencé trouvé pour cette localité.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Nom du site',
                controller: _projectNameController,
                required: true,
              ),
              AppTextField(
                label: 'Nom de l\'entreprise',
                controller: _companyNameController,
                required: true,
              ),
              const SizedBox(height: 8),
              if (_isEcole) ...[
                AppTextField(
                  label: 'Code MESRE',
                  controller: _codeMesreController,
                  hint: 'En attendant codification MESRE',
                ),
                const SizedBox(height: 8),
                AppNumberField(
                  label: 'Effectif de l\'école',
                  controller: _effectifController,
                ),
                const SizedBox(height: 8),
              ],
              if (_isStructureSante) ...[
                AppTextField(
                  label: 'Code MS',
                  controller: _codeMsController,
                  hint: 'En attendant codification MS',
                ),
                const SizedBox(height: 8),
              ],
              AppNumberField(
                label: 'Nb potentiels d\'usagers',
                controller: _nbPotentielsController,
              ),

              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'B. Données des marchés',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Intitulé du projet',
                controller: _intituleProjetController,
              ),
              AppTextField(
                label: 'Marché de travaux',
                controller: _marcheTravauxController,
              ),
              AppTextField(
                label: 'Numéro du marché',
                controller: _numeroMarcheController,
              ),
              AppTextField(
                label: 'Nom de l\'entreprise',
                controller: _nomEntrepriseMarcheController,
              ),
              AppNumberField(
                label: 'Délai du marché (en jours ou mois)',
                controller: _delaiMarcheController,
              ),
              AppDateField(
                label: 'Date de démarrage du marché',
                controller: _dateDemarrageMarcheController,
              ),
              AppTextField(
                label: 'Marché de contrôle des travaux',
                controller: _marcheControleTravauxController,
              ),
              AppTextField(
                label: 'Numéro du marché de contrôle',
                controller: _numeroMarcheControleController,
              ),
              AppTextField(
                label: 'Bureau chargé du contrôle',
                controller: _bureauControleController,
              ),
              AppTextField(
                label: 'Nom du contrôleur',
                controller: _nomControleurController,
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
              AppTextField(
                label: 'Latrines à réaliser',
                controller: _latrinesArealiserController,
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
              AppNumberField(
                label: 'Nombre de blocs de latrines à réaliser',
                controller: _nbBlocsController,
              ),
              const SizedBox(height: 8),
              AppNumberField(
                label: 'Nombre de cabines à réaliser',
                controller: _nbCabinesController,
              ),
              const SizedBox(height: 8),
              AppNumberField(
                label: 'Nombre de dispositifs de lave-mains à installer',
                controller: _nbDLMController,
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Autres travaux',
                controller: _autresTravauxController,
              ),
              AppTextField(
                label: 'Autre (à préciser)',
                controller: _autrePreciserController,
                maxLines: 2,
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
