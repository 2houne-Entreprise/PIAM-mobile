import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';

/// Formulaire — État des Lieux Localité
///
/// Pattern :
///   1. [FormHeaderWidget] fournit localiteId → déclenche [_loadSavedData]
///   2. [_loadSavedData] pré-remplit tous les champs depuis SQLite
///   3. [_save] valide + upsert dans SQLite
class EtatLieuxLocalitePage extends StatefulWidget {
  final String formulaireId;

  const EtatLieuxLocalitePage({Key? key, required this.formulaireId})
      : super(key: key);

  @override
  State<EtatLieuxLocalitePage> createState() => _EtatLieuxLocalitePageState();
}

class _EtatLieuxLocalitePageState extends State<EtatLieuxLocalitePage> {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  // Données de localisation
  int? _localiteId;
  dynamic _userId;

  // ── Controllers ───────────────────────────────────────────────────────────

  // Date
  final _dateController = TextEditingController();

  // Population
  final _nbPopulationController = TextEditingController();
  final _nbHommesController = TextEditingController();
  final _nbFemmesController = TextEditingController();
  final _nbEnfantsController = TextEditingController();
  final _nbMenagesController = TextEditingController();

  // Eau
  bool? _accesEau;
  final _sourceEauController = TextEditingController();
  final _nbMenagesSansEauController = TextEditingController();

  // Latrines
  final _nbLatrinesController = TextEditingController();
  final _nbLatrinesAAmeliorerController = TextEditingController();
  final _nbLatrinesAmelioreesController = TextEditingController();

  // État des latrines
  final _nbLatrinesEndommageesController = TextEditingController();
  final _nbMenagesLatrinesVoisinsController = TextEditingController();
  final _nbMenagesDefecationAirLibreController = TextEditingController();

  // DLM
  final _nbLatrinesAvecDLMController = TextEditingController();
  final _nbDLMEauSavonController = TextEditingController();
  final _nbDLMEauSansSavonController = TextEditingController();
  final _nbMenagesSansDLMController = TextEditingController();

  // Observations
  final _observationsController = TextEditingController();

  // ── Cycle de vie ──────────────────────────────────────────────────────────

  @override
  void dispose() {
    _dateController.dispose();
    _nbPopulationController.dispose();
    _nbHommesController.dispose();
    _nbFemmesController.dispose();
    _nbEnfantsController.dispose();
    _nbMenagesController.dispose();
    _sourceEauController.dispose();
    _nbMenagesSansEauController.dispose();
    _nbLatrinesController.dispose();
    _nbLatrinesAAmeliorerController.dispose();
    _nbLatrinesAmelioreesController.dispose();
    _nbLatrinesEndommageesController.dispose();
    _nbMenagesLatrinesVoisinsController.dispose();
    _nbMenagesDefecationAirLibreController.dispose();
    _nbLatrinesAvecDLMController.dispose();
    _nbDLMEauSavonController.dispose();
    _nbDLMEauSansSavonController.dispose();
    _nbMenagesSansDLMController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  // ── Chargement ────────────────────────────────────────────────────────────

  /// Appelé par [FormHeaderWidget] dès que localiteId est connu.
  void _onLocalisationLoaded(int? localiteId, dynamic userId) {
    setState(() {
      _localiteId = localiteId;
      _userId = userId;
    });
    if (localiteId != null) _loadSavedData(localiteId);
  }

  Future<void> _loadSavedData(int localiteId) async {
    final data = await DatabaseService().getQuestionnaire(
      type: 'etat_lieux_localite',
      localiteId: localiteId,
    );

    if (data == null || !mounted) return;

    _dateController.text = data['dateActivite'] ?? '';
    _nbPopulationController.text = data['nbPopulation']?.toString() ?? '';
    _nbHommesController.text = data['nbHommes']?.toString() ?? '';
    _nbFemmesController.text = data['nbFemmes']?.toString() ?? '';
    _nbEnfantsController.text = data['nbEnfants']?.toString() ?? '';
    _nbMenagesController.text = data['nbMenages']?.toString() ?? '';
    _sourceEauController.text = data['sourceEau'] ?? '';
    _nbMenagesSansEauController.text = data['nbMenagesSansEau']?.toString() ?? '';
    _nbLatrinesController.text = data['nbLatrines']?.toString() ?? '';
    _nbLatrinesAAmeliorerController.text = data['nbLatrinesAAmeliorer']?.toString() ?? '';
    _nbLatrinesAmelioreesController.text = data['nbLatrinesAmeliorees']?.toString() ?? '';
    _nbLatrinesEndommageesController.text = data['nbLatrinesEndommagees']?.toString() ?? '';
    _nbMenagesLatrinesVoisinsController.text = data['nbMenagesLatrinesVoisins']?.toString() ?? '';
    _nbMenagesDefecationAirLibreController.text = data['nbMenagesDefecationAirLibre']?.toString() ?? '';
    _nbLatrinesAvecDLMController.text = data['nbLatrinesAvecDLM']?.toString() ?? '';
    _nbDLMEauSavonController.text = data['nbDLM_EauSavon']?.toString() ?? '';
    _nbDLMEauSansSavonController.text = data['nbDLM_EauSansSavon']?.toString() ?? '';
    _nbMenagesSansDLMController.text = data['nbMenagesSansDLM']?.toString() ?? '';
    _observationsController.text = data['observations'] ?? '';

    // Restaurer la valeur du dropdown
    final accesEauVal = data['accesEau'];
    if (accesEauVal != null) {
      setState(() => _accesEau = accesEauVal as bool?);
    }

    if (mounted) setState(() => _isSaved = true);
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

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'dateActivite': _dateController.text,
        'nbPopulation': int.tryParse(_nbPopulationController.text),
        'nbHommes': int.tryParse(_nbHommesController.text),
        'nbFemmes': int.tryParse(_nbFemmesController.text),
        'nbEnfants': int.tryParse(_nbEnfantsController.text),
        'nbMenages': int.tryParse(_nbMenagesController.text),
        'accesEau': _accesEau,
        'sourceEau': _sourceEauController.text,
        'nbMenagesSansEau': int.tryParse(_nbMenagesSansEauController.text),
        'nbLatrines': int.tryParse(_nbLatrinesController.text),
        'nbLatrinesAAmeliorer': int.tryParse(_nbLatrinesAAmeliorerController.text),
        'nbLatrinesAmeliorees': int.tryParse(_nbLatrinesAmelioreesController.text),
        'nbLatrinesEndommagees': int.tryParse(_nbLatrinesEndommageesController.text),
        'nbMenagesLatrinesVoisins': int.tryParse(_nbMenagesLatrinesVoisinsController.text),
        'nbMenagesDefecationAirLibre': int.tryParse(_nbMenagesDefecationAirLibreController.text),
        'nbLatrinesAvecDLM': int.tryParse(_nbLatrinesAvecDLMController.text),
        'nbDLM_EauSavon': int.tryParse(_nbDLMEauSavonController.text),
        'nbDLM_EauSansSavon': int.tryParse(_nbDLMEauSansSavonController.text),
        'nbMenagesSansDLM': int.tryParse(_nbMenagesSansDLMController.text),
        'observations': _observationsController.text,
      };

      await DatabaseService().upsertQuestionnaire(
        type: 'etat_lieux_localite',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Données enregistrées avec succès'),
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
        title: const Text('État des Lieux – Localité'),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Localisation ─────────────────────────────────────────────
            FormHeaderWidget(onDataLoaded: _onLocalisationLoaded),

            // ── Date ─────────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                  title: 'Date de l\'activité',
                  icon: Icons.event_note,
                ),
                AppDateField(
                  label: 'Date de l\'activité',
                  controller: _dateController,
                  required: true,
                  lastDate: DateTime.now(),
                ),
              ],
            ),

            // ── Population ───────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(title: 'Population', icon: Icons.people),
                AppNumberField(
                  label: 'Nombre total de population',
                  controller: _nbPopulationController,
                  required: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppNumberField(
                        label: 'Hommes',
                        controller: _nbHommesController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppNumberField(
                        label: 'Femmes',
                        controller: _nbFemmesController,
                      ),
                    ),
                  ],
                ),
                AppNumberField(
                  label: 'Enfants de moins de 5 ans',
                  controller: _nbEnfantsController,
                ),
                AppNumberField(
                  label: 'Nombre de ménages',
                  controller: _nbMenagesController,
                  required: true,
                ),
              ],
            ),

            // ── Accès à l'eau ────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Accès à l\'eau', icon: Icons.water_drop),
                AppDropdownField<bool>(
                  label: 'Accès à l\'eau potable',
                  value: _accesEau,
                  required: true,
                  prefixIcon: Icons.water,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Oui')),
                    DropdownMenuItem(value: false, child: Text('Non')),
                  ],
                  onChanged: (v) => setState(() => _accesEau = v),
                ),
                if (_accesEau == true)
                  AppTextField(
                    label: 'Source d\'eau (forage, puits, etc.)',
                    controller: _sourceEauController,
                    prefixIcon: Icons.location_on,
                  ),
                if (_accesEau == false)
                  AppNumberField(
                    label: 'Ménages sans accès à l\'eau',
                    controller: _nbMenagesSansEauController,
                  ),
              ],
            ),

            // ── Latrines ─────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Assainissement (latrines)', icon: Icons.sanitizer),
                AppNumberField(
                  label: 'Nombre total de latrines familiales',
                  controller: _nbLatrinesController,
                  required: true,
                ),
                AppNumberField(
                  label: 'Latrines à améliorer',
                  controller: _nbLatrinesAAmeliorerController,
                ),
                AppNumberField(
                  label: 'Latrines améliorées',
                  controller: _nbLatrinesAmelioreesController,
                ),
              ],
            ),

            // ── État des latrines ─────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'État des latrines',
                    icon: Icons.home_repair_service),
                AppNumberField(
                  label: 'Latrines endommagées',
                  controller: _nbLatrinesEndommageesController,
                ),
                AppNumberField(
                  label: 'Ménages utilisant latrines des voisins',
                  controller: _nbMenagesLatrinesVoisinsController,
                ),
                AppNumberField(
                  label: 'Ménages pratiquant la défécation à l\'air libre',
                  controller: _nbMenagesDefecationAirLibreController,
                ),
              ],
            ),

            // ── DLM ───────────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                  title: 'Dispositif de lavage des mains (DLM)',
                  icon: Icons.wash,
                ),
                AppNumberField(
                  label: 'Latrines avec DLM',
                  controller: _nbLatrinesAvecDLMController,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppNumberField(
                        label: 'Eau + savon',
                        controller: _nbDLMEauSavonController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppNumberField(
                        label: 'Eau sans savon',
                        controller: _nbDLMEauSansSavonController,
                      ),
                    ),
                  ],
                ),
                AppNumberField(
                  label: 'Ménages sans DLM',
                  controller: _nbMenagesSansDLMController,
                ),
              ],
            ),

            // ── Observations ──────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Observations', icon: Icons.comment_outlined),
                AppTextField(
                  label: 'Remarques de l\'enquêteur',
                  controller: _observationsController,
                  maxLines: 3,
                  prefixIcon: Icons.edit_note,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Bouton enregistrer ────────────────────────────────────────
            AppSubmitButton(
              label: 'Enregistrer',
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
