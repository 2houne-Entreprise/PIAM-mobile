import 'package:flutter/material.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';

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

  int? _localiteId;
  dynamic _userId;

  DateTime? _dateActivite;
  int? _nbHabitants;
  int? _nbLatrines;

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
    
    try {
      final db = DatabaseService();
      
      final data = {
        'type': 'dernier_suivi_localite',
        'data_json': {
          'dateActivite': _dateActivite?.toIso8601String(),
          'nbHabitants': _nbHabitants,
          'nbLatrines': _nbLatrines,
          'ameliorations': _ameliorationsController.text,
          'degradations': _degradationsController.text,
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
            content: Text('Dernier Suivi Localité enregistré avec succès'),
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
      appBar: AppBar(title: const Text('Dernier Suivi Localité')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FormHeaderWidget(
                    onDataLoaded: (localiteId, userId) {
                      setState(() {
                        _localiteId = localiteId;
                        _userId = userId;
                      });
                    },
                  ),
                  const Text(
                    'Point de situation actuel et comparaison avec l\'état initial.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de l’activité',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'NB d’habitants',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                    onSaved: (v) => _nbHabitants = int.tryParse(v ?? ''),
                    onChanged: (v) => _nbHabitants = int.tryParse(v),
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
                    onChanged: (v) => _nbLatrines = int.tryParse(v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ameliorationsController,
                    decoration: const InputDecoration(
                      labelText: 'Améliorations constatées',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _degradationsController,
                    decoration: const InputDecoration(
                      labelText: 'Dégradations constatées',
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
