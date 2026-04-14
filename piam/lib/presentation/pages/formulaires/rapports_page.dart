import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';


/// Formulaire — Rapports de contrôle
/// 
/// Gère les visites de contrôle, la conformité par critère et les mesures correctives.
class RapportsPage extends StatefulWidget {
  final String formulaireId;

  const RapportsPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<RapportsPage> createState() => _RapportsPageState();
}

class _RapportsPageState extends State<RapportsPage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _dateVisiteController = TextEditingController();
  final _travauxRealisesController = TextEditingController();
  final _nonConformitesController = TextEditingController();
  final _mesuresCorrectivesController = TextEditingController();
  final _recommandationsController = TextEditingController();

  // Conformité par critère: null = non évalué, true = conforme, false = non conforme
  final Map<String, bool?> _conformites = {
    'Qualité des matériaux': null,
    'Respect des plans': null,
    'Qualité de la maçonnerie': null,
    'Alignement et niveaux': null,
    'Finitions': null,
    'EPI des ouvriers': null,
  };

  int _noteGlobale = 3; // 1-5

  @override
  void dispose() {
    _dateVisiteController.dispose();
    _travauxRealisesController.dispose();
    _nonConformitesController.dispose();
    _mesuresCorrectivesController.dispose();
    _recommandationsController.dispose();
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
      type: 'rapport_controle',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    setState(() {
      _dateVisiteController.text = data['dateVisite'] ?? '';
      _travauxRealisesController.text = data['travauxRealises'] ?? '';
      _nonConformitesController.text = data['nonConformites'] ?? '';
      _mesuresCorrectivesController.text = data['mesuresCorrectives'] ?? '';
      _recommandationsController.text = data['recommandations'] ?? '';
      _noteGlobale = data['noteGlobale'] ?? 3;

      if (data['conformites'] != null) {
        final Map<String, dynamic> savedConf = data['conformites'];
        _conformites.clear();
        savedConf.forEach((key, value) {
          _conformites[key] = value;
        });
      }

      _isSaved = true;
    });
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'dateVisite': _dateVisiteController.text,
        'travauxRealises': _travauxRealisesController.text,
        'nonConformites': _nonConformitesController.text,
        'mesuresCorrectives': _mesuresCorrectivesController.text,
        'recommandations': _recommandationsController.text,
        'noteGlobale': _noteGlobale,
        'conformites': _conformites,
      };

      await saveAndSync(
        type: 'rapport_controle',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport de contrôle enregistré'),
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
        title: const Text('Rapport de contrôle'),
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

            // ── Section Visite ────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Informations de visite', icon: Icons.calendar_today_rounded),
                AppDateField(
                  label: 'Date de visite',
                  controller: _dateVisiteController,
                  required: true,
                ),
                AppTextField(
                  label: 'Travaux réalisés depuis la dernière visite',
                  controller: _travauxRealisesController,
                  maxLines: 4,
                  required: true,
                  hint: 'Énumérez les principales avancées...',
                ),
              ],
            ),

            // ── Section Conformité ────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Grille de conformité technique', icon: Icons.fact_check_outlined),
                const SizedBox(height: 8),
                ..._conformites.keys.map((critere) => _buildConformiteRow(critere)),
                const Divider(height: 32),
                const Center(
                  child: Text('Note globale de la visite', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => IconButton(
                    iconSize: 36,
                    icon: Icon(i < _noteGlobale ? Icons.star_rounded : Icons.star_outline_rounded),
                    color: Colors.amber,
                    onPressed: () => setState(() => _noteGlobale = i + 1),
                  )),
                ),
              ],
            ),

            // ── Section Écarts ────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Non-conformités et Mesures', icon: Icons.report_problem_outlined),
                AppTextField(
                  label: 'Non-conformités observées',
                  controller: _nonConformitesController,
                  maxLines: 3,
                  prefixIcon: Icons.warning_amber_rounded,
                ),
                AppTextField(
                  label: 'Mesures correctives prescrites',
                  controller: _mesuresCorrectivesController,
                  maxLines: 3,
                  prefixIcon: Icons.handyman_outlined,
                ),
              ],
            ),

            // ── Section Recommandations ───────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Prochaines étapes', icon: Icons.next_plan_outlined),
                AppTextField(
                  label: 'Recommandations',
                  controller: _recommandationsController,
                  maxLines: 3,
                  hint: 'Conseils pour la suite du chantier...',
                ),
              ],
            ),

            const SizedBox(height: 8),
            AppSubmitButton(
              label: 'Enregistrer le rapport',
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConformiteRow(String critere) {
    final val = _conformites[critere];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(critere, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Wrap(
            spacing: 8,
            children: [
              _statusChip(Icons.check_circle_outline, Colors.green, val == true, () => setState(() => _conformites[critere] = true)),
              _statusChip(Icons.remove_circle_outline, Colors.grey, val == null, () => setState(() => _conformites[critere] = null)),
              _statusChip(Icons.error_outline, Colors.red, val == false, () => setState(() => _conformites[critere] = false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(IconData icon, Color color, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 1.5),
        ),
        child: Icon(icon, color: isSelected ? color : Colors.grey.shade400, size: 20),
      ),
    );
  }
}
