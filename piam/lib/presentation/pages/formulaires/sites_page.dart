import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';

/// Formulaire — Sites d'assainissement
/// 
/// Gère les caractéristiques techniques du site, les quantitatifs et les travaux associés.
class SitesPage extends StatefulWidget {
  final String formulaireId;

  const SitesPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  // ── État ─────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false;

  int? _localiteId;
  dynamic _userId;

  // Controllers
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _nbBlocsController = TextEditingController();
  final _nbCabinesController = TextEditingController();
  final _nbDlmController = TextEditingController();
  final _autresTravauxController = TextEditingController();
  final _superficieController = TextEditingController();
  final _observationsController = TextEditingController();

  String? _typeLatrines;
  String? _etatSiteActuel;

  bool _destructionAnciennesLatrines = false;
  bool _constructionMur = false;
  bool _trancheesDrainage = false;
  bool _pointEauLavage = false;

  static const List<String> _typesLatrines = [
    'Semi-enterrée',
    'Enterrée',
    'Améliorée',
    'VIP (Ventilated Improved Pit)',
    'À fosse septique',
  ];

  static const List<String> _etats = [
    'Vierge',
    'Dégradé',
    'Partiellement réhabilité',
    'Réhabilité',
  ];

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _nbBlocsController.dispose();
    _nbCabinesController.dispose();
    _nbDlmController.dispose();
    _autresTravauxController.dispose();
    _superficieController.dispose();
    _observationsController.dispose();
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
      type: 'sites_assainissement',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    setState(() {
      _latitudeController.text = data['latitude']?.toString() ?? '';
      _longitudeController.text = data['longitude']?.toString() ?? '';
      _nbBlocsController.text = data['nbBlocs']?.toString() ?? '';
      _nbCabinesController.text = data['nbCabines']?.toString() ?? '';
      _nbDlmController.text = data['nbDlm']?.toString() ?? '';
      _autresTravauxController.text = data['autresTravaux'] ?? '';
      _superficieController.text = data['superficie']?.toString() ?? '';
      _observationsController.text = data['observations'] ?? '';
      
      _typeLatrines = data['typeLatrines'];
      _etatSiteActuel = data['etatSiteActuel'];
      
      _destructionAnciennesLatrines = data['destructionAnciennesLatrines'] ?? false;
      _constructionMur = data['constructionMur'] ?? false;
      _trancheesDrainage = data['trancheesDrainage'] ?? false;
      _pointEauLavage = data['pointEauLavage'] ?? false;

      _isSaved = true;
    });
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataMap = {
        'latitude': double.tryParse(_latitudeController.text),
        'longitude': double.tryParse(_longitudeController.text),
        'nbBlocs': int.tryParse(_nbBlocsController.text),
        'nbCabines': int.tryParse(_nbCabinesController.text),
        'nbDlm': int.tryParse(_nbDlmController.text),
        'autresTravaux': _autresTravauxController.text,
        'superficie': double.tryParse(_superficieController.text),
        'observations': _observationsController.text,
        'typeLatrines': _typeLatrines,
        'etatSiteActuel': _etatSiteActuel,
        'destructionAnciennesLatrines': _destructionAnciennesLatrines,
        'constructionMur': _constructionMur,
        'trancheesDrainage': _trancheesDrainage,
        'pointEauLavage': _pointEauLavage,
      };

      await DatabaseService().upsertQuestionnaire(
        type: 'sites_assainissement',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données du site enregistrées'),
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
        title: const Text('Sites d\'assainissement'),
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

            // ── Section GPS ───────────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Coordonnées GPS du site', icon: Icons.gps_fixed_rounded),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Latitude',
                        controller: _latitudeController,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Longitude',
                        controller: _longitudeController,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Section Caractéristiques ──────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Caractéristiques techniques', icon: Icons.settings_applications_outlined),
                AppDropdownField<String>(
                  label: 'Type de latrines',
                  value: _typeLatrines,
                  items: _typesLatrines.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _typeLatrines = v!),
                ),
                AppDropdownField<String>(
                  label: 'État actuel du site',
                  value: _etatSiteActuel,
                  items: _etats.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _etatSiteActuel = v!),
                ),
                AppTextField(
                  label: 'Superficie allouée (m²)',
                  controller: _superficieController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.square_foot_rounded,
                ),
              ],
            ),

            // ── Section Quantitatifs ──────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Quantitatifs prévus', icon: Icons.format_list_numbered_rounded),
                Row(
                  children: [
                    Expanded(child: AppTextField(label: 'Nb blocs', controller: _nbBlocsController, keyboardType: TextInputType.number, required: true)),
                    const SizedBox(width: 12),
                    Expanded(child: AppTextField(label: 'Nb cabines', controller: _nbCabinesController, keyboardType: TextInputType.number)),
                  ],
                ),
                AppTextField(
                  label: 'Nb de DLM (Dispositifs de Lavage des Mains)',
                  controller: _nbDlmController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.wash_rounded,
                ),
              ],
            ),

            // ── Section Travaux ───────────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Travaux associés', icon: Icons.handyman_outlined),
                _buildCheckbox('Destruction des anciennes latrines', _destructionAnciennesLatrines, (v) => setState(() => _destructionAnciennesLatrines = v!)),
                _buildCheckbox('Construction d\'un mur de clôture', _constructionMur, (v) => setState(() => _constructionMur = v!)),
                _buildCheckbox('Tranchées de drainage / évacuation', _trancheesDrainage, (v) => setState(() => _trancheesDrainage = v!)),
                _buildCheckbox('Point d\'eau / robinetterie dédiée', _pointEauLavage, (v) => setState(() => _pointEauLavage = v!)),
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Autres travaux spécifiques',
                  controller: _autresTravauxController,
                  maxLines: 2,
                ),
              ],
            ),

            // ── Section Observations ──────────────────────────────────────
            AppFormCard(
              children: [
                const AppSectionTitle(title: 'Observations', icon: Icons.comment_outlined),
                AppTextField(
                  label: 'Commentaires sur le site',
                  controller: _observationsController,
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 8),
            AppSubmitButton(
              label: 'Enregistrer le site',
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
