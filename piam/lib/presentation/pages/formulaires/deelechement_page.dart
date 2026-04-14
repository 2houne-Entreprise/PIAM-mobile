import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';

/// Formulaire — Déclenchement
///
/// Un seul champ : la date de l'activité.
/// Pattern de persistance identique aux autres formulaires.
/// Utilise [FormAutoSyncMixin] pour la sauvegarde locale + sync API automatique.
class DeeclenchementPage extends StatefulWidget {
  final String formulaireId;

  const DeeclenchementPage({Key? key, required this.formulaireId})
      : super(key: key);

  @override
  State<DeeclenchementPage> createState() => _DeeclenchementPageState();
}

class _DeeclenchementPageState extends State<DeeclenchementPage>
    with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  bool _isLoading = false;
  bool _isSaved = false;

  // Données de localisation (fournies par FormHeaderWidget)
  int? _localiteId;
  dynamic _userId;

  // ── Cycle de vie ──────────────────────────────────────────────────────────

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // ── Chargement ────────────────────────────────────────────────────────────

  /// Appelé par [FormHeaderWidget] dès que la localité est connue.
  void _onLocalisationLoaded(int? localiteId, dynamic userId) {
    setState(() {
      _localiteId = localiteId;
      _userId = userId;
    });
    if (localiteId != null) _loadSavedData(localiteId);
  }

  Future<void> _loadSavedData(int localiteId) async {
    final data = await DatabaseService().getQuestionnaire(
      type: 'declenchement',
      localiteId: localiteId,
    );

    if (data == null || !mounted) return;

    _dateController.text = data['date_activite'] ?? '';
    if (mounted) setState(() => _isSaved = true);
  }

  // ── Enregistrement ────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Sauvegarde locale + sync API automatique via le mixin
      await saveAndSync(
        type: 'declenchement',
        localiteId: _localiteId,
        dataMap: {'date_activite': _dateController.text},
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
                Text('Déclenchement enregistré avec succès'),
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
        title: const Text(AppStrings.declenchementTitle),
        elevation: 0,
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
                  title: AppStrings.declenchementTitle,
                  icon: Icons.flag_outlined,
                  color: AppTheme.primaryColor,
                ),
                AppInfoBanner(
                  message:
                      'Saisissez la date à laquelle le déclenchement a eu lieu dans cette localité.',
                  icon: Icons.lightbulb_outline,
                ),
                AppDateField(
                  label: 'Date de l\'activité',
                  controller: _dateController,
                  required: true,
                  lastDate: DateTime.now(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Boutons ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppSubmitButton(
                    label: AppStrings.send,
                    isLoading: _isLoading,
                    onPressed: _save,
                    color: AppTheme.colorGreen,
                    icon: Icons.save_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
