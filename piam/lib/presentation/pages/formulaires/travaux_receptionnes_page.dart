import 'package:flutter/material.dart';

class TravauxReceptionnesPage extends StatefulWidget {
  final String formulaireId;
  const TravauxReceptionnesPage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<TravauxReceptionnesPage> createState() =>
      _TravauxReceptionnesPageState();
}

class _TravauxReceptionnesPageState extends State<TravauxReceptionnesPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateReception;
  // ignore: unused_field
  int? _nbTravaux;
  // ignore: unused_field
  String? _autre;
  String? _imagePath;
  final _autreController = TextEditingController();

  @override
  void dispose() {
    _autreController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateReception ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => _dateReception = d);
  }

  Future<void> _pickImage() async {
    // TODO: Intégrer la sélection d'image (image_picker)
    setState(() => _imagePath = 'image_exemple.jpg');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image sélectionnée (simulation)')),
    );
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
      appBar: AppBar(title: const Text('Travaux Réceptionnés')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Validation des réalisations et conformité aux spécifications.',
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateReception != null
                            ? '${_dateReception!.day.toString().padLeft(2, '0')}/'
                                  '${_dateReception!.month.toString().padLeft(2, '0')}/'
                                  '${_dateReception!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dateReception != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'NB de travaux réceptionnés',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbTravaux = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Ajouter une image'),
                        onPressed: _pickImage,
                      ),
                      const SizedBox(width: 12),
                      if (_imagePath != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
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
