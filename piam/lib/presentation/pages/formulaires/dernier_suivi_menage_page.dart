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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int? _localiteId;
  dynamic _userId;

  // Latrine
  bool? _latrineExiste;
  bool? _ancienneLatrineDegradee;
  bool? _utilisationLatrineVoisin;
  bool? _dal;
  String? _photoPath;
  bool? _latrineAmelioree;
  int? _nbMenagesPartageLatrine;

  // DLM
  bool? _dlmExiste;
  String? _typeDlm; // 'eau+savon', 'eau seule', 'aucun'

  // Pour la gestion de la photo (à adapter selon votre logique de prise de photo)
  Future<void> _pickPhoto() async {
    // TODO: Intégrer la logique de prise ou sélection de photo
    setState(() {
      _photoPath = 'photo_path.jpg'; // Placeholder
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
          'latrine_existe': _latrineExiste,
          'ancienne_latrine_degradee': _latrineExiste == false
              ? _ancienneLatrineDegradee
              : null,
          'utilisation_latrine_voisin': _latrineExiste == false
              ? _utilisationLatrineVoisin
              : null,
          'dal': _latrineExiste == false ? _dal : null,
          'photo': _latrineExiste == true ? _photoPath : null,
          'latrine_amelioree': _latrineExiste == true
              ? _latrineAmelioree
              : null,
          'nb_menages_partage_latrine': _latrineExiste == true
              ? _nbMenagesPartageLatrine
              : null,
          'dlm_existe': _dlmExiste,
          'type_dlm': _dlmExiste == true ? _typeDlm : null,
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
                  FormHeaderWidget(
                    onDataLoaded: (localiteId, userId) {
                      setState(() {
                        _localiteId = localiteId;
                        _userId = userId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Latrine
                  const Text(
                    'Latrine',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Oui'),
                          value: true,
                          groupValue: _latrineExiste,
                          onChanged: (v) => setState(() => _latrineExiste = v),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Non'),
                          value: false,
                          groupValue: _latrineExiste,
                          onChanged: (v) => setState(() => _latrineExiste = v),
                        ),
                      ),
                    ],
                  ),
                  if (_latrineExiste == false) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Ancienne latrine dégradée'),
                            value: _ancienneLatrineDegradee ?? false,
                            onChanged: (v) =>
                                setState(() => _ancienneLatrineDegradee = v),
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Utilisation latrine voisin'),
                            value: _utilisationLatrineVoisin ?? false,
                            onChanged: (v) =>
                                setState(() => _utilisationLatrineVoisin = v),
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      title: const Text('Défécation à l’air libre'),
                      value: _dal ?? false,
                      onChanged: (v) => setState(() => _dal = v),
                    ),
                  ],
                  if (_latrineExiste == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Latrine améliorée'),
                            value: _latrineAmelioree ?? false,
                            onChanged: (v) =>
                                setState(() => _latrineAmelioree = v),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText:
                                  'Nombre de ménages partageant la latrine',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                _nbMenagesPartageLatrine = int.tryParse(v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Prendre une photo'),
                            onPressed: _pickPhoto,
                          ),
                        ),
                        if (_photoPath != null)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  // DLM
                  const Text(
                    'Dispositif de lavage des mains',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Oui'),
                          value: true,
                          groupValue: _dlmExiste,
                          onChanged: (v) => setState(() => _dlmExiste = v),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Non'),
                          value: false,
                          groupValue: _dlmExiste,
                          onChanged: (v) => setState(() => _dlmExiste = v),
                        ),
                      ),
                    ],
                  ),
                  if (_dlmExiste == true) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _typeDlm,
                      items: const [
                        DropdownMenuItem(
                          value: 'eau+savon',
                          child: Text('Eau + savon'),
                        ),
                        DropdownMenuItem(
                          value: 'eau seule',
                          child: Text('Eau seule'),
                        ),
                        DropdownMenuItem(value: 'aucun', child: Text('Aucun')),
                      ],
                      onChanged: (v) => setState(() => _typeDlm = v),
                      decoration: const InputDecoration(
                        labelText: 'Type de dispositif',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Envoyer'),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
