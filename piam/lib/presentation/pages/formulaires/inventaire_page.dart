import 'package:flutter/material.dart';

class InventairePage extends StatefulWidget {
  final String formulaireId;
  const InventairePage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<InventairePage> createState() => _InventairePageState();
}

class _InventairePageState extends State<InventairePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateActivite;
  // ignore: unused_field
  int? _nbEquipements;
  bool _lavageMains = false;
  bool? _accesAssainissement;
  // ignore: unused_field
  String? _autre;
  final _autreController = TextEditingController();

  bool _showAccesOui = false;
  bool _showAccesNon = false;

  @override
  void dispose() {
    _autreController.dispose();
    super.dispose();
  }

  void _onAccesChanged(bool? value) {
    setState(() {
      _accesAssainissement = value;
      _showAccesOui = value == true;
      _showAccesNon = value == false;
    });
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
      appBar: AppBar(title: const Text('Inventaire')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Liste complète des équipements.'),
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
                      labelText: 'NB d’équipements',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbEquipements = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Dispositif de lavage de mains'),
                    value: _lavageMains,
                    onChanged: (v) => setState(() => _lavageMains = v ?? false),
                  ),
                  const SizedBox(height: 12),
                  const Text('Accès à l’assainissement ?'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Oui'),
                          value: true,
                          groupValue: _accesAssainissement,
                          onChanged: _onAccesChanged,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Non'),
                          value: false,
                          groupValue: _accesAssainissement,
                          onChanged: _onAccesChanged,
                        ),
                      ),
                    ],
                  ),
                  if (_showAccesOui)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Formulaire spécifique pour accès OUI (à compléter selon besoins)',
                      ),
                    ),
                  if (_showAccesNon)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Formulaire spécifique pour accès NON (à compléter selon besoins)',
                      ),
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
