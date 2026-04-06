import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';

/// Formulaire 7 – Rapports de contrôle
class RapportsPage extends StatefulWidget {
  final String formulaireId;

  const RapportsPage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<RapportsPage> createState() => _RapportsPageState();
}

class _RapportsPageState extends State<RapportsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateVisite;
  final _travauxRealisesController = TextEditingController();
  final _nonConformitesController = TextEditingController();
  final _mesuresCorractivesController = TextEditingController();
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
    _travauxRealisesController.dispose();
    _nonConformitesController.dispose();
    _mesuresCorractivesController.dispose();
    _recommandationsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateVisite ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => _dateVisite = d);
  }

  Future<void> _saveFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport enregistré'),
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
          content: Text('Rapport soumis pour validation'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport de contrôle'),
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
                    'Renseignez le rapport de visite de contrôle des travaux',
                  ),
                  const SizedBox(height: 20),

                  // ── Section A : Date de visite ─────────────────────────────
                  _buildSectionTitle('A. Date de visite'),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de visite *',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateVisite != null
                            ? '${_dateVisite!.day.toString().padLeft(2, '0')}/'
                                  '${_dateVisite!.month.toString().padLeft(2, '0')}/'
                                  '${_dateVisite!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dateVisite != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section B : Travaux réalisés ──────────────────────────
                  _buildSectionTitle(
                    'B. Travaux réalisés depuis la dernière visite',
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _travauxRealisesController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Décrire les travaux réalisés...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Section C : Grille de conformité ──────────────────────
                  _buildSectionTitle('C. Grille de conformité'),
                  const SizedBox(height: 12),

                  ..._conformites.keys.map(
                    (critere) => _buildConformiteRow(critere),
                  ),
                  const SizedBox(height: 20),

                  // ── Section D : Note globale ──────────────────────────────
                  _buildSectionTitle('D. Note globale de la visite'),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        icon: Icon(
                          i < _noteGlobale ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setState(() => _noteGlobale = i + 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section E : Non-conformités ───────────────────────────
                  _buildSectionTitle('E. Non-conformités observées'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _nonConformitesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Décrire les non-conformités observées...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section F : Mesures correctives ───────────────────────
                  _buildSectionTitle('F. Mesures correctives prescrites'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _mesuresCorractivesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Décrire les mesures correctives...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Recommandations ───────────────────────────────────────
                  _buildSectionTitle('Recommandations'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _recommandationsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Recommandations pour la prochaine visite...',
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

  Widget _buildConformiteRow(String critere) {
    final val = _conformites[critere];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(critere, style: const TextStyle(fontSize: 14))),
          ToggleButtons(
            isSelected: [val == true, val == null, val == false],
            onPressed: (index) {
              setState(() {
                if (index == 0) _conformites[critere] = true;
                if (index == 1) _conformites[critere] = null;
                if (index == 2) _conformites[critere] = false;
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 36),
            color: Colors.grey,
            fillColor: val == true
                ? Colors.green
                : val == false
                ? Colors.red
                : Colors.grey.shade300,
            children: const [
              Icon(Icons.check, size: 18),
              Icon(Icons.remove, size: 18),
              Icon(Icons.close, size: 18),
            ],
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
