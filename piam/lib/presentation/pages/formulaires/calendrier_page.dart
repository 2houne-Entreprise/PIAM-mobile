import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';

/// Formulaire 6 – Calendrier des travaux
class CalendrierPage extends StatefulWidget {
  final String formulaireId;

  const CalendrierPage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendrierPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateDebutPrevue;
  DateTime? _dateFinPrevue;
  DateTime? _dateDebutReelle;
  DateTime? _dateFinReelle;

  double _avancement = 0;
  final _observationsController = TextEditingController();

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
    _jalons.add(_Jalon());
  }

  @override
  void dispose() {
    _observationsController.dispose();
    for (final j in _jalons) {
      j.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );

  String _formatDate(DateTime? d) {
    if (d == null) return 'Sélectionner';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> _saveFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calendrier enregistré'),
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
          content: Text('Calendrier soumis pour validation'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des travaux'),
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
                    'Renseignez le calendrier prévisionnel et réel des travaux',
                  ),
                  const SizedBox(height: 20),

                  // ── Section A : Dates prévisionnelles ─────────────────────
                  _buildSectionTitle('A. Dates prévisionnelles'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await _pickDate(_dateDebutPrevue);
                            if (d != null) setState(() => _dateDebutPrevue = d);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Début prévu',
                              prefixIcon: Icon(Icons.event),
                              isDense: true,
                            ),
                            child: Text(
                              _formatDate(_dateDebutPrevue),
                              style: TextStyle(
                                color: _dateDebutPrevue != null
                                    ? Colors.black87
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await _pickDate(_dateFinPrevue);
                            if (d != null) setState(() => _dateFinPrevue = d);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fin prévue',
                              prefixIcon: Icon(Icons.event_available),
                              isDense: true,
                            ),
                            child: Text(
                              _formatDate(_dateFinPrevue),
                              style: TextStyle(
                                color: _dateFinPrevue != null
                                    ? Colors.black87
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Section B : Dates réelles ─────────────────────────────
                  _buildSectionTitle('B. Dates réelles d\'exécution'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await _pickDate(_dateDebutReelle);
                            if (d != null) setState(() => _dateDebutReelle = d);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Début réel',
                              prefixIcon: Icon(Icons.play_circle_outline),
                              isDense: true,
                            ),
                            child: Text(
                              _formatDate(_dateDebutReelle),
                              style: TextStyle(
                                color: _dateDebutReelle != null
                                    ? Colors.black87
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await _pickDate(_dateFinReelle);
                            if (d != null) setState(() => _dateFinReelle = d);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fin réelle',
                              prefixIcon: Icon(Icons.stop_circle_outlined),
                              isDense: true,
                            ),
                            child: Text(
                              _formatDate(_dateFinReelle),
                              style: TextStyle(
                                color: _dateFinReelle != null
                                    ? Colors.black87
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Section C : Avancement ─────────────────────────────────
                  _buildSectionTitle('C. Taux d\'avancement'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _avancement,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '${_avancement.toInt()} %',
                          onChanged: (v) => setState(() => _avancement = v),
                        ),
                      ),
                      SizedBox(
                        width: 56,
                        child: Text(
                          '${_avancement.toInt()} %',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Section D : Jalons ─────────────────────────────────────
                  _buildSectionTitle('D. Jalons du projet'),
                  const SizedBox(height: 12),

                  ..._jalons.asMap().entries.map(
                    (e) => _buildJalonCard(e.key, e.value),
                  ),

                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un jalon'),
                    onPressed: () => setState(() => _jalons.add(_Jalon())),
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
                          'Observations sur le déroulement du chantier...',
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

  Widget _buildJalonCard(int index, _Jalon jalon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: jalon.nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du jalon',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: jalon.statut,
                    items: _statutsJalon
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => jalon.statut = v!),
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      isDense: true,
                    ),
                    isExpanded: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _jalons[index].dispose();
                      _jalons.removeAt(index);
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final d = await _pickDate(jalon.date);
                if (d != null) setState(() => jalon.date = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date du jalon',
                  prefixIcon: Icon(Icons.calendar_month),
                  isDense: true,
                ),
                child: Text(
                  _formatDate(jalon.date),
                  style: TextStyle(
                    color: jalon.date != null ? Colors.black87 : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
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

class _Jalon {
  final nomController = TextEditingController();
  String statut = 'Planifié';
  DateTime? date;

  void dispose() => nomController.dispose();
}
