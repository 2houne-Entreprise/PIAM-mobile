import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';
import 'package:piam/services/image_handler_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';


/// Formulaire — Dernier Suivi Ménage
///
/// Collecte les informations sur la latrine et le DLM d'un ménage.
/// Les données sont persistées dans SQLite par localité.
class DernierSuiviMenagePage extends StatefulWidget {
  final String formulaireId;

  const DernierSuiviMenagePage({Key? key, required this.formulaireId})
      : super(key: key);

  @override
  State<DernierSuiviMenagePage> createState() => _DernierSuiviMenagePageState();
}

class _DernierSuiviMenagePageState extends State<DernierSuiviMenagePage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageHandlerService();
  bool _isLoading = false;
  bool _isSaved = false;
  String? _syncStatus; // 'draft', 'completed', 'synced'

  // Données de localisation
  int? _localiteId;
  dynamic _userId;

  // ── Champs (états pour les radios/checkboxes) ─────────────────────────────
  bool? _latrineExiste;
  bool _ancienneLatrineDegradee = false;
  bool _utilisationLatrineVoisinNon = false;
  bool _dalNon = false;

  bool _latrineAmelioree = false;
  final _nbMenagesPartageLatrineCtr = TextEditingController();
  String? _photoPath;

  bool? _dlmExiste;
  String? _typeDlm;

  bool _isRestoring = false;

  // ── Cycle de vie ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    onSyncStatusChanged = (status) {
      if (mounted) setState(() => _syncStatus = status);
    };

    _nbMenagesPartageLatrineCtr.addListener(_triggerAutoSave);
  }

  @override
  void dispose() {
    _nbMenagesPartageLatrineCtr.dispose();
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
      type: 'dernier_suivi_menage',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    _isRestoring = true;

    setState(() {
      _latrineExiste = data['latrine_existe'] as bool?;
      _ancienneLatrineDegradee = data['ancienne_latrine_degradee'] as bool? ?? false;
      _utilisationLatrineVoisinNon = data['utilisation_latrine_voisin'] as bool? ?? false;
      _dalNon = data['dal'] as bool? ?? false;
      _latrineAmelioree = data['latrine_amelioree'] as bool? ?? false;
      _photoPath = data['photo'] as String?;
      _dlmExiste = data['dlm_existe'] as bool?;
      _typeDlm = data['type_dlm'] as String?;
      _syncStatus = data['_status'] as String?;
      _isSaved = _syncStatus == 'completed' || _syncStatus == 'synced';
    });
    _nbMenagesPartageLatrineCtr.text =
        data['nb_menages_partage_latrine']?.toString() ?? '';
        
    _isRestoring = false;
  }

  // ── Enregistrement ────────────────────────────────────────────────────────

  Future<void> _takePhoto() async {
    final String? path = await _imageService.takePhoto();
    if (path != null) {
      setState(() => _photoPath = path);
    }
  }

  /// Déclenche la sauvegarde automatique du brouillon (debounced).
  void _triggerAutoSave() {
    if (_isRestoring) return;

    onFieldChanged(
      type: 'dernier_suivi_menage',
      localiteId: _localiteId,
      userId: _userId,
      dataProvider: () => {
        'latrine_existe': _latrineExiste,
        'ancienne_latrine_degradee': _latrineExiste == false ? _ancienneLatrineDegradee : null,
        'utilisation_latrine_voisin': _latrineExiste == false ? _utilisationLatrineVoisinNon : null,
        'dal': _latrineExiste == false ? _dalNon : null,
        'latrine_amelioree': _latrineExiste == true ? _latrineAmelioree : null,
        'nb_menages_partage_latrine': _latrineExiste == true ? int.tryParse(_nbMenagesPartageLatrineCtr.text) : null,
        'photo': _latrineExiste == true ? _photoPath : null,
        'dlm_existe': _dlmExiste,
        'type_dlm': _dlmExiste == true ? _typeDlm : null,
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'latrine_existe': _latrineExiste,
        'ancienne_latrine_degradee':
            _latrineExiste == false ? _ancienneLatrineDegradee : null,
        'utilisation_latrine_voisin':
            _latrineExiste == false ? _utilisationLatrineVoisinNon : null,
        'dal': _latrineExiste == false ? _dalNon : null,
        'latrine_amelioree':
            _latrineExiste == true ? _latrineAmelioree : null,
        'nb_menages_partage_latrine': _latrineExiste == true
            ? int.tryParse(_nbMenagesPartageLatrineCtr.text)
            : null,
        'photo': _latrineExiste == true ? _photoPath : null,
        'dlm_existe': _dlmExiste,
        'type_dlm': _dlmExiste == true ? _typeDlm : null,
      };

      await saveAndSync(
        type: 'dernier_suivi_menage',
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
              Text('Dernier Suivi Ménage enregistré'),
            ]),
            backgroundColor: AppTheme.successColor,
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
        title: const Text('Dernier Suivi Ménage'),
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

            // ── Latrine ───────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                  title: 'Le ménage dispose-t-il d\'une latrine ?',
                  icon: Icons.home,
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Oui'),
                        value: true,
                        groupValue: _latrineExiste,
                        activeColor: AppTheme.successColor,
                        onChanged: (v) => setState(() {
                          _latrineExiste = v;
                          _triggerAutoSave();
                        }),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Non'),
                        value: false,
                        groupValue: _latrineExiste,
                        activeColor: AppTheme.errorColor,
                        onChanged: (v) => setState(() {
                          _latrineExiste = v;
                          _triggerAutoSave();
                        }),
                      ),
                    ),
                  ],
                ),

                // Si NON → questions sur situation alternative
                if (_latrineExiste == false) ...[
                  const Divider(),
                  CheckboxListTile(
                    title:
                        const Text('Ancienne latrine dégradée / effondrée'),
                    value: _ancienneLatrineDegradee,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) => setState(() {
                      _ancienneLatrineDegradee = v ?? false;
                      _triggerAutoSave();
                    }),
                  ),
                  CheckboxListTile(
                    title: const Text('Utilise la latrine d\'un voisin'),
                    value: _utilisationLatrineVoisinNon,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) => setState(() {
                      _utilisationLatrineVoisinNon = v ?? false;
                      _triggerAutoSave();
                    }),
                  ),
                  CheckboxListTile(
                    title: const Text('Défécation à l\'air libre (DAL)'),
                    value: _dalNon,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (v) => setState(() {
                      _dalNon = v ?? false;
                      _triggerAutoSave();
                    }),
                  ),
                ],

                // Si OUI → détails de la latrine
                if (_latrineExiste == true) ...[
                  const Divider(),
                  CheckboxListTile(
                    title: const Text('Latrine améliorée'),
                    value: _latrineAmelioree,
                    activeColor: AppTheme.successColor,
                    onChanged: (v) => setState(() {
                      _latrineAmelioree = v ?? false;
                      _triggerAutoSave();
                    }),
                  ),
                  AppNumberField(
                    label: 'Nombre de ménages partageant la latrine',
                    controller: _nbMenagesPartageLatrineCtr,
                    onChanged: (v) => _triggerAutoSave(),
                  ),
                  // Photo (professionnelle)
                  if (_photoPath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb 
                        ? Image.network(_photoPath!, height: 180, width: double.infinity, fit: BoxFit.cover)
                        : Image.file(File(_photoPath!), height: 180, width: double.infinity, fit: BoxFit.cover),
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
                      side: BorderSide(
                        color: _photoPath != null
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // ── DLM ───────────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                  title: 'Dispositif de lavage des mains (DLM)',
                  icon: Icons.wash,
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Oui'),
                        value: true,
                        groupValue: _dlmExiste,
                        activeColor: AppTheme.successColor,
                        onChanged: (v) => setState(() {
                          _dlmExiste = v;
                          _triggerAutoSave();
                        }),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Non'),
                        value: false,
                        groupValue: _dlmExiste,
                        activeColor: AppTheme.errorColor,
                        onChanged: (v) => setState(() {
                          _dlmExiste = v;
                          _triggerAutoSave();
                        }),
                      ),
                    ),
                  ],
                ),
                if (_dlmExiste == true)
                  AppDropdownField<String>(
                    label: 'Type de dispositif',
                    value: _typeDlm,
                    prefixIcon: Icons.category_outlined,
                    items: const [
                      DropdownMenuItem(
                          value: 'eau+savon', child: Text('Eau + Savon')),
                      DropdownMenuItem(
                          value: 'eau seule', child: Text('Eau seule')),
                      DropdownMenuItem(child: Text('Aucun'), value: 'aucun'),
                    ],
                    onChanged: (v) => setState(() {
                      _typeDlm = v;
                      _triggerAutoSave();
                    }),
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
