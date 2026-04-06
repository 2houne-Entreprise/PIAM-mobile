import 'package:flutter/material.dart';

class DernierSuiviLocalitePage extends StatefulWidget {
  final String formulaireId;
  const DernierSuiviLocalitePage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<DernierSuiviLocalitePage> createState() =>
      _DernierSuiviLocalitePageState();
}

class _DernierSuiviLocalitePageState extends State<DernierSuiviLocalitePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateActivite;
  // ignore: unused_field
  int? _nbHabitants;
  // ignore: unused_field
  int? _nbLatrines;
  // ignore: unused_field
  String? _ameliorations;
  // ignore: unused_field
  String? _degradations;
  final _ameliorationsController = TextEditingController();
  final _degradationsController = TextEditingController();

  @override
  void dispose() {
    _ameliorationsController.dispose();
    _degradationsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateActivite ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => _dateActivite = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questionnaire envoyé'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dernier Suivi Localité')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Point de situation actuel et comparaison avec état initial.',
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de l’activité',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateActivite != null
                            ? '${_dateActivite!.day.toString().padLeft(2, '0')}/'
                                  '${_dateActivite!.month.toString().padLeft(2, '0')}/'
                                  '${_dateActivite!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dateActivite != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'NB d’habitants',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbHabitants = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'NB de latrines',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbLatrines = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ameliorationsController,
                    decoration: const InputDecoration(
                      labelText: 'Améliorations constatées',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _degradationsController,
                    decoration: const InputDecoration(
                      labelText: 'Dégradations constatées',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Envoyer'),
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }
}
