import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';


/// Formulaire — Programmation des travaux
/// 
/// Permet de planifier les activités à venir et le nombre de travaux associés.
class ProgrammationTravauxPage extends StatefulWidget {
  final String formulaireId;

  const ProgrammationTravauxPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<ProgrammationTravauxPage> createState() => _ProgrammationTravauxPageState();
}

class _ProgrammationTravauxPageState extends State<ProgrammationTravauxPage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _dateActiviteController = TextEditingController();
  final _nbTravauxController = TextEditingController();
  final _autreController = TextEditingController();

  @override
  void dispose() {
    _dateActiviteController.dispose();
    _nbTravauxController.dispose();
    _autreController.dispose();
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
      type: 'programmation_travaux',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    setState(() {
      _dateActiviteController.text = data['dateActivite'] ?? '';
      _nbTravauxController.text = data['nbTravaux']?.toString() ?? '';
      _autreController.text = data['autre'] ?? '';
      _isSaved = true;
    });
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'dateActivite': _dateActiviteController.text,
        'nbTravaux': int.tryParse(_nbTravauxController.text),
        'autre': _autreController.text,
      };

      await saveAndSync(
        type: 'programmation_travaux',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Programmation enregistrée avec succès'),
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
        title: const Text('Programmation des Travaux'),
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

            // ── Section Programmation ─────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Détails de la planification', icon: Icons.calendar_month_rounded),
                const SizedBox(height: 8),
                const Text('Programmation des travaux à venir sur le site.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 16),
                AppDateField(
                  label: 'Date prévue de l\'activité',
                  controller: _dateActiviteController,
                  required: true,
                ),
                AppTextField(
                  label: 'Nombre de travaux programmés',
                  controller: _nbTravauxController,
                  keyboardType: TextInputType.number,
                  required: true,
                  prefixIcon: Icons.format_list_numbered_rounded,
                ),
              ],
            ),

            // ── Section Note ───────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Informations complémentaires', icon: Icons.note_alt_outlined),
                AppTextField(
                  label: 'Autre (texte libre)',
                  controller: _autreController,
                  maxLines: 4,
                  hint: 'Précisez ici toute autre information pertinente...',
                ),
              ],
            ),

            const SizedBox(height: 8),
            AppSubmitButton(
              label: 'Enregistrer la programmation',
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
