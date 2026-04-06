import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';

/// Formulaire 3 – Organisation du chantier
class OrganisationPage extends StatefulWidget {
  final String formulaireId;

  const OrganisationPage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<OrganisationPage> createState() => _OrganisationPageState();
}

class _OrganisationPageState extends State<OrganisationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _chefChantierController = TextEditingController();
  final _nomEntrepriseController = TextEditingController();
  final _effectifOuvrierController = TextEditingController();
  final _effectifEncadrementController = TextEditingController();
  final _observationsController = TextEditingController();

  // Équipements de protection
  bool _casques = false;
  bool _gants = false;
  bool _chaussures = false;
  bool _gilets = false;
  bool _masques = false;

  // Main d'œuvre
  String _origineMainOeuvre = 'Locale';
  static const List<String> _origines = ['Locale', 'Régionale', 'Nationale'];

  // Matériaux
  final _materiaux = <Map<String, TextEditingController>>[];

  @override
  void initState() {
    super.initState();
    // Ajouter une ligne de matériau par défaut
    _addMateriau();
  }

  void _addMateriau() {
    setState(() {
      _materiaux.add({
        'nom': TextEditingController(),
        'quantite': TextEditingController(),
        'qualite': TextEditingController(),
      });
    });
  }

  void _removeMateriau(int index) {
    setState(() {
      _materiaux[index].forEach((_, c) => c.dispose());
      _materiaux.removeAt(index);
    });
  }

  @override
  void dispose() {
    _chefChantierController.dispose();
    _nomEntrepriseController.dispose();
    _effectifOuvrierController.dispose();
    _effectifEncadrementController.dispose();
    _observationsController.dispose();
    for (final m in _materiaux) {
      m.forEach((_, c) => c.dispose());
    }
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
          content: Text('Organisation enregistrée'),
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
          content: Text('Organisation soumise pour validation'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organisation du chantier'),
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
                    'Renseignez l\'organisation du chantier et les ressources humaines',
                  ),
                  const SizedBox(height: 20),

                  // ── Section A : Encadrement ───────────────────────────────
                  _buildSectionTitle('A. Encadrement du chantier'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _chefChantierController,
                    decoration: const InputDecoration(
                      labelText: 'Chef de chantier',
                      prefixIcon: Icon(Icons.engineering),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? AppStrings.requiredField
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _nomEntrepriseController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'entreprise',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? AppStrings.requiredField
                        : null,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _effectifOuvrierController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Effectif ouvriers',
                            prefixIcon: Icon(Icons.construction),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _effectifEncadrementController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Encadrement',
                            prefixIcon: Icon(Icons.supervisor_account),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _origineMainOeuvre,
                    items: _origines
                        .map(
                          (o) => DropdownMenuItem<String>(
                            value: o,
                            child: Text(o),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(
                      () => _origineMainOeuvre = v ?? _origineMainOeuvre,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Origine main d\'œuvre',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 20),

                  // ── Section B : EPI ───────────────────────────────────────
                  _buildSectionTitle('B. Équipements de protection (EPI)'),
                  const SizedBox(height: 8),
                  _buildEpiCheckboxes(),
                  const SizedBox(height: 20),

                  // ── Section C : Matériaux ─────────────────────────────────
                  _buildSectionTitle('C. Matériaux et approvisionnement'),
                  const SizedBox(height: 12),

                  ..._materiaux.asMap().entries.map(
                    (entry) => _buildMateriauxRow(entry.key, entry.value),
                  ),

                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un matériau'),
                    onPressed: _addMateriau,
                  ),
                  const SizedBox(height: 20),

                  // ── Observations ──────────────────────────────────────────
                  _buildSectionTitle('Observations'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _observationsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Observations sur l\'organisation du chantier...',
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

  Widget _buildEpiCheckboxes() {
    final items = [
      ('Casques', _casques, (v) => setState(() => _casques = v!)),
      ('Gants', _gants, (v) => setState(() => _gants = v!)),
      (
        'Chaussures de sécurité',
        _chaussures,
        (v) => setState(() => _chaussures = v!),
      ),
      ('Gilets', _gilets, (v) => setState(() => _gilets = v!)),
      ('Masques', _masques, (v) => setState(() => _masques = v!)),
    ];
    return Wrap(
      children: items
          .map(
            (item) => SizedBox(
              width: 160,
              child: CheckboxListTile(
                title: Text(item.$1, style: const TextStyle(fontSize: 13)),
                value: item.$2,
                onChanged: item.$3,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMateriauxRow(int index, Map<String, TextEditingController> row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: row['nom'],
              decoration: const InputDecoration(
                labelText: 'Matériau',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: row['quantite'],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: row['qualite'],
              decoration: const InputDecoration(
                labelText: 'Qualité',
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _removeMateriau(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
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
