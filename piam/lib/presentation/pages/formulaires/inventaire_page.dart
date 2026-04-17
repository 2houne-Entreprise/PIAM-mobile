import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';
import 'package:piam/services/image_handler_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';


/// Formulaire — Inventaire des infrastructures
/// 
/// Gère les détails de l'infrastructure, l'accès à l'eau, l'assainissement et le DLM.
class InventairePage extends StatefulWidget {
  final String formulaireId;

  const InventairePage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<InventairePage> createState() => _InventairePageState();
}

class _InventairePageState extends State<InventairePage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageHandlerService();
  bool _isLoading = false;
  bool _isSaved = false;
  String? _syncStatus; // 'draft', 'completed', 'synced'

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _nomInfraController = TextEditingController();
  final _typeInfraController = TextEditingController();
  final _sourceEauController = TextEditingController();
  final _distanceSourceController = TextEditingController();
  final _nbBlocsController = TextEditingController();
  final _nbCabinesController = TextEditingController();
  final _nbCabinesFonctController = TextEditingController();
  final _nbBlocsConstruireController = TextEditingController();
  final _nbCabinesConstruireController = TextEditingController();

  // Flags & Selection
  bool? _accesEau;
  bool? _accesLatrines;
  bool? _besoinConstruction;
  bool _presenceDLM = false;
  bool _dlmEauSavon = false;
  bool _dlmFonctionnel = false;
  String? _photoPath;

  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    onSyncStatusChanged = (status) {
      if (mounted) setState(() => _syncStatus = status);
    };

    _nomInfraController.addListener(_triggerAutoSave);
    _typeInfraController.addListener(_triggerAutoSave);
    _sourceEauController.addListener(_triggerAutoSave);
    _distanceSourceController.addListener(_triggerAutoSave);
    _nbBlocsController.addListener(_triggerAutoSave);
    _nbCabinesController.addListener(_triggerAutoSave);
    _nbCabinesFonctController.addListener(_triggerAutoSave);
    _nbBlocsConstruireController.addListener(_triggerAutoSave);
    _nbCabinesConstruireController.addListener(_triggerAutoSave);
  }

  @override
  void dispose() {
    _nomInfraController.dispose();
    _typeInfraController.dispose();
    _sourceEauController.dispose();
    _distanceSourceController.dispose();
    _nbBlocsController.dispose();
    _nbCabinesController.dispose();
    _nbCabinesFonctController.dispose();
    _nbBlocsConstruireController.dispose();
    _nbCabinesConstruireController.dispose();
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
      type: 'inventaire_infra',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    _isRestoring = true;

    setState(() {
      _nomInfraController.text = data['nomInfrastructure'] ?? '';
      _typeInfraController.text = data['typeInfrastructure'] ?? '';
      _sourceEauController.text = data['sourceEau'] ?? '';
      _distanceSourceController.text = data['distanceSource']?.toString() ?? '';
      _nbBlocsController.text = data['nbBlocs']?.toString() ?? '';
      _nbCabinesController.text = data['nbCabines']?.toString() ?? '';
      _nbCabinesFonctController.text = data['nbCabinesFonctionnelles']?.toString() ?? '';
      _nbBlocsConstruireController.text = data['nbBlocsConstruire']?.toString() ?? '';
      _nbCabinesConstruireController.text = data['nbCabinesConstruire']?.toString() ?? '';

      _accesEau = data['accesEau'];
      _accesLatrines = data['accesLatrines'];
      _besoinConstruction = data['besoinConstruction'];
      _presenceDLM = data['presenceDLM'] ?? false;
      _dlmEauSavon = data['dlmEauSavon'] ?? false;
      _dlmFonctionnel = data['dlmFonctionnel'] ?? false;
      _photoPath = data['photoPath'];
      _syncStatus = data['_status'] as String?;
      _isSaved = _syncStatus == 'completed' || _syncStatus == 'synced';
    });

    _isRestoring = false;
  }

  Future<void> _takePhoto() async {
    final path = await _imageService.takePhoto();
    if (path != null) {
      setState(() => _photoPath = path);
    }
  }

  /// Déclenche la sauvegarde automatique du brouillon (debounced).
  void _triggerAutoSave() {
    if (_isRestoring) return;

    onFieldChanged(
      type: 'inventaire_infra',
      localiteId: _localiteId,
      userId: _userId,
      dataProvider: () => {
        'nomInfrastructure': _nomInfraController.text,
        'typeInfrastructure': _typeInfraController.text,
        'sourceEau': _sourceEauController.text,
        'distanceSource': double.tryParse(_distanceSourceController.text),
        'accesEau': _accesEau,
        'accesLatrines': _accesLatrines,
        'nbBlocs': int.tryParse(_nbBlocsController.text),
        'nbCabines': int.tryParse(_nbCabinesController.text),
        'nbCabinesFonctionnelles': int.tryParse(_nbCabinesFonctController.text),
        'photoPath': _photoPath,
        'besoinConstruction': _besoinConstruction,
        'nbBlocsConstruire': int.tryParse(_nbBlocsConstruireController.text),
        'nbCabinesConstruire': int.tryParse(_nbCabinesConstruireController.text),
        'presenceDLM': _presenceDLM,
        'dlmEauSavon': _dlmEauSavon,
        'dlmFonctionnel': _dlmFonctionnel,
      },
    );
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'nomInfrastructure': _nomInfraController.text,
        'typeInfrastructure': _typeInfraController.text,
        'sourceEau': _sourceEauController.text,
        'distanceSource': double.tryParse(_distanceSourceController.text),
        'accesEau': _accesEau,
        'accesLatrines': _accesLatrines,
        'nbBlocs': int.tryParse(_nbBlocsController.text),
        'nbCabines': int.tryParse(_nbCabinesController.text),
        'nbCabinesFonctionnelles': int.tryParse(_nbCabinesFonctController.text),
        'photoPath': _photoPath,
        'besoinConstruction': _besoinConstruction,
        'nbBlocsConstruire': int.tryParse(_nbBlocsConstruireController.text),
        'nbCabinesConstruire': int.tryParse(_nbCabinesConstruireController.text),
        'presenceDLM': _presenceDLM,
        'dlmEauSavon': _dlmEauSavon,
        'dlmFonctionnel': _dlmFonctionnel,
      };

      await saveAndSync(
        type: 'inventaire_infra',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inventaire enregistré'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: AppTheme.errorColor),
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
        title: const Text('Inventaire des infrastructures'),
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
            FormHeaderWidget(onDataLoaded: _onLocalisationLoaded),

            // ── Section Infra ─────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Informations générales', icon: Icons.business_rounded),
                AppTextField(
                  label: 'Nom de l\'infrastructure',
                  controller: _nomInfraController,
                  required: true,
                  onChanged: (v) => _triggerAutoSave(),
                ),
                AppTextField(
                  label: 'Type d\'infrastructure',
                  controller: _typeInfraController,
                  hint: 'Ex: École, Centre de santé...',
                  onChanged: (v) => _triggerAutoSave(),
                ),
              ],
            ),

            // ── Section Eau ───────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Accès à l\'Eau', icon: Icons.water_drop_outlined),
                _buildYesNoRadio('La localité a-t-elle accès à l\'eau ?', _accesEau, (v) => setState(() {
                  _accesEau = v;
                  _triggerAutoSave();
                })),
                if (_accesEau != null) ...[
                  AppTextField(
                    label: 'Source d\'eau',
                    controller: _sourceEauController,
                    hint: 'Ex: Forage, Puits...',
                    onChanged: (v) => _triggerAutoSave(),
                  ),
                  AppTextField(
                    label: 'Distance à la source (m)',
                    controller: _distanceSourceController,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _triggerAutoSave(),
                  ),
                ],
              ],
            ),

            // ── Section Assainissement ────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Assainissement', icon: Icons.wc_rounded),
                _buildYesNoRadio('Présence de latrines ?', _accesLatrines, (v) => setState(() {
                  _accesLatrines = v;
                  _triggerAutoSave();
                })),
                if (_accesLatrines == true) ...[
                  Row(
                    children: [
                      Expanded(child: AppTextField(label: 'Nb Blocs', controller: _nbBlocsController, keyboardType: TextInputType.number, onChanged: (v) => _triggerAutoSave())),
                      const SizedBox(width: 12),
                      Expanded(child: AppTextField(label: 'Nb Cabines', controller: _nbCabinesController, keyboardType: TextInputType.number, onChanged: (v) => _triggerAutoSave())),
                    ],
                  ),
                  AppTextField(
                    label: 'Nombre de cabines fonctionnelles',
                    controller: _nbCabinesFonctController,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _triggerAutoSave(),
                  ),
                ],
                if (_accesLatrines == false) ...[
                  CheckboxListTile(
                    title: const Text('Besoin de construction / réhabilitation', style: TextStyle(fontSize: 14)),
                    value: _besoinConstruction ?? false,
                    onChanged: (v) => setState(() {
                      _besoinConstruction = v;
                      _triggerAutoSave();
                    }),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_besoinConstruction == true)
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'Blocs à prévoir', controller: _nbBlocsConstruireController, keyboardType: TextInputType.number, onChanged: (v) => _triggerAutoSave())),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(label: 'Cabines à prévoir', controller: _nbCabinesConstruireController, keyboardType: TextInputType.number, onChanged: (v) => _triggerAutoSave())),
                      ],
                    ),
                ],
              ],
            ),

            // ── Section DLM ───────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Dispositif de Lavage des Mains (DLM)', icon: Icons.clean_hands_outlined),
                _buildCheckbox('Présence de DLM', _presenceDLM, (v) => setState(() {
                  _presenceDLM = v!;
                  _triggerAutoSave();
                })),
                _buildCheckbox('DLM avec eau + savon', _dlmEauSavon, (v) => setState(() {
                  _dlmEauSavon = v!;
                  _triggerAutoSave();
                })),
                _buildCheckbox('DLM fonctionnel', _dlmFonctionnel, (v) => setState(() {
                  _dlmFonctionnel = v!;
                  _triggerAutoSave();
                })),
                
                const Divider(),
                const AppSectionTitle(title: 'Preuve Photo', icon: Icons.camera_alt_outlined),
                if (_photoPath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb 
                      ? Image.network(_photoPath!, height: 200, width: double.infinity, fit: BoxFit.cover)
                      : Image.file(File(_photoPath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: Icon(_photoPath != null ? Icons.check_circle : Icons.camera_alt),
                  label: Text(_photoPath != null ? 'Changer la photo' : 'Prendre une photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _photoPath != null ? AppTheme.successColor : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            AppSubmitButton(
              label: 'Enregistrer l\'inventaire',
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildYesNoRadio(String label, bool? value, Function(bool?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Oui'),
                value: true,
                groupValue: value,
                onChanged: onChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Non'),
                value: false,
                groupValue: value,
                onChanged: onChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
