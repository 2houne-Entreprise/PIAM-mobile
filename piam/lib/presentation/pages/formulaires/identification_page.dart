import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/data/reference_data.dart';

/// Formulaire 2 – Identification du site
class IdentificationPage extends StatefulWidget {
  final String formulaireId;

  const IdentificationPage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Localisation en cascade
  int? _selectedWilayaId;
  int? _selectedMoughataaId;
  int? _selectedCommuneId;
  int? _selectedLocaliteId;

  List<Map<String, dynamic>> _moughataas = [];
  List<Map<String, dynamic>> _communes = [];
  List<Map<String, dynamic>> _localites = [];

  // Etablissement
  final _codeAnsadeController = TextEditingController();
  String _etablissement = 'Ecole fondamentale';
  // String _typeInfra = 'Ecole';

  // Marché travaux
  final _intituleProjetController = TextEditingController();
  final _marcheTravauxController = TextEditingController();
  final _numeroMarcheController = TextEditingController();
  final _nomEntrepriseController = TextEditingController();
  final _delaiMarcheController = TextEditingController();

  // Contrôle travaux
  final _marcheControleController = TextEditingController();
  final _bureauControleController = TextEditingController();
  final _nomControleurController = TextEditingController();

  // Statistiques
  final _effectifController = TextEditingController();
  final _nbPotentielsController = TextEditingController();

  static const List<String> _etablissements = [
    'Ecole fondamentale',
    'Lycée',
    'Centre de santé',
    'Poste de santé',
    'Mairie',
    'Mosque',
    'Autre',
  ];

  // static const List<String> _typesInfra = [
  //   'Ecole',
  //   'Centre santé',
  //   'Poste de santé',
  //   'Gare routiere',
  //   'Autre',
  // ];

  @override
  void dispose() {
    _codeAnsadeController.dispose();
    _intituleProjetController.dispose();
    _marcheTravauxController.dispose();
    _numeroMarcheController.dispose();
    _nomEntrepriseController.dispose();
    _delaiMarcheController.dispose();
    _marcheControleController.dispose();
    _bureauControleController.dispose();
    _nomControleurController.dispose();
    _effectifController.dispose();
    _nbPotentielsController.dispose();
    super.dispose();
  }

  void _onWilayaChanged(int? wilayaId) {
    setState(() {
      _selectedWilayaId = wilayaId;
      _selectedMoughataaId = null;
      _selectedCommuneId = null;
      _selectedLocaliteId = null;
      _moughataas = wilayaId != null
          ? ReferenceData.getMoughatasByWilaya(wilayaId)
          : [];
      _communes = [];
      _localites = [];
    });
  }

  void _onMoughataaChanged(int? moughataaId) {
    setState(() {
      _selectedMoughataaId = moughataaId;
      _selectedCommuneId = null;
      _selectedLocaliteId = null;
      _communes = moughataaId != null
          ? ReferenceData.getCommunesByMoughataa(moughataaId)
          : [];
      _localites = [];
    });
  }

  void _onCommuneChanged(int? communeId) {
    setState(() {
      _selectedCommuneId = communeId;
      _selectedLocaliteId = null;
      _localites = communeId != null
          ? ReferenceData.getLocalitesByCommune(communeId)
          : [];
    });
  }

  Future<void> _saveFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identification enregistrée'),
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
          content: Text('Identification soumise pour validation'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification'),
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
                    'Remplissez les informations d\'identification du site',
                  ),
                  const SizedBox(height: 20),

                  // ── Section A : Localisation ──────────────────────────────
                  _buildSectionTitle('A. Localisation géographique'),
                  const SizedBox(height: 12),

                  // Wilaya
                  _buildDropdownField<int>(
                    label: 'Wilaya',
                    value: _selectedWilayaId,
                    items: ReferenceData.wilayas
                        .map(
                          (w) => DropdownMenuItem<int>(
                            value: w['id'] as int,
                            child: Text(w['intitule'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: _onWilayaChanged,
                    hint: 'Sélectionner une wilaya',
                  ),
                  const SizedBox(height: 12),

                  // Moughataa
                  _buildDropdownField<int>(
                    label: 'Moughataa',
                    value: _selectedMoughataaId,
                    items: _moughataas
                        .map(
                          (m) => DropdownMenuItem<int>(
                            value: m['id'] as int,
                            child: Text(m['intitule'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: _onMoughataaChanged,
                    hint: 'Sélectionner une moughataa',
                    enabled: _selectedWilayaId != null,
                  ),
                  const SizedBox(height: 12),

                  // Commune
                  _buildDropdownField<int>(
                    label: 'Commune',
                    value: _selectedCommuneId,
                    items: _communes
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c['id'] as int,
                            child: Text(c['intitule'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: _onCommuneChanged,
                    hint: 'Sélectionner une commune',
                    enabled: _selectedMoughataaId != null,
                  ),
                  const SizedBox(height: 12),

                  // Localité
                  _buildDropdownField<int>(
                    label: 'Localité',
                    value: _selectedLocaliteId,
                    items: _localites
                        .map(
                          (l) => DropdownMenuItem<int>(
                            value: l['id'] as int,
                            child: Text(l['intitule'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLocaliteId = v),
                    hint: 'Sélectionner une localité',
                    enabled: _selectedCommuneId != null,
                  ),
                  const SizedBox(height: 12),

                  // Code ANSADE
                  TextFormField(
                    controller: _codeAnsadeController,
                    decoration: const InputDecoration(
                      labelText: 'Code ANSADE',
                      hintText: 'Ex: 01-1-01-001',
                      prefixIcon: Icon(Icons.code),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? AppStrings.requiredField
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Type d'établissement
                  _buildDropdownField<String>(
                    label: 'Type d\'établissement',
                    value: _etablissement,
                    items: _etablissements
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _etablissement = v ?? _etablissement),
                    hint: 'Type d\'établissement',
                  ),
                  const SizedBox(height: 20),

                  // ── Section B : Marché travaux ────────────────────────────
                  _buildSectionTitle('B. Marché des travaux'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _intituleProjetController,
                    decoration: const InputDecoration(
                      labelText: 'Intitulé du projet',
                      prefixIcon: Icon(Icons.assignment),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? AppStrings.requiredField
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _marcheTravauxController,
                    decoration: const InputDecoration(
                      labelText: 'Marché des travaux',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _numeroMarcheController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro du marché',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _nomEntrepriseController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'entreprise',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _delaiMarcheController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Délai du marché (jours)',
                      prefixIcon: Icon(Icons.timer),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section C : Contrôle des travaux ─────────────────────
                  _buildSectionTitle('C. Contrôle des travaux'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _bureauControleController,
                    decoration: const InputDecoration(
                      labelText: 'Bureau de contrôle',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _nomControleurController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du contrôleur',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section D : Statistiques ──────────────────────────────
                  _buildSectionTitle('D. Population concernée'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _effectifController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Effectif',
                            prefixIcon: Icon(Icons.group),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _nbPotentielsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nb. potentiels',
                            prefixIcon: Icon(Icons.people_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Boutons d'action
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

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String hint,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      isExpanded: true,
    );
  }
}
