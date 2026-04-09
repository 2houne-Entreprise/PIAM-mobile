import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/data/reference_data.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/services/database_service.dart';

/// Formulaire 2 — Identification du site
///
/// Ce formulaire peut être rempli indépendamment du paramétrage initial.
/// Il permet à l'utilisateur de choisir manuellement la localisation
/// (wilaya, moughataa, commune, localité) et de saisir les infos du projet.
class IdentificationPage extends StatefulWidget {
  final String formulaireId;

  const IdentificationPage({Key? key, required this.formulaireId})
      : super(key: key);

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  // Localisation en cascade (sélections)
  int? _selectedWilayaId;
  int? _selectedMoughataaId;
  int? _selectedCommuneId;
  int? _selectedLocaliteId;

  List<Map<String, dynamic>> _moughataas = [];
  List<Map<String, dynamic>> _communes = [];
  List<Map<String, dynamic>> _localites = [];

  // ── Controllers ───────────────────────────────────────────────────────────
  final _codeAnsadeController = TextEditingController();
  final _intituleProjetController = TextEditingController();
  final _marcheTravauxController = TextEditingController();
  final _numeroMarcheController = TextEditingController();
  final _nomEntrepriseController = TextEditingController();
  final _delaiMarcheController = TextEditingController();
  final _bureauControleController = TextEditingController();
  final _nomControleurController = TextEditingController();
  final _effectifController = TextEditingController();
  final _nbPotentielsController = TextEditingController();

  // Type d'établissement sélectionné
  String _etablissement = 'Ecole fondamentale';

  static const List<String> _etablissements = [
    'Ecole fondamentale',
    'Lycée',
    'Centre de santé',
    'Poste de santé',
    'Mairie',
    'Mosquée',
    'Autre',
  ];

  // ── Cycle de vie ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Le chargement des données sauvegardées se fait dans
    // _onLocaliteChanged() quand l'utilisateur sélectionne une localité,
    // OU au démarrage si le paramétrage a une localité enregistrée
    _tryLoadFromParametrage();
  }

  @override
  void dispose() {
    _codeAnsadeController.dispose();
    _intituleProjetController.dispose();
    _marcheTravauxController.dispose();
    _numeroMarcheController.dispose();
    _nomEntrepriseController.dispose();
    _delaiMarcheController.dispose();
    _bureauControleController.dispose();
    _nomControleurController.dispose();
    _effectifController.dispose();
    _nbPotentielsController.dispose();
    super.dispose();
  }

  // ── Chargement ────────────────────────────────────────────────────────────

  /// Essaie de récupérer la localité depuis le paramétrage et pré-charge les données.
  Future<void> _tryLoadFromParametrage() async {
    final param = await DatabaseService().getParametreUtilisateur();
    if (param == null || !mounted) return;

    final wilayaId = param['wilaya_id'] as int?;
    final moughataaId = param['moughataa_id'] as int?;
    final communeId = param['commune_id'] as int?;
    final localiteId = param['localite_id'] as int?;

    if (wilayaId == null) return;

    setState(() {
      _selectedWilayaId = wilayaId;
      _moughataas = ReferenceData.getMoughatasByWilaya(wilayaId);
      if (moughataaId != null) {
        _selectedMoughataaId = moughataaId;
        _communes = ReferenceData.getCommunesByMoughataa(moughataaId);
        if (communeId != null) {
          _selectedCommuneId = communeId;
          _localites = ReferenceData.getLocalitesByCommune(communeId);
          if (localiteId != null) {
            _selectedLocaliteId = localiteId;
          }
        }
      }
    });

    if (localiteId != null) {
      await _loadSavedData(localiteId);
    }
  }

  /// Charge les données du formulaire d'identification pour une localité donnée.
  Future<void> _loadSavedData(int localiteId) async {
    final data = await DatabaseService().getQuestionnaire(
      type: 'identification',
      localiteId: localiteId,
    );

    if (data == null || !mounted) return;

    _codeAnsadeController.text = data['codeAnsade'] ?? '';
    _intituleProjetController.text = data['intituleProjet'] ?? '';
    _marcheTravauxController.text = data['marcheTravaux'] ?? '';
    _numeroMarcheController.text = data['numeroMarche'] ?? '';
    _nomEntrepriseController.text = data['nomEntreprise'] ?? '';
    _delaiMarcheController.text = data['delaiMarche']?.toString() ?? '';
    _bureauControleController.text = data['bureauControle'] ?? '';
    _nomControleurController.text = data['nomControleur'] ?? '';
    _effectifController.text = data['effectif']?.toString() ?? '';
    _nbPotentielsController.text = data['nbPotentiels']?.toString() ?? '';

    if (data['typeEtablissement'] != null &&
        _etablissements.contains(data['typeEtablissement'])) {
      setState(() => _etablissement = data['typeEtablissement']);
    }

    if (mounted) setState(() => _isSaved = true);
  }

  // ── Navigation en cascade (wilaya → moughataa → commune → localité) ───────

  void _onWilayaChanged(int? wilayaId) {
    setState(() {
      _selectedWilayaId = wilayaId;
      _selectedMoughataaId = null;
      _selectedCommuneId = null;
      _selectedLocaliteId = null;
      _moughataas = wilayaId != null
          ? ReferenceData.getMoughatasByWilaya(wilayaId)
          : [];
      _communes = [];
      _localites = [];
      _isSaved = false;
    });
    _clearControllers();
  }

  void _onMoughataaChanged(int? moughataaId) {
    setState(() {
      _selectedMoughataaId = moughataaId;
      _selectedCommuneId = null;
      _selectedLocaliteId = null;
      _communes = moughataaId != null
          ? ReferenceData.getCommunesByMoughataa(moughataaId)
          : [];
      _localites = [];
      _isSaved = false;
    });
    _clearControllers();
  }

  void _onCommuneChanged(int? communeId) {
    setState(() {
      _selectedCommuneId = communeId;
      _selectedLocaliteId = null;
      _localites = communeId != null
          ? ReferenceData.getLocalitesByCommune(communeId)
          : [];
      _isSaved = false;
    });
    _clearControllers();
  }

  void _onLocaliteChanged(int? localiteId) {
    setState(() {
      _selectedLocaliteId = localiteId;
      _isSaved = false;
    });
    _clearControllers();
    if (localiteId != null) _loadSavedData(localiteId);
  }

  /// Efface tous les champs quand la localité change pour éviter la confusion.
  void _clearControllers() {
    _codeAnsadeController.clear();
    _intituleProjetController.clear();
    _marcheTravauxController.clear();
    _numeroMarcheController.clear();
    _nomEntrepriseController.clear();
    _delaiMarcheController.clear();
    _bureauControleController.clear();
    _nomControleurController.clear();
    _effectifController.clear();
    _nbPotentielsController.clear();
  }

  // ── Enregistrement ────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant d\'enregistrer'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedLocaliteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une localité'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'wilayaId': _selectedWilayaId,
        'moughataaId': _selectedMoughataaId,
        'communeId': _selectedCommuneId,
        'localiteId': _selectedLocaliteId,
        'typeEtablissement': _etablissement,
        'codeAnsade': _codeAnsadeController.text,
        'intituleProjet': _intituleProjetController.text,
        'marcheTravaux': _marcheTravauxController.text,
        'numeroMarche': _numeroMarcheController.text,
        'nomEntreprise': _nomEntrepriseController.text,
        'delaiMarche': int.tryParse(_delaiMarcheController.text),
        'bureauControle': _bureauControleController.text,
        'nomControleur': _nomControleurController.text,
        'effectif': int.tryParse(_effectifController.text),
        'nbPotentiels': int.tryParse(_nbPotentielsController.text),
      };

      await DatabaseService().upsertQuestionnaire(
        type: 'identification',
        localiteId: _selectedLocaliteId,
        dataMap: dataMap,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Identification enregistrée avec succès'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Identification du site'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isSaved)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AppStatusBadge(
                label: 'Enregistré',
                color: AppTheme.successColor,
                icon: Icons.check_circle_outline,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppInfoBanner(
                    message:
                        'Remplissez les informations d\'identification du site. Les données sont sauvegardées localement.',
                  ),

                  // ── A. Localisation ───────────────────────────────────
                  AppFormCard(
                    children: [
                      AppSectionTitle(
                        title: 'A. Localisation géographique',
                        icon: Icons.location_on,
                      ),
                      AppDropdownField<int>(
                        label: 'Wilaya',
                        value: _selectedWilayaId,
                        required: true,
                        prefixIcon: Icons.map,
                        items: ReferenceData.wilayas
                            .map((w) => DropdownMenuItem<int>(
                                  value: w['id'] as int,
                                  child: Text(w['intitule'] as String),
                                ))
                            .toList(),
                        onChanged: _onWilayaChanged,
                      ),
                      AppDropdownField<int>(
                        label: 'Moughataa',
                        value: _selectedMoughataaId,
                        enabled: _selectedWilayaId != null,
                        prefixIcon: Icons.map_outlined,
                        items: _moughataas
                            .map((m) => DropdownMenuItem<int>(
                                  value: m['id'] as int,
                                  child: Text(m['intitule'] as String),
                                ))
                            .toList(),
                        onChanged: _onMoughataaChanged,
                      ),
                      AppDropdownField<int>(
                        label: 'Commune',
                        value: _selectedCommuneId,
                        enabled: _selectedMoughataaId != null,
                        prefixIcon: Icons.location_city,
                        items: _communes
                            .map((c) => DropdownMenuItem<int>(
                                  value: c['id'] as int,
                                  child: Text(c['intitule'] as String),
                                ))
                            .toList(),
                        onChanged: _onCommuneChanged,
                      ),
                      AppDropdownField<int>(
                        label: 'Localité',
                        value: _selectedLocaliteId,
                        required: true,
                        enabled: _selectedCommuneId != null,
                        prefixIcon: Icons.home_outlined,
                        items: _localites
                            .map((l) => DropdownMenuItem<int>(
                                  value: l['id'] as int,
                                  child: Text(l['intitule'] as String),
                                ))
                            .toList(),
                        onChanged: _onLocaliteChanged,
                      ),
                      AppTextField(
                        label: 'Code ANSADE',
                        controller: _codeAnsadeController,
                        required: true,
                        prefixIcon: Icons.code,
                        hint: 'Ex: 01-1-01-001',
                      ),
                      AppDropdownField<String>(
                        label: 'Type d\'établissement',
                        value: _etablissement,
                        prefixIcon: Icons.business,
                        items: _etablissements
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _etablissement = v ?? _etablissement),
                      ),
                    ],
                  ),

                  // ── B. Marché des travaux ────────────────────────────
                  AppFormCard(
                    children: [
                      AppSectionTitle(
                        title: 'B. Marché des travaux',
                        icon: Icons.description,
                      ),
                      AppTextField(
                        label: 'Intitulé du projet',
                        controller: _intituleProjetController,
                        required: true,
                        prefixIcon: Icons.assignment,
                      ),
                      AppTextField(
                        label: 'Marché des travaux',
                        controller: _marcheTravauxController,
                        prefixIcon: Icons.article,
                      ),
                      AppTextField(
                        label: 'Numéro du marché',
                        controller: _numeroMarcheController,
                        prefixIcon: Icons.numbers,
                      ),
                      AppTextField(
                        label: 'Nom de l\'entreprise',
                        controller: _nomEntrepriseController,
                        prefixIcon: Icons.business_center,
                      ),
                      AppNumberField(
                        label: 'Délai du marché (jours)',
                        controller: _delaiMarcheController,
                        prefixIcon: Icons.timer_outlined,
                      ),
                    ],
                  ),

                  // ── C. Contrôle des travaux ──────────────────────────
                  AppFormCard(
                    children: [
                      AppSectionTitle(
                        title: 'C. Contrôle des travaux',
                        icon: Icons.verified,
                      ),
                      AppTextField(
                        label: 'Bureau de contrôle',
                        controller: _bureauControleController,
                        prefixIcon: Icons.account_balance,
                      ),
                      AppTextField(
                        label: 'Nom du contrôleur',
                        controller: _nomControleurController,
                        prefixIcon: Icons.person,
                      ),
                    ],
                  ),

                  // ── D. Population ────────────────────────────────────
                  AppFormCard(
                    children: [
                      AppSectionTitle(
                        title: 'D. Population concernée',
                        icon: Icons.people,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: AppNumberField(
                              label: 'Effectif',
                              controller: _effectifController,
                              prefixIcon: Icons.group,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppNumberField(
                              label: 'Nb. potentiels',
                              controller: _nbPotentielsController,
                              prefixIcon: Icons.people_outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Bouton ───────────────────────────────────────────
                  AppSubmitButton(
                    label: 'Enregistrer l\'identification',
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
