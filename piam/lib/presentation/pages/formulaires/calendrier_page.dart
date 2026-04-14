import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';


/// Formulaire — Calendrier des travaux
/// 
/// Gère les dates prévisionnelles, réelles, le taux d'avancement et les jalons.
class CalendrierPage extends StatefulWidget {
  final String formulaireId;

  const CalendrierPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendrierPage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _dateDebutPrevueController = TextEditingController();
  final _dateFinPrevueController = TextEditingController();
  final _dateDebutReelleController = TextEditingController();
  final _dateFinReelleController = TextEditingController();
  final _observationsController = TextEditingController();

  double _avancement = 0;
  final List<_Jalon> _jalons = [];

  static const List<String> _statutsJalon = [
    'Planifié',
    'En cours',
    'Réalisé',
    'Retardé',
    'Annulé',
  ];

  @override
  void initState() {
    super.initState();
    // Par défaut, pas de jalon vide au début car ils seront chargés depuis la base
  }

  @override
  void dispose() {
    _dateDebutPrevueController.dispose();
    _dateFinPrevueController.dispose();
    _dateDebutReelleController.dispose();
    _dateFinReelleController.dispose();
    _observationsController.dispose();
    for (final j in _jalons) j.dispose();
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
      type: 'calendrier_travaux',
      localiteId: localiteId,
    );
    if (data == null || !mounted) {
      if (_jalons.isEmpty) setState(() => _jalons.add(_Jalon())); // Un jalon vide si rien
      return;
    }

    setState(() {
      _dateDebutPrevueController.text = data['dateDebutPrevue'] ?? '';
      _dateFinPrevueController.text = data['dateFinPrevue'] ?? '';
      _dateDebutReelleController.text = data['dateDebutReelle'] ?? '';
      _dateFinReelleController.text = data['dateFinReelle'] ?? '';
      _observationsController.text = data['observations'] ?? '';
      _avancement = (data['avancement'] ?? 0.0).toDouble();

      // Jalons
      _jalons.clear();
      if (data['jalons'] != null) {
        for (var item in (data['jalons'] as List)) {
          final j = _Jalon();
          j.nomController.text = item['nom'] ?? '';
          j.statut = item['statut'] ?? 'Planifié';
          j.dateController.text = item['date'] ?? '';
          _jalons.add(j);
        }
      }
      if (_jalons.isEmpty) _jalons.add(_Jalon());

      _isSaved = true;
    });
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez corriger les erreurs'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jalonsJson = _jalons.map((j) => {
        'nom': j.nomController.text,
        'statut': j.statut,
        'date': j.dateController.text,
      }).toList();

      final dataMap = {
        'dateDebutPrevue': _dateDebutPrevueController.text,
        'dateFinPrevue': _dateFinPrevueController.text,
        'dateDebutReelle': _dateDebutReelleController.text,
        'dateFinReelle': _dateFinReelleController.text,
        'avancement': _avancement,
        'jalons': jalonsJson,
        'observations': _observationsController.text,
      };

      await saveAndSync(
        type: 'calendrier_travaux',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calendrier enregistré avec succès !'),
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
        title: const Text('Calendrier des travaux'),
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

            // ── Dates Prévisionnelles ─────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Dates prévisionnelles', icon: Icons.event_note),
                Row(
                  children: [
                    Expanded(
                      child: AppDateField(
                        label: 'Début prévu',
                        controller: _dateDebutPrevueController,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppDateField(
                        label: 'Fin prévue',
                        controller: _dateFinPrevueController,
                        required: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Dates Réelles ─────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Exécution réelle', icon: Icons.play_circle_fill_outlined),
                Row(
                  children: [
                    Expanded(
                      child: AppDateField(
                        label: 'Début réel',
                        controller: _dateDebutReelleController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppDateField(
                        label: 'Fin réelle',
                        controller: _dateFinReelleController,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Avancement ────────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Taux d\'avancement', icon: Icons.speed),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _avancement,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: AppTheme.primaryColor,
                        label: '${_avancement.toInt()}%',
                        onChanged: (v) => setState(() => _avancement = v),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_avancement.toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Jalons ────────────────────────────────────────────────────
            const AppSectionTitle(title: 'Jalons du projet', icon: Icons.flag_rounded),
            ..._jalons.asMap().entries.map((e) => _buildJalonCard(e.key, e.value)),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Ajouter un jalon'),
                onPressed: () => setState(() => _jalons.add(_Jalon())),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            // ── Observations ──────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Observations', icon: Icons.comment_outlined),
                AppTextField(
                  label: 'Observations sur le chantier',
                  controller: _observationsController,
                  maxLines: 4,
                ),
              ],
            ),

            const SizedBox(height: 16),
            AppSubmitButton(
              label: 'Enregistrer le calendrier',
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildJalonCard(int index, _Jalon jalon) {
    return AppFormCard(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  AppTextField(
                    label: 'Nom du jalon',
                    controller: jalon.nomController,
                    required: true,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<String>(
                          label: 'Statut',
                          value: jalon.statut,
                          items: _statutsJalon.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => jalon.statut = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppDateField(
                          label: 'Date',
                          controller: jalon.dateController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_jalons.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                onPressed: () => setState(() {
                  _jalons[index].dispose();
                  _jalons.removeAt(index);
                }),
              ),
          ],
        ),
      ],
    );
  }
}

class _Jalon {
  final nomController = TextEditingController();
  final dateController = TextEditingController();
  String statut = 'Planifié';

  void dispose() {
    nomController.dispose();
    dateController.dispose();
  }
}
