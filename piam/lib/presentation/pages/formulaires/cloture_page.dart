import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';


/// Formulaire — Clôture du chantier
/// 
/// Enregistre les réceptions (provisoire/définitive), les PV, les réserves et les signatures.
class CloturePage extends StatefulWidget {
  final String formulaireId;

  const CloturePage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<CloturePage> createState() => _CloturePageState();
}

class _CloturePageState extends State<CloturePage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _dateReceptionProvisoireController = TextEditingController();
  final _dateReceptionDefinitiveController = TextEditingController();
  final _dateLeveeReservesController = TextEditingController();
  final _pvReceptionController = TextEditingController();
  final _reservesController = TextEditingController();
  final _remarquesFinalesController = TextEditingController();

  // Flags
  bool _leveeReserves = false;
  bool _signatureEntreprise = false;
  bool _signatureMaitreOuvrage = false;
  bool _signatureControleur = false;
  bool _dossierComplet = false;

  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _dateReceptionProvisoireController.addListener(_triggerAutoSave);
    _dateReceptionDefinitiveController.addListener(_triggerAutoSave);
    _dateLeveeReservesController.addListener(_triggerAutoSave);
    _pvReceptionController.addListener(_triggerAutoSave);
    _reservesController.addListener(_triggerAutoSave);
    _remarquesFinalesController.addListener(_triggerAutoSave);
  }

  @override
  void dispose() {
    _dateReceptionProvisoireController.dispose();
    _dateReceptionDefinitiveController.dispose();
    _dateLeveeReservesController.dispose();
    _pvReceptionController.dispose();
    _reservesController.dispose();
    _remarquesFinalesController.dispose();
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
      type: 'cloture_chantier',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    _isRestoring = true;

    setState(() {
      _dateReceptionProvisoireController.text = data['dateReceptionProvisoire'] ?? '';
      _dateReceptionDefinitiveController.text = data['dateReceptionDefinitive'] ?? '';
      _dateLeveeReservesController.text = data['dateLeveeReserves'] ?? '';
      _pvReceptionController.text = data['pvReception'] ?? '';
      _reservesController.text = data['reserves'] ?? '';
      _remarquesFinalesController.text = data['remarquesFinales'] ?? '';
      
      _leveeReserves = data['leveeReserves'] ?? false;
      _signatureEntreprise = data['signatureEntreprise'] ?? false;
      _signatureMaitreOuvrage = data['signatureMaitreOuvrage'] ?? false;
      _signatureControleur = data['signatureControleur'] ?? false;
      _dossierComplet = data['dossierComplet'] ?? false;

      _isSaved = true;
    });

    _isRestoring = false;
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  void _triggerAutoSave() {
    if (_isRestoring) return;

    onFieldChanged(
      type: 'cloture_chantier',
      localiteId: _localiteId,
      userId: _userId,
      dataProvider: () => {
        'dateReceptionProvisoire': _dateReceptionProvisoireController.text,
        'dateReceptionDefinitive': _dateReceptionDefinitiveController.text,
        'dateLeveeReserves': _dateLeveeReservesController.text,
        'pvReception': _pvReceptionController.text,
        'reserves': _reservesController.text,
        'remarquesFinales': _remarquesFinalesController.text,
        'leveeReserves': _leveeReserves,
        'signatureEntreprise': _signatureEntreprise,
        'signatureMaitreOuvrage': _signatureMaitreOuvrage,
        'signatureControleur': _signatureControleur,
        'dossierComplet': _dossierComplet,
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez corriger les erreurs'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'dateReceptionProvisoire': _dateReceptionProvisoireController.text,
        'dateReceptionDefinitive': _dateReceptionDefinitiveController.text,
        'dateLeveeReserves': _dateLeveeReservesController.text,
        'pvReception': _pvReceptionController.text,
        'reserves': _reservesController.text,
        'remarquesFinales': _remarquesFinalesController.text,
        'leveeReserves': _leveeReserves,
        'signatureEntreprise': _signatureEntreprise,
        'signatureMaitreOuvrage': _signatureMaitreOuvrage,
        'signatureControleur': _signatureControleur,
        'dossierComplet': _dossierComplet,
      };

      await saveAndSync(
        type: 'cloture_chantier',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clôture enregistrée'),
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
        title: const Text('Clôture du chantier'),
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

            // ── Section Dates ─────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Réceptions et délais', icon: Icons.calendar_today_rounded),
                AppDateField(
                  label: 'Date réception provisoire',
                  controller: _dateReceptionProvisoireController,
                  required: true,
                ),
                AppDateField(
                  label: 'Date réception définitive',
                  controller: _dateReceptionDefinitiveController,
                ),
              ],
            ),

            // ── Section PV ────────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Procès-verbal', icon: Icons.description_outlined),
                AppTextField(
                  label: 'Contenu du PV de réception',
                  controller: _pvReceptionController,
                  maxLines: 5,
                  prefixIcon: Icons.article_outlined,
                ),
              ],
            ),

            // ── Section Réserves ──────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Réserves émises', icon: Icons.playlist_add_check_rounded),
                AppTextField(
                  label: 'Détail des réserves',
                  controller: _reservesController,
                  maxLines: 4,
                  prefixIcon: Icons.list_alt_rounded,
                ),
                SwitchListTile(
                  title: const Text('Levée des réserves effectuée', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  value: _leveeReserves,
                  onChanged: (v) {
                    setState(() => _leveeReserves = v);
                    _triggerAutoSave();
                  },
                  activeColor: AppTheme.successColor,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_leveeReserves)
                  AppDateField(
                    label: 'Date de levée des réserves',
                    controller: _dateLeveeReservesController,
                    required: true,
                  ),
              ],
            ),

            // ── Section Signatures ────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Signatures et validation', icon: Icons.draw_rounded),
                const Text('Parties ayant signé le PV :', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildCheckbox('Entreprise titulaire', _signatureEntreprise, (v) { setState(() => _signatureEntreprise = v!); _triggerAutoSave(); }),
                _buildCheckbox('Maître d\'ouvrage', _signatureMaitreOuvrage, (v) { setState(() => _signatureMaitreOuvrage = v!); _triggerAutoSave(); }),
                _buildCheckbox('Bureau de contrôle (MDC)', _signatureControleur, (v) { setState(() => _signatureControleur = v!); _triggerAutoSave(); }),
                const Divider(height: 32),
                SwitchListTile(
                  title: const Text('Dossier de clôture complet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Incluant les plans de recollement et PV', style: TextStyle(fontSize: 12)),
                  value: _dossierComplet,
                  onChanged: (v) {
                    setState(() => _dossierComplet = v);
                    _triggerAutoSave();
                  },
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),

            // ── Section Remarques ─────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Remarques finales', icon: Icons.comment_outlined),
                AppTextField(
                  label: 'Observations de clôture',
                  controller: _remarquesFinalesController,
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 8),
            AppSubmitButton(
              label: 'Enregistrer la clôture',
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
      activeColor: AppTheme.primaryColor,
    );
  }
}
