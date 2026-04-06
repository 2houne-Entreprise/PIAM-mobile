import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';

/// Formulaire 4 – Sites d'assainissement
class SitesPage extends StatefulWidget {
  final String formulaireId;

  const SitesPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  Future<void> _saveFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sites enregistrés'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _submitFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sites soumis pour validation'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites d\'assainissement'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoBanner(
                    'Renseignez les informations sur les sites d\'assainissement',
                  ),
                  const SizedBox(height: 20),

                  // ── Section A : Localisation GPS ──────────────────────────
                  _buildSectionTitle('A. Localisation GPS'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            prefixIcon: Icon(Icons.gps_fixed),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? AppStrings.requiredField
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            prefixIcon: Icon(Icons.gps_fixed),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? AppStrings.requiredField
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Section B : Caractéristiques ──────────────────────────
                  _buildSectionTitle('B. Caractéristiques du site'),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _typeLatrines,
                    items: _typesLatrines
                        .map(
                          (t) => DropdownMenuItem<String>(
                            value: t,
                            child: Text(t),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _typeLatrines = v),
                    decoration: const InputDecoration(
                      labelText: 'Type de latrines *',
                      prefixIcon: Icon(Icons.category),
                    ),
                    isExpanded: true,
                    validator: (v) =>
                        v == null ? AppStrings.requiredField : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _etatSiteActuel,
                    items: _etats
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _etatSiteActuel = v),
                    decoration: const InputDecoration(
                      labelText: 'État actuel du site',
                      prefixIcon: Icon(Icons.assessment),
                    ),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _superficieController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Superficie (m²)',
                      prefixIcon: Icon(Icons.square_foot),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section C : Quantitatifs ──────────────────────────────
                  _buildSectionTitle('C. Quantitatifs'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nbBlocsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nb blocs',
                            prefixIcon: Icon(Icons.grid_view),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? AppStrings.requiredField
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _nbCabinesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nb cabines',
                            prefixIcon: Icon(Icons.cabin),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _nbDlmController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nb DLM',
                            prefixIcon: Icon(Icons.houseboat),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Section D : Travaux associés ──────────────────────────
                  _buildSectionTitle('D. Travaux associés'),
                  const SizedBox(height: 8),

                  CheckboxListTile(
                    title: const Text('Destruction des anciennes latrines'),
                    value: _destructionAnciennesLatrines,
                    onChanged: (v) =>
                        setState(() => _destructionAnciennesLatrines = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Construction d\'un mur'),
                    value: _constructionMur,
                    onChanged: (v) => setState(() => _constructionMur = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Tranchées de drainage'),
                    value: _trancheesDrainage,
                    onChanged: (v) => setState(() => _trancheesDrainage = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Point d\'eau / lavage des mains'),
                    value: _pointEauLavage,
                    onChanged: (v) => setState(() => _pointEauLavage = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _autresTravauxController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Autres travaux',
                      hintText: 'Préciser d\'autres travaux éventuels...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Observations ──────────────────────────────────────────
                  _buildSectionTitle('Observations'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _observationsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Observations générales sur les sites...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Enregistrer'),
                          onPressed: _saveFormulaire,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Soumettre'),
                          onPressed: _submitFormulaire,
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

  Widget _buildInfoBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.colorBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.colorBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.colorBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.colorBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.colorBlue,
      ),
    );
  }
}
