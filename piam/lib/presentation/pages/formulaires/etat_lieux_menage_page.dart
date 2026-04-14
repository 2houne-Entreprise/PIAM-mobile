import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';
import 'package:piam/services/image_handler_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';


/// Formulaire — État des Lieux Ménage
///
/// Collecte composition du ménage, accès eau, statut latrine et DLM.
/// Inclut une preuve photo optionnelle.
class EtatLieuxMenagePage extends StatefulWidget {
  final String formulaireId;

  const EtatLieuxMenagePage({Key? key, required this.formulaireId})
      : super(key: key);

  @override
  State<EtatLieuxMenagePage> createState() => _EtatLieuxMenagePageState();
}

class _EtatLieuxMenagePageState extends State<EtatLieuxMenagePage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageHandlerService();
  bool _isLoading = false;
  bool _isSaved = false;
  String? _syncStatus; // 'draft', 'completed', 'synced'

  // Localisation
  int? _localiteId;
  dynamic _userId;

  // ── Controllers ───────────────────────────────────────────────────────────
  final _dateController = TextEditingController();
  final _nbTotalController = TextEditingController();
  final _nbHommesController = TextEditingController();
  final _nbFemmesController = TextEditingController();
  final _nbEnfantsController = TextEditingController();
  final _difficulteEauController = TextEditingController();
  final _observationsController = TextEditingController();

  // ── Variables d'état pour radios/dropdowns ────────────────────────────────
  bool? _accesEau;
  bool? _latrinesExiste;
  String? _typeLatrine;
  bool? _latrineAmelioree;
  bool? _latrineDegradee;
  bool? _latrineUsageToujours;
  bool? _latrineVoisin;
  bool? _latrineDefecation;
  bool? _latrineVoisinNon;
  bool? _latrineDefecationNon;
  bool? _dlmExiste;
  String? _typeDLM;
  String? _photoPath;

  // ── Cycle de vie ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    onSyncStatusChanged = (status) {
      if (mounted) setState(() => _syncStatus = status);
    };
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nbTotalController.dispose();
    _nbHommesController.dispose();
    _nbFemmesController.dispose();
    _nbEnfantsController.dispose();
    _difficulteEauController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  // ── Chargement ────────────────────────────────────────────────────────────

  void _onLocalisationLoaded(int? localiteId, dynamic userId) {
    setState(() {
      _localiteId = localiteId;
      _userId = userId;
    });
    if (localiteId != null) _loadSavedData(localiteId);
  }

  Future<void> _loadSavedData(int localiteId) async {
    final data = await DatabaseService().getQuestionnaire(
      type: 'etat_lieux_menage',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    _dateController.text = data['dateActivite'] ?? '';
    _nbTotalController.text = data['nbTotal']?.toString() ?? '';
    _nbHommesController.text = data['nbHommes']?.toString() ?? '';
    _nbFemmesController.text = data['nbFemmes']?.toString() ?? '';
    _nbEnfantsController.text = data['nbEnfants']?.toString() ?? '';
    _difficulteEauController.text = data['difficulteEau'] ?? '';
    _observationsController.text = data['observations'] ?? '';

    setState(() {
      _accesEau = data['accesEau'] as bool?;
      _latrinesExiste = data['latrinesExiste'] as bool?;
      _typeLatrine = data['typeLatrine'] as String?;
      _latrineAmelioree = data['latrineAmelioree'] as bool?;
      _latrineDegradee = data['latrineDegradee'] as bool?;
      _latrineUsageToujours = data['latrineUsageToujours'] as bool?;
      _latrineVoisin = data['latrineVoisin'] as bool?;
      _latrineDefecation = data['latrineDefecation'] as bool?;
      _latrineVoisinNon = data['latrineVoisinNon'] as bool?;
      _latrineDefecationNon = data['latrineDefecationNon'] as bool?;
      _dlmExiste = data['dlmExiste'] as bool?;
      _typeDLM = data['typeDLM'] as String?;
      _photoPath = data['photoPath'] as String?;
      _syncStatus = data['_status'] as String?;
      _isSaved = _syncStatus == 'completed' || _syncStatus == 'synced';
    });
  }

  // ── Enregistrement ────────────────────────────────────────────────────────

  Future<void> _takePhoto() async {
    final String? path = await _imageService.takePhoto();
    if (path != null) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'dateActivite': _dateController.text,
        'nbTotal': int.tryParse(_nbTotalController.text),
        'nbHommes': int.tryParse(_nbHommesController.text),
        'nbFemmes': int.tryParse(_nbFemmesController.text),
        'nbEnfants': int.tryParse(_nbEnfantsController.text),
        'accesEau': _accesEau,
        'difficulteEau': _difficulteEauController.text,
        'latrinesExiste': _latrinesExiste,
        'typeLatrine': _typeLatrine,
        'latrineAmelioree': _latrineAmelioree,
        'latrineDegradee': _latrineDegradee,
        'latrineUsageToujours': _latrineUsageToujours,
        'latrineVoisin': _latrineVoisin,
        'latrineDefecation': _latrineDefecation,
        'latrineVoisinNon': _latrineVoisinNon,
        'latrineDefecationNon': _latrineDefecationNon,
        'dlmExiste': _dlmExiste,
        'typeDLM': _typeDLM,
        'photoPath': _photoPath,
        'observations': _observationsController.text,
      };

      await saveAndSync(
        type: 'etat_lieux_menage',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('État des Lieux Ménage enregistré'),
            ]),
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

  /// Déclenche la sauvegarde automatique du brouillon (debounced).
  void _triggerAutoSave() {
    onFieldChanged(
      type: 'etat_lieux_menage',
      localiteId: _localiteId,
      userId: _userId,
      dataProvider: () => {
        'dateActivite': _dateController.text,
        'nbTotal': int.tryParse(_nbTotalController.text),
        'nbHommes': int.tryParse(_nbHommesController.text),
        'nbFemmes': int.tryParse(_nbFemmesController.text),
        'nbEnfants': int.tryParse(_nbEnfantsController.text),
        'accesEau': _accesEau,
        'difficulteEau': _difficulteEauController.text,
        'latrinesExiste': _latrinesExiste,
        'typeLatrine': _typeLatrine,
        'latrineAmelioree': _latrineAmelioree,
        'latrineDegradee': _latrineDegradee,
        'latrineUsageToujours': _latrineUsageToujours,
        'latrineVoisin': _latrineVoisin,
        'latrineDefecation': _latrineDefecation,
        'latrineVoisinNon': _latrineVoisinNon,
        'latrineDefecationNon': _latrineDefecationNon,
        'dlmExiste': _dlmExiste,
        'typeDLM': _typeDLM,
        'photoPath': _photoPath,
        'observations': _observationsController.text,
      },
    );
  }

  // ── Helpers d'interface ───────────────────────────────────────────────────

  /// Crée une ligne Question / Dropdown Oui-Non
  Widget _buildOuiNon({
    required String label,
    required bool? value,
    required void Function(bool?) onChanged,
    bool required = false,
  }) {
    return AppDropdownField<bool>(
      label: label,
      value: value,
      required: required,
      items: const [
        DropdownMenuItem(value: true, child: Text('Oui')),
        DropdownMenuItem(value: false, child: Text('Non')),
      ],
      onChanged: onChanged,
    );
  }

  // ── Interface ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('État des Lieux – Ménage'),
        actions: [
          if (_syncStatus == 'draft')
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: AppStatusBadge(
                label: 'Brouillon',
                color: Colors.orange,
                icon: Icons.edit_note,
              ),
            ),
          if (_isSaved)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AppStatusBadge(
                label: _syncStatus == 'synced' ? 'Synchronisé' : 'Enregistré',
                color: AppTheme.successColor,
                icon: _syncStatus == 'synced' ? Icons.cloud_done : Icons.check_circle_outline,
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
                    title: 'Date de l\'activité', icon: Icons.event_note),
                AppDateField(
                  label: 'Date de l\'activité',
                  controller: _dateController,
                  required: true,
                  lastDate: DateTime.now(),
                  onChanged: (v) => _triggerAutoSave(),
                ),
              ],
            ),

            // ── Composition du ménage ─────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Composition du ménage', icon: Icons.family_restroom),
                AppNumberField(
                  label: 'Nombre total de personnes',
                  controller: _nbTotalController,
                  required: true,
                  onChanged: (v) => _triggerAutoSave(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppNumberField(
                        label: 'Hommes',
                        controller: _nbHommesController,
                        onChanged: (v) => _triggerAutoSave(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppNumberField(
                        label: 'Femmes',
                        controller: _nbFemmesController,
                        onChanged: (v) => _triggerAutoSave(),
                      ),
                    ),
                  ],
                ),
                AppNumberField(
                  label: 'Enfants < 5 ans',
                  controller: _nbEnfantsController,
                  onChanged: (v) => _triggerAutoSave(),
                ),
              ],
            ),

            // ── Accès à l'eau ─────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Accès à l\'eau', icon: Icons.water_drop),
                _buildOuiNon(
                  label: 'Accès à l\'eau potable',
                  value: _accesEau,
                  required: true,
                  onChanged: (v) => setState(() {
                    _accesEau = v;
                    _triggerAutoSave();
                  }),
                ),
                if (_accesEau == false)
                  AppTextField(
                    label: 'Type de difficulté (optionnel)',
                    controller: _difficulteEauController,
                    prefixIcon: Icons.warning_amber_outlined,
                    onChanged: (v) => _triggerAutoSave(),
                  ),
              ],
            ),

            // ── Latrines ──────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Latrine du ménage', icon: Icons.home_repair_service),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Dispose d\'une latrine'),
                        value: true,
                        groupValue: _latrinesExiste,
                        activeColor: AppTheme.successColor,
                        onChanged: (v) => setState(() {
                          _latrinesExiste = v;
                          _triggerAutoSave();
                        }),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Pas de latrine'),
                        value: false,
                        groupValue: _latrinesExiste,
                        activeColor: AppTheme.errorColor,
                        onChanged: (v) => setState(() {
                          _latrinesExiste = v;
                          _triggerAutoSave();
                        }),
                      ),
                    ),
                  ],
                ),

                // Si OUI
                if (_latrinesExiste == true) ...[
                  const Divider(),
                  AppDropdownField<String>(
                    label: 'Type de latrine',
                    value: _typeLatrine,
                    prefixIcon: Icons.category_outlined,
                    items: const [
                      DropdownMenuItem(
                          value: 'traditionnelle', child: Text('Traditionnelle')),
                      DropdownMenuItem(
                          value: 'amelioree', child: Text('Améliorée')),
                      DropdownMenuItem(value: 'autre', child: Text('Autre')),
                    ],
                    onChanged: (v) => setState(() {
                      _typeLatrine = v;
                      _triggerAutoSave();
                    }),
                  ),
                  _buildOuiNon(
                    label: 'Latrine améliorée ?',
                    value: _latrineAmelioree,
                    onChanged: (v) => setState(() {
                      _latrineAmelioree = v;
                      _triggerAutoSave();
                    }),
                  ),
                  _buildOuiNon(
                    label: 'Latrine dégradée ?',
                    value: _latrineDegradee,
                    onChanged: (v) => setState(() {
                      _latrineDegradee = v;
                      _triggerAutoSave();
                    }),
                  ),
                  _buildOuiNon(
                    label: 'Utilisez-vous toujours cette latrine ?',
                    value: _latrineUsageToujours,
                    onChanged: (v) => setState(() {
                      _latrineUsageToujours = v;
                      _triggerAutoSave();
                    }),
                  ),
                  _buildOuiNon(
                    label: 'Utilisez-vous aussi la latrine du voisin ?',
                    value: _latrineVoisin,
                    onChanged: (v) => setState(() {
                      _latrineVoisin = v;
                      _triggerAutoSave();
                    }),
                  ),
                  _buildOuiNon(
                    label: 'Pratiquez-vous la défécation à l\'air libre ?',
                    value: _latrineDefecation,
                    onChanged: (v) => setState(() {
                      _latrineDefecation = v;
                      _triggerAutoSave();
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Photo (professionnelle)
                  if (_photoPath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb 
                        ? Image.network(_photoPath!, height: 200, width: double.infinity, fit: BoxFit.cover)
                        : Image.file(File(_photoPath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(
                    icon: Icon(
                      _photoPath != null ? Icons.check_circle : Icons.camera_alt,
                      color: _photoPath != null
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                    label: Text(
                      _photoPath != null ? 'Changer la photo' : 'Prendre une photo',
                    ),
                    onPressed: _takePhoto,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _photoPath != null
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ],

                // Si NON
                if (_latrinesExiste == false) ...[
                  const Divider(),
                  _buildOuiNon(
                    label: 'Utilisez-vous la latrine d\'un voisin ?',
                    value: _latrineVoisinNon,
                    onChanged: (v) => setState(() {
                      _latrineVoisinNon = v;
                      _triggerAutoSave();
                    }),
                  ),
                  _buildOuiNon(
                    label: 'Pratiquez-vous la défécation à l\'air libre ?',
                    value: _latrineDefecationNon,
                    onChanged: (v) => setState(() {
                      _latrineDefecationNon = v;
                      _triggerAutoSave();
                    }),
                  ),
                ],
              ],
            ),

            // ── DLM ───────────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Dispositif de lavage des mains (DLM)',
                    icon: Icons.wash),
                _buildOuiNon(
                  label: 'Disposez-vous d\'un DLM ?',
                  value: _dlmExiste,
                  required: true,
                  onChanged: (v) => setState(() => _dlmExiste = v),
                ),
                if (_dlmExiste == true)
                  AppDropdownField<String>(
                    label: 'Type de dispositif',
                    value: _typeDLM,
                    prefixIcon: Icons.category_outlined,
                    items: const [
                      DropdownMenuItem(
                          value: 'eau_savon', child: Text('Eau + Savon')),
                      DropdownMenuItem(
                          value: 'eau_seule', child: Text('Eau seule')),
                    ],
                    onChanged: (v) => setState(() => _typeDLM = v),
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
                  onChanged: (v) => _triggerAutoSave(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Bouton ────────────────────────────────────────────────────
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
