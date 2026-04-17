import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';


/// Formulaire — Personnel et équipes sur site
/// 
/// Gère la liste des membres, leurs rôles et leurs équipements de protection individuelle (EPI).
class EquipesPage extends StatefulWidget {
  final String formulaireId;

  const EquipesPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<EquipesPage> createState() => _EquipesPageState();
}

class _EquipesPageState extends State<EquipesPage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _dateDemarrageController = TextEditingController();
  final _remarquesController = TextEditingController();

  bool _premierSecours = false;
  final List<_MembreEquipe> _membres = [];

  static const List<String> _roles = [
    'Chef d\'équipe',
    'Maçon',
    'Aide-maçon',
    'Manœuvre',
    'Plombier',
    'Électricien',
    'Chauffeur',
    'Gardien',
    'Autre',
  ];

  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _dateDemarrageController.addListener(_triggerAutoSave);
    _remarquesController.addListener(_triggerAutoSave);
  }

  @override
  void dispose() {
    _dateDemarrageController.dispose();
    _remarquesController.dispose();
    for (final m in _membres) m.dispose();
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
      type: 'equipes_personnel',
      localiteId: localiteId,
    );
    if (data == null || !mounted) {
      if (_membres.isEmpty) setState(() => _membres.add(_MembreEquipe(onChanged: _triggerAutoSave)));
      return;
    }

    _isRestoring = true;

    setState(() {
      _dateDemarrageController.text = data['dateDemarrage'] ?? '';
      _remarquesController.text = data['remarques'] ?? '';
      _premierSecours = data['premierSecours'] ?? false;

      _membres.clear();
      if (data['membres'] != null) {
        for (var item in (data['membres'] as List)) {
          final m = _MembreEquipe(onChanged: _triggerAutoSave);
          m.nomController.text = item['nom'] ?? '';
          m.role = item['role'] ?? 'Maçon';
          m.casque = item['casque'] ?? false;
          m.gants = item['gants'] ?? false;
          m.chaussures = item['chaussures'] ?? false;
          m.gilet = item['gilet'] ?? false;
          _membres.add(m);
        }
      }
      if (_membres.isEmpty) _membres.add(_MembreEquipe(onChanged: _triggerAutoSave));

      _isSaved = true;
    });

    _isRestoring = false;
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  void _triggerAutoSave() {
    if (_isRestoring) return;

    final membresJson = _membres.map((m) => {
      'nom': m.nomController.text,
      'role': m.role,
      'casque': m.casque,
      'gants': m.gants,
      'chaussures': m.chaussures,
      'gilet': m.gilet,
    }).toList();

    onFieldChanged(
      type: 'equipes_personnel',
      localiteId: _localiteId,
      userId: _userId,
      dataProvider: () => {
        'dateDemarrage': _dateDemarrageController.text,
        'premierSecours': _premierSecours,
        'remarques': _remarquesController.text,
        'membres': membresJson,
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final membresJson = _membres.map((m) => {
        'nom': m.nomController.text,
        'role': m.role,
        'casque': m.casque,
        'gants': m.gants,
        'chaussures': m.chaussures,
        'gilet': m.gilet,
      }).toList();

      final dataMap = {
        'dateDemarrage': _dateDemarrageController.text,
        'premierSecours': _premierSecours,
        'remarques': _remarquesController.text,
        'membres': membresJson,
      };

      await saveAndSync(
        type: 'equipes_personnel',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données du personnel enregistrées'),
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
        title: const Text('Personnel et équipes'),
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

            // ── Section Installation ──────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Installation sur site', icon: Icons.engineering_outlined),
                AppDateField(
                  label: 'Date de démarrage effectif',
                  controller: _dateDemarrageController,
                  required: true,
                ),
                SwitchListTile(
                  title: const Text('Trousse de premiers secours disponible', style: TextStyle(fontSize: 14)),
                  value: _premierSecours,
                  onChanged: (v) {
                    setState(() => _premierSecours = v);
                    _triggerAutoSave();
                  },
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),

            // ── Liste des Membres ─────────────────────────────────────────
            const AppSectionTitle(title: 'Liste des membres de l\'équipe', icon: Icons.group_outlined),
            ..._membres.asMap().entries.map((e) => _buildMembreCard(e.key, e.value)),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Ajouter un ouvrier'),
                onPressed: () {
                  setState(() => _membres.add(_MembreEquipe(onChanged: _triggerAutoSave)));
                  _triggerAutoSave();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            // ── Remarques ─────────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Conditions de travail', icon: Icons.comment_outlined),
                AppTextField(
                  label: 'Observations sur l\'équipe',
                  controller: _remarquesController,
                  maxLines: 4,
                ),
              ],
            ),

            const SizedBox(height: 8),
            AppSubmitButton(
              label: 'Enregistrer l\'équipe',
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMembreCard(int index, _MembreEquipe membre) {
    return AppFormCard(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text('${index + 1}', style: const TextStyle(color: AppTheme.primaryColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Nom complet',
                controller: membre.nomController,
                required: true,
              ),
            ),
            if (_membres.length > 1)
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.errorColor),
                onPressed: () {
                  setState(() {
                    _membres[index].dispose();
                    _membres.removeAt(index);
                  });
                  _triggerAutoSave();
                },
              ),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppDropdownField<String>(
                label: 'Rôle',
                value: membre.role,
                items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) {
                  setState(() => membre.role = v!);
                  _triggerAutoSave();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Équipements (EPI) :', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Wrap(
                    spacing: 4,
                    children: [
                      _epiToggle('Casque', membre.casque, (v) { setState(() => membre.casque = v); _triggerAutoSave(); }),
                      _epiToggle('Gilet', membre.gilet, (v) { setState(() => membre.gilet = v); _triggerAutoSave(); }),
                      _epiToggle('Gants', membre.gants, (v) { setState(() => membre.gants = v); _triggerAutoSave(); }),
                      _epiToggle('Chaussures', membre.chaussures, (v) { setState(() => membre.chaussures = v); _triggerAutoSave(); }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _epiToggle(String label, bool value, Function(bool) onChanged) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      avatar: value ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
      backgroundColor: value ? AppTheme.successColor : Colors.grey.shade200,
      labelStyle: TextStyle(color: value ? Colors.white : Colors.black87),
      padding: EdgeInsets.zero,
      onPressed: () => onChanged(!value),
    );
  }
}

class _MembreEquipe {
  final nomController = TextEditingController();
  String role = 'Maçon';
  bool casque = false;
  bool gants = false;
  bool chaussures = false;
  bool gilet = false;

  _MembreEquipe({VoidCallback? onChanged}) {
    if (onChanged != null) {
      nomController.addListener(onChanged);
    }
  }

  void dispose() {
    nomController.dispose();
  }
}
