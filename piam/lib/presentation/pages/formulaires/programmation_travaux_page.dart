import 'package:flutter/material.dart';

class ProgrammationTravauxPage extends StatefulWidget {
  final String formulaireId;
  const ProgrammationTravauxPage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<ProgrammationTravauxPage> createState() =>
      _ProgrammationTravauxPageState();
}

class _ProgrammationTravauxPageState extends State<ProgrammationTravauxPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateActivite;
  // ignore: unused_field
  int? _nbTravaux;
  // ignore: unused_field
  String? _autre;
  final _autreController = TextEditingController();

  @override
  void dispose() {
    _autreController.dispose();
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
      appBar: AppBar(title: const Text('Programmation des Travaux')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Programmation des travaux à venir.'),
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
                      labelText: 'NB de travaux programmés',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbTravaux = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _autreController,
                    decoration: const InputDecoration(
                      labelText: 'Autre (texte libre)',
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
