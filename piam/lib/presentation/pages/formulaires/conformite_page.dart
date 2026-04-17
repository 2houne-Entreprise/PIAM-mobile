import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';


/// Formulaire — Certification FDAL / ATPC (Conformité)
/// 
/// Enregistre si la certification a été obtenue et les raisons de refus le cas échéant.
class ConformitePage extends StatefulWidget {
  final String formulaireId;

  const ConformitePage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<ConformitePage> createState() => _ConformitePageState();
}

class _ConformitePageState extends State<ConformitePage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _dateCertificationController = TextEditingController();
  final _remarqueNonController = TextEditingController();

  bool? _certifie;
  final List<String> _raisonsNon = [];

  final List<String> _optionsRaisonsNon = [
    'Pas de fonds disponibles',
    'Fonds mobilisés ailleurs',
    'Administration en retard',
    'Problème foncier / Conflits',
    'Problème foncier / Conflits',
    'Autre (spécifier)',
  ];

  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _dateCertificationController.addListener(_triggerAutoSave);
    _remarqueNonController.addListener(_triggerAutoSave);
  }

  @override
  void dispose() {
    _dateCertificationController.dispose();
    _remarqueNonController.dispose();
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
      type: 'conformite_fdal',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    _isRestoring = true;

    setState(() {
      _dateCertificationController.text = data['dateCertification'] ?? '';
      _remarqueNonController.text = data['remarqueNon'] ?? '';
      _certifie = data['certifie'] as bool?;
      
      _raisonsNon.clear();
      if (data['raisonsNon'] != null) {
        _raisonsNon.addAll(List<String>.from(data['raisonsNon']));
      }

      _isSaved = true;
    });

    _isRestoring = false;
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  void _triggerAutoSave() {
    if (_isRestoring) return;

    onFieldChanged(
      type: 'conformite_fdal',
      localiteId: _localiteId,
      userId: _userId,
      dataProvider: () => {
        'dateCertification': _dateCertificationController.text,
        'certifie': _certifie,
        'raisonsNon': _raisonsNon,
        'remarqueNon': _remarqueNonController.text,
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'dateCertification': _dateCertificationController.text,
        'certifie': _certifie,
        'raisonsNon': _raisonsNon,
        'remarqueNon': _remarqueNonController.text,
      };

      await saveAndSync(
        type: 'conformite_fdal',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conformité enregistrée'),
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
        title: const Text('Certification FDAL'),
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
            FormHeaderWidget(onDataLoaded: _onLocalisationLoaded),

            // ── Section Certification ─────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Statut de certification', icon: Icons.verified_user_rounded),
                AppDateField(
                  label: 'Date de l\'évaluation',
                  controller: _dateCertificationController,
                  required: true,
                ),
                const SizedBox(height: 8),
                const Text('La localité est-elle certifiée FDAL ?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Oui'),
                        value: true,
                        groupValue: _certifie,
                        activeColor: AppTheme.successColor,
                        onChanged: (v) {
                          setState(() => _certifie = v);
                          _triggerAutoSave();
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Non'),
                        value: false,
                        groupValue: _certifie,
                        activeColor: AppTheme.errorColor,
                        onChanged: (v) {
                          setState(() => _certifie = v);
                          _triggerAutoSave();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Section Raisons (si Non) ──────────────────────────────────
            if (_certifie == false)
              AppFormCard(
                children: [
                  const AppSectionTitle(title: 'Raisons de non-certification', icon: Icons.warning_amber_rounded),
                  const Text('Cochez les motifs identifiés :', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._optionsRaisonsNon.map((opt) => CheckboxListTile(
                        title: Text(opt, style: const TextStyle(fontSize: 14)),
                        value: _raisonsNon.contains(opt),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) _raisonsNon.add(opt);
                            else _raisonsNon.remove(opt);
                          });
                          _triggerAutoSave();
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: AppTheme.errorColor,
                        contentPadding: EdgeInsets.zero,
                      )),
                  if (_raisonsNon.contains('Autre (spécifier)'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AppTextField(
                        label: 'Précisez l\'autre raison',
                        controller: _remarqueNonController,
                        required: true,
                        maxLines: 2,
                      ),
                    ),
                ],
              ),

            // ── Section Observations ──────────────────────────────────────
            if (_certifie == true)
              AppFormCard(
                children: [
                  const AppSectionTitle(title: 'Observations', icon: Icons.comment_outlined),
                  AppTextField(
                    label: 'Commentaire libre',
                    controller: _remarqueNonController,
                    maxLines: 3,
                  ),
                ],
              ),

            const SizedBox(height: 8),
            AppSubmitButton(
              label: 'Enregistrer la conformité',
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
