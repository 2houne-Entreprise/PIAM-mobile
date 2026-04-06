import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';

/// Formulaire 5 – Personnel et équipes
class EquipesPage extends StatefulWidget {
  final String formulaireId;

  const EquipesPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<EquipesPage> createState() => _EquipesPageState();
}

class _EquipesPageState extends State<EquipesPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateDemarrage;
  bool _premierSecours = false;
  final _remarquesController = TextEditingController();

  // Membres de l'équipe: nom, rôle, casque, gants, chaussures, gilet
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

  @override
  void initState() {
    super.initState();
    _membres.add(_MembreEquipe());
  }

  @override
  void dispose() {
    _remarquesController.dispose();
    for (final m in _membres) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateDemarrage ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _dateDemarrage = picked);
  }

  void _addMembre() => setState(() => _membres.add(_MembreEquipe()));

  void _removeMembre(int index) {
    setState(() {
      _membres[index].dispose();
      _membres.removeAt(index);
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
          content: Text('Équipes enregistrées'),
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
          content: Text('Équipes soumises pour validation'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel et équipes'),
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
                    'Renseignez les membres de l\'équipe et leurs équipements de protection',
                  ),
                  const SizedBox(height: 20),

                  // ── Section A : Démarrage ─────────────────────────────────
                  _buildSectionTitle('A. Démarrage des travaux'),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de démarrage',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateDemarrage != null
                            ? '${_dateDemarrage!.day.toString().padLeft(2, '0')}/'
                                  '${_dateDemarrage!.month.toString().padLeft(2, '0')}/'
                                  '${_dateDemarrage!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dateDemarrage != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  SwitchListTile(
                    title: const Text('Trousse de premiers secours disponible'),
                    value: _premierSecours,
                    onChanged: (v) => setState(() => _premierSecours = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),

                  // ── Section B : Membres ───────────────────────────────────
                  _buildSectionTitle('B. Membres de l\'équipe'),
                  const SizedBox(height: 12),

                  ..._membres.asMap().entries.map(
                    (e) => _buildMembreCard(e.key, e.value),
                  ),

                  TextButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Ajouter un membre'),
                    onPressed: _addMembre,
                  ),
                  const SizedBox(height: 20),

                  // ── Remarques ─────────────────────────────────────────────
                  _buildSectionTitle('Remarques'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _remarquesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Remarques sur l\'équipe et les conditions de travail...',
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

  Widget _buildMembreCard(int index, _MembreEquipe membre) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Membre ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_membres.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () => _removeMembre(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: membre.nomController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                isDense: true,
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: membre.role,
              items: _roles
                  .map(
                    (r) => DropdownMenuItem<String>(value: r, child: Text(r)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => membre.role = v),
              decoration: const InputDecoration(
                labelText: 'Rôle / Fonction',
                isDense: true,
              ),
              isExpanded: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'EPI fournis :',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Wrap(
              children: [
                _epiChip('Casque', membre.casque, (v) {
                  setState(() => membre.casque = v!);
                }),
                _epiChip('Gants', membre.gants, (v) {
                  setState(() => membre.gants = v!);
                }),
                _epiChip('Chaussures', membre.chaussures, (v) {
                  setState(() => membre.chaussures = v!);
                }),
                _epiChip('Gilet', membre.gilet, (v) {
                  setState(() => membre.gilet = v!);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _epiChip(String label, bool value, ValueChanged<bool?> onChange) {
    return SizedBox(
      width: 130,
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChange,
        dense: true,
        contentPadding: EdgeInsets.zero,
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

class _MembreEquipe {
  final nomController = TextEditingController();
  String? role = 'Maçon';
  bool casque = false;
  bool gants = false;
  bool chaussures = false;
  bool gilet = false;

  void dispose() => nomController.dispose();
}
