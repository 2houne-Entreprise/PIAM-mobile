import 'package:flutter/material.dart';

class DernierSuiviMenagePage extends StatefulWidget {
  final String formulaireId;
  const DernierSuiviMenagePage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<DernierSuiviMenagePage> createState() => _DernierSuiviMenagePageState();
}

class _DernierSuiviMenagePageState extends State<DernierSuiviMenagePage> {
  bool? _latrinesExiste;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ignore: unused_field
  int? _nbPersonnes;
  // ignore: unused_field
  int? _nbLatrines;
  bool _lavageMains = false;
  // ignore: unused_field
  String? _evolution;
  final _evolutionController = TextEditingController();

  bool _showLatrinesOui = false;
  bool _showLatrinesNon = false;

  @override
  void dispose() {
    _evolutionController.dispose();
    super.dispose();
  }

  void _onLatrinesChanged(bool? value) {
    setState(() {
      _latrinesExiste = value;
      _showLatrinesOui = value == true;
      _showLatrinesNon = value == false;
    });
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
      appBar: AppBar(title: const Text('Dernier Suivi Ménage')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Suivi des conditions domestiques et évolution depuis le dernier état.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'NB de personnes',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbPersonnes = int.tryParse(v ?? ''),
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
                  const Text('Existence de latrines ?'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Oui'),
                          value: true,
                          groupValue: _latrinesExiste,
                          onChanged: _onLatrinesChanged,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Non'),
                          value: false,
                          groupValue: _latrinesExiste,
                          onChanged: _onLatrinesChanged,
                        ),
                      ),
                    ],
                  ),
                  if (_showLatrinesOui)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Formulaire spécifique pour latrines OUI (à compléter selon besoins)',
                      ),
                    ),
                  if (_showLatrinesNon)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Formulaire spécifique pour latrines NON (à compléter selon besoins)',
                      ),
                    ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text(
                      'Disposez-vous d’un dispositif de lavage de mains ?',
                    ),
                    value: _lavageMains,
                    onChanged: (v) => setState(() => _lavageMains = v ?? false),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _evolutionController,
                    decoration: const InputDecoration(
                      labelText: 'Évolution depuis le dernier état',
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
