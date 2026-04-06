import 'package:flutter/material.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';

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

  int? _nbPersonnes;
  int? _nbLatrines;
  bool _lavageMains = false;
  final _evolutionController = TextEditingController();

  bool _showLatrinesOui = false;
  bool _showLatrinesNon = false;

  int? _localiteId;
  dynamic _userId;

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

    try {
      final db = DatabaseService();
      
      final data = {
        'type': 'dernier_suivi_menage',
        'data_json': {
          'nb_personnes': _nbPersonnes,
          'nb_latrines': _nbLatrines,
          'latrines_existe': _latrinesExiste,
          'lavage_mains': _lavageMains,
          'evolution': _evolutionController.text,
        }.toString(),
        'date': DateTime.now().toIso8601String(),
        'user_id': _userId,
        'localite_id': _localiteId,
      };
      
      await db.insertQuestionnaire(data);
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dernier Suivi Ménage enregistré avec succès'),
            backgroundColor: Color.fromARGB(255, 16, 185, 129),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                  // Bloc d'En-tête Partagé (Localisation)
                  FormHeaderWidget(
                    onDataLoaded: (localiteId, userId) {
                      setState(() {
                        _localiteId = localiteId;
                        _userId = userId;
                      });
                    },
                  ),

                  const Text(
                    'Suivi des conditions domestiques et évolution depuis le dernier état.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'NB de personnes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbPersonnes = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'NB de latrines',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbLatrines = int.tryParse(v ?? ''),
                  ),
                  const SizedBox(height: 16),
                  const Text('Existence de latrines ?', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
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
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                      ),
                    ),
                  if (_showLatrinesNon)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Formulaire spécifique pour latrines NON (à compléter selon besoins)',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                      ),
                    ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text(
                      'Disposez-vous d’un dispositif de lavage de mains ?',
                    ),
                    value: _lavageMains,
                    onChanged: (v) => setState(() => _lavageMains = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _evolutionController,
                    decoration: const InputDecoration(
                      labelText: 'Évolution depuis le dernier état',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Envoyer'),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
