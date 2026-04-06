import 'package:flutter/material.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';

class EtatLieuxLocalitePage extends StatefulWidget {
  final String formulaireId;
  const EtatLieuxLocalitePage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<EtatLieuxLocalitePage> createState() => _EtatLieuxLocalitePageState();
}

class _EtatLieuxLocalitePageState extends State<EtatLieuxLocalitePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Localisation et données admin
  int? _localiteId;
  dynamic _userId;

  // Champs principaux
  DateTime? _dateActivite;
  final _nbPopulationController = TextEditingController();
  final _nbHommesController = TextEditingController();
  final _nbFemmesController = TextEditingController();
  final _nbEnfantsController = TextEditingController();
  final _nbMenagesController = TextEditingController();

  // Eau
  bool? _accesEau;
  final _sourceEauController = TextEditingController();
  final _nbMenagesSansEauController = TextEditingController();

  // Latrines
  final _nbLatrinesController = TextEditingController();
  final _nbLatrinesAAmeliorerController = TextEditingController();
  final _nbLatrinesAmelioreesController = TextEditingController();

  // État des latrines
  final _nbLatrinesEndommageesController = TextEditingController();
  final _nbMenagesLatrinesVoisinsController = TextEditingController();
  final _nbMenagesDefecationAirLibreController = TextEditingController();

  // DLM
  final _nbLatrinesAvecDLMController = TextEditingController();
  final _nbDLM_EauSavonController = TextEditingController();
  final _nbDLM_EauSansSavonController = TextEditingController();
  final _nbMenagesSansDLMController = TextEditingController();

  // Observations
  final _observationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nbPopulationController.dispose();
    _nbHommesController.dispose();
    _nbFemmesController.dispose();
    _nbEnfantsController.dispose();
    _nbMenagesController.dispose();
    _sourceEauController.dispose();
    _nbMenagesSansEauController.dispose();
    _nbLatrinesController.dispose();
    _nbLatrinesAAmeliorerController.dispose();
    _nbLatrinesAmelioreesController.dispose();
    _nbLatrinesEndommageesController.dispose();
    _nbMenagesLatrinesVoisinsController.dispose();
    _nbMenagesDefecationAirLibreController.dispose();
    _nbLatrinesAvecDLMController.dispose();
    _nbDLM_EauSavonController.dispose();
    _nbDLM_EauSansSavonController.dispose();
    _nbMenagesSansDLMController.dispose();
    _observationsController.dispose();
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
  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final data = {
      'type': 'etat_lieux_localite',
      'data_json': {
        'dateActivite': _dateActivite?.toIso8601String(),
        'nbPopulation': _nbPopulationController.text,
        'nbHommes': _nbHommesController.text,
        'nbFemmes': _nbFemmesController.text,
        'nbEnfants': _nbEnfantsController.text,
        'nbMenages': _nbMenagesController.text,
        'accesEau': _accesEau,
        'sourceEau': _sourceEauController.text,
        'nbMenagesSansEau': _nbMenagesSansEauController.text,
        'nbLatrines': _nbLatrinesController.text,
        'nbLatrinesAAmeliorer': _nbLatrinesAAmeliorerController.text,
        'nbLatrinesAmeliorees': _nbLatrinesAmelioreesController.text,
        'nbLatrinesEndommagees': _nbLatrinesEndommageesController.text,
        'nbMenagesLatrinesVoisins': _nbMenagesLatrinesVoisinsController.text,
        'nbMenagesDefecationAirLibre':
            _nbMenagesDefecationAirLibreController.text,
        'nbLatrinesAvecDLM': _nbLatrinesAvecDLMController.text,
        'nbDLM_EauSavon': _nbDLM_EauSavonController.text,
        'nbDLM_EauSansSavon': _nbDLM_EauSansSavonController.text,
        'nbMenagesSansDLM': _nbMenagesSansDLMController.text,
        'observations': _observationsController.text,
      }.toString(),
      'date': DateTime.now().toIso8601String(),
      'user_id': _userId,
      'localite_id': _localiteId,
    };
    await db.insertQuestionnaire(data);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questionnaire sauvegardé'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final data = {
      'type': 'etat_lieux_localite',
      'data_json': {
        'dateActivite': _dateActivite?.toIso8601String(),
        'nbPopulation': _nbPopulationController.text,
        'nbHommes': _nbHommesController.text,
        'nbFemmes': _nbFemmesController.text,
        'nbEnfants': _nbEnfantsController.text,
        'nbMenages': _nbMenagesController.text,
        'accesEau': _accesEau,
        'sourceEau': _sourceEauController.text,
        'nbMenagesSansEau': _nbMenagesSansEauController.text,
        'nbLatrines': _nbLatrinesController.text,
        'nbLatrinesAAmeliorer': _nbLatrinesAAmeliorerController.text,
        'nbLatrinesAmeliorees': _nbLatrinesAmelioreesController.text,
        'nbLatrinesEndommagees': _nbLatrinesEndommageesController.text,
        'nbMenagesLatrinesVoisins': _nbMenagesLatrinesVoisinsController.text,
        'nbMenagesDefecationAirLibre':
            _nbMenagesDefecationAirLibreController.text,
        'nbLatrinesAvecDLM': _nbLatrinesAvecDLMController.text,
        'nbDLM_EauSavon': _nbDLM_EauSavonController.text,
        'nbDLM_EauSansSavon': _nbDLM_EauSansSavonController.text,
        'nbMenagesSansDLM': _nbMenagesSansDLMController.text,
        'observations': _observationsController.text,
      }.toString(),
      'date': DateTime.now().toIso8601String(),
      'user_id': _userId,
      'localite_id': _localiteId,
    };
    await db.insertQuestionnaire(data);
    await Future.delayed(const Duration(milliseconds: 800));
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
      appBar: AppBar(title: const Text('État des Lieux – Localité')),
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
                  const SizedBox(height: 12),
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
                  const Divider(height: 32),
                  // 3. Population
                  const Text(
                    'Population',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _nbPopulationController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre total de population',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: _nbHommesController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre d’hommes',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbFemmesController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de femmes',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbEnfantsController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre d’enfants de moins de 5 ans',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbMenagesController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de ménages',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(height: 32),
                  // 4. Accès à l’eau
                  const Text(
                    'Accès à l’eau',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Text('Accès à l’eau potable ?'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<bool>(
                          value: _accesEau,
                          items: const [
                            DropdownMenuItem(value: true, child: Text('Oui')),
                            DropdownMenuItem(value: false, child: Text('Non')),
                          ],
                          onChanged: (v) => setState(() => _accesEau = v),
                          validator: (v) => v == null ? 'Champ requis' : null,
                        ),
                      ),
                    ],
                  ),
                  if (_accesEau == true)
                    TextFormField(
                      controller: _sourceEauController,
                      decoration: const InputDecoration(
                        labelText: 'Source d’eau (forage, puits, etc.)',
                      ),
                    ),
                  if (_accesEau == false)
                    TextFormField(
                      controller: _nbMenagesSansEauController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de ménages sans accès à l’eau',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  const Divider(height: 32),
                  // 5. Assainissement (latrines)
                  const Text(
                    'Assainissement (latrines)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _nbLatrinesController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre total de latrines familiales',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbLatrinesAAmeliorerController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de latrines à améliorer',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbLatrinesAmelioreesController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de latrines améliorées',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(height: 32),
                  // 6. État des latrines
                  const Text(
                    'État des latrines',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _nbLatrinesEndommageesController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de latrines endommagées',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbMenagesLatrinesVoisinsController,
                    decoration: const InputDecoration(
                      labelText:
                          'Nombre de ménages utilisant latrines des voisins',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbMenagesDefecationAirLibreController,
                    decoration: const InputDecoration(
                      labelText:
                          'Nombre de ménages pratiquant la défécation à l’air libre',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(height: 32),
                  // 7. Dispositif de lavage des mains (DLM)
                  const Text(
                    'Dispositif de lavage des mains (DLM)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _nbLatrinesAvecDLMController,
                    decoration: const InputDecoration(
                      labelText:
                          'Nombre de latrines avec dispositif de lavage des mains',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Text('Détail DLM :'),
                  TextFormField(
                    controller: _nbDLM_EauSavonController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de dispositifs avec eau + savon',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbDLM_EauSansSavonController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de dispositifs avec eau sans savon',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _nbMenagesSansDLMController,
                    decoration: const InputDecoration(
                      labelText:
                          'Nombre de ménages sans dispositif de lavage des mains',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(height: 32),
                  // 8. Observations
                  const Text(
                    'Observations',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _observationsController,
                    decoration: const InputDecoration(
                      labelText: 'Remarques de l’enquêteur',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  // 9. Validation
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _saveDraft,
                          child: const Text('Enregistrer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Envoyer'),
                          onPressed: _isLoading ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
