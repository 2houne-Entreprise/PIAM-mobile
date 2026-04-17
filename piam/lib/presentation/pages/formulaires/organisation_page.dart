import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/form_auto_sync_mixin.dart';


/// Formulaire — Organisation du chantier
/// 
/// Gère l'encadrement, les effectifs, les EPI et l'approvisionnement en matériaux.
class OrganisationPage extends StatefulWidget {
  final String formulaireId;

  const OrganisationPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<OrganisationPage> createState() => _OrganisationPageState();
}

class _OrganisationPageState extends State<OrganisationPage> with FormAutoSyncMixin {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _chefChantierController = TextEditingController();
  final _nomEntrepriseController = TextEditingController();
  final _effectifOuvrierController = TextEditingController();
  final _effectifEncadrementController = TextEditingController();
  final _observationsController = TextEditingController();

  // EPI
  bool _casques = false;
  bool _gants = false;
  bool _chaussures = false;
  bool _gilets = false;
  bool _masques = false;

  // Main d'œuvre
  String _origineMainOeuvre = 'Locale';
  static const List<String> _origines = ['Locale', 'Régionale', 'Nationale'];

  // Matériaux
  final List<_MateriauItem> _materiaux = [];

  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    // Le premier matériau sera ajouté par le chargement ou par défaut
    _chefChantierController.addListener(_triggerAutoSave);
    _nomEntrepriseController.addListener(_triggerAutoSave);
    _effectifOuvrierController.addListener(_triggerAutoSave);
    _effectifEncadrementController.addListener(_triggerAutoSave);
    _observationsController.addListener(_triggerAutoSave);
  }

  @override
  void dispose() {
    _chefChantierController.dispose();
    _nomEntrepriseController.dispose();
    _effectifOuvrierController.dispose();
    _effectifEncadrementController.dispose();
    _observationsController.dispose();
    for (var m in _materiaux) m.dispose();
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
      type: 'organisation_chantier',
      localiteId: localiteId,
    );
    if (data == null || !mounted) {
      if (_materiaux.isEmpty) setState(() => _materiaux.add(_MateriauItem(onChanged: _triggerAutoSave)));
      return;
    }

    _isRestoring = true;

    setState(() {
      _chefChantierController.text = data['chefChantier'] ?? '';
      _nomEntrepriseController.text = data['nomEntreprise'] ?? '';
      _effectifOuvrierController.text = data['effectifOuvrier']?.toString() ?? '';
      _effectifEncadrementController.text = data['effectifEncadrement']?.toString() ?? '';
      _observationsController.text = data['observations'] ?? '';
      _origineMainOeuvre = data['origineMainOeuvre'] ?? 'Locale';
      
      _casques = data['casques'] ?? false;
      _gants = data['gants'] ?? false;
      _chaussures = data['chaussures'] ?? false;
      _gilets = data['gilets'] ?? false;
      _masques = data['masques'] ?? false;

      _materiaux.clear();
      if (data['materiaux'] != null) {
        for (var item in (data['materiaux'] as List)) {
          final m = _MateriauItem(onChanged: _triggerAutoSave);
          m.nomController.text = item['nom'] ?? '';
          m.quantiteController.text = item['quantite'] ?? '';
          m.qualiteController.text = item['qualite'] ?? '';
          _materiaux.add(m);
        }
      }
      if (_materiaux.isEmpty) _materiaux.add(_MateriauItem(onChanged: _triggerAutoSave));

      _isSaved = true;
    });

    _isRestoring = false;
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  void _triggerAutoSave() {
    if (_isRestoring) return;

    final materiauxJson = _materiaux.map((m) => {
      'nom': m.nomController.text,
      'quantite': m.quantiteController.text,
      'qualite': m.qualiteController.text,
    }).toList();

    onFieldChanged(
      type: 'organisation_chantier',
      localiteId: _localiteId,
      userId: _userId,
      dataProvider: () => {
        'chefChantier': _chefChantierController.text,
        'nomEntreprise': _nomEntrepriseController.text,
        'effectifOuvrier': int.tryParse(_effectifOuvrierController.text),
        'effectifEncadrement': int.tryParse(_effectifEncadrementController.text),
        'origineMainOeuvre': _origineMainOeuvre,
        'casques': _casques,
        'gants': _gants,
        'chaussures': _chaussures,
        'gilets': _gilets,
        'masques': _masques,
        'materiaux': materiauxJson,
        'observations': _observationsController.text,
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final materiauxJson = _materiaux.map((m) => {
        'nom': m.nomController.text,
        'quantite': m.quantiteController.text,
        'qualite': m.qualiteController.text,
      }).toList();

      final dataMap = {
        'chefChantier': _chefChantierController.text,
        'nomEntreprise': _nomEntrepriseController.text,
        'effectifOuvrier': int.tryParse(_effectifOuvrierController.text),
        'effectifEncadrement': int.tryParse(_effectifEncadrementController.text),
        'origineMainOeuvre': _origineMainOeuvre,
        'casques': _casques,
        'gants': _gants,
        'chaussures': _chaussures,
        'gilets': _gilets,
        'masques': _masques,
        'materiaux': materiauxJson,
        'observations': _observationsController.text,
      };

      await saveAndSync(
        type: 'organisation_chantier',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organisation enregistrée'),
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
        title: const Text('Organisation du chantier'),
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

            // ── Section Encadrement ───────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Encadrement du chantier', icon: Icons.engineering_rounded),
                AppTextField(
                  label: 'Nom du Chef de chantier',
                  controller: _chefChantierController,
                  required: true,
                  prefixIcon: Icons.person_outline,
                ),
                AppTextField(
                  label: 'Nom de l\'entreprise titulaire',
                  controller: _nomEntrepriseController,
                  required: true,
                  prefixIcon: Icons.business_outlined,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Ouvriers',
                        controller: _effectifOuvrierController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.group_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Encadrants',
                        controller: _effectifEncadrementController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.supervisor_account_outlined,
                      ),
                    ),
                  ],
                ),
                AppDropdownField<String>(
                  label: 'Origine de la main d\'œuvre',
                  value: _origineMainOeuvre,
                  items: _origines.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (v) {
                    setState(() => _origineMainOeuvre = v!);
                    _triggerAutoSave();
                  },
                ),
              ],
            ),

            // ── Section EPI ───────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Équipements de protection (EPI)', icon: Icons.security_rounded),
                const Text('Cochez les EPI disponibles sur site :', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    _epiToggle('Casques', _casques, (v) { setState(() => _casques = v); _triggerAutoSave(); }),
                    _epiToggle('Gants', _gants, (v) { setState(() => _gants = v); _triggerAutoSave(); }),
                    _epiToggle('Chaussures de sécu.', _chaussures, (v) { setState(() => _chaussures = v); _triggerAutoSave(); }),
                    _epiToggle('Gilets réfléchissants', _gilets, (v) { setState(() => _gilets = v); _triggerAutoSave(); }),
                    _epiToggle('Masques', _masques, (v) { setState(() => _masques = v); _triggerAutoSave(); }),
                  ],
                ),
              ],
            ),

            // ── Section Matériaux ─────────────────────────────────────────
            const AppSectionTitle(title: 'Matériaux et approvisionnement', icon: Icons.inventory_2_outlined),
            ..._materiaux.asMap().entries.map((e) => _buildMateriauCard(e.key, e.value)),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Ajouter un matériau'),
                onPressed: () {
                  setState(() => _materiaux.add(_MateriauItem(onChanged: _triggerAutoSave)));
                  _triggerAutoSave();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            // ── Observations ──────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Observations générales', icon: Icons.comment_outlined),
                AppTextField(
                  label: 'Remarques sur l\'organisation',
                  controller: _observationsController,
                  maxLines: 4,
                ),
              ],
            ),

            const SizedBox(height: 8),
            AppSubmitButton(
              label: 'Enregistrer l\'organisation',
              isLoading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMateriauCard(int index, _MateriauItem item) {
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
                    label: 'Nom du matériau',
                    controller: item.nomController,
                    required: true,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Quantité',
                          controller: item.quantiteController,
                          hint: 'Ex: 50 sacs',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          label: 'Qualité observé',
                          controller: item.qualiteController,
                          hint: 'Ex: Conforme',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_materiaux.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                onPressed: () {
                  setState(() {
                    _materiaux[index].dispose();
                    _materiaux.removeAt(index);
                  });
                  _triggerAutoSave();
                },
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
      backgroundColor: value ? AppTheme.primaryColor : Colors.grey.shade200,
      labelStyle: TextStyle(color: value ? Colors.white : Colors.black87),
      padding: EdgeInsets.zero,
      onPressed: () => onChanged(!value),
    );
  }
}

class _MateriauItem {
  final nomController = TextEditingController();
  final quantiteController = TextEditingController();
  final qualiteController = TextEditingController();

  _MateriauItem({VoidCallback? onChanged}) {
    if (onChanged != null) {
      nomController.addListener(onChanged);
      quantiteController.addListener(onChanged);
      qualiteController.addListener(onChanged);
    }
  }

  void dispose() {
    nomController.dispose();
    quantiteController.dispose();
    qualiteController.dispose();
  }
}
