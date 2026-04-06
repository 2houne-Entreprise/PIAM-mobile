import 'package:flutter/material.dart';
import 'package:piam/services/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EtatLieuxMenagePage extends StatefulWidget {
  final String formulaireId;
  const EtatLieuxMenagePage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<EtatLieuxMenagePage> createState() => _EtatLieuxMenagePageState();
}

class _EtatLieuxMenagePageState extends State<EtatLieuxMenagePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Localisation et données admin
  String? _localisationInfo;
  DateTime? _dateActivite;

  // Composition ménage
  final _nbTotalController = TextEditingController();
  final _nbHommesController = TextEditingController();
  final _nbFemmesController = TextEditingController();
  final _nbEnfantsController = TextEditingController();

  // Eau
  bool? _accesEau;
  final _difficulteEauController = TextEditingController();

  // Latrines
  bool? _latrinesExiste;
  // Formulaire A (si oui)
  String? _typeLatrine;
  bool? _latrineAmelioree;
  bool? _latrineDegradee;
  bool? _latrineUsageToujours;
  bool? _latrineVoisin;
  bool? _latrineDefecation;
  // Formulaire B (si non)
  bool? _latrineVoisinNon;
  bool? _latrineDefecationNon;

  // DLM
  bool? _dlmExiste;
  String? _typeDLM; // 'eau_savon', 'eau_seule', 'aucun'

  // Photo
  XFile? _photo;
  final ImagePicker _picker = ImagePicker();

  // Observations
  final _observationsController = TextEditingController();

  // ...existing code...

  @override
  void initState() {
    super.initState();
    _loadLocalisation();
  }

  Future<void> _loadLocalisation() async {
    final db = DatabaseService();
    final param = await db.getParametreUtilisateur();
    setState(() {
      _localisationInfo = [
        if (param != null && param['localite_id'] != null)
          'Localité: ${param['localite_id']}',
        if (param != null && param['commune_id'] != null)
          'Commune: ${param['commune_id']}',
        if (param != null && param['moughataa_id'] != null)
          'Moughataa: ${param['moughataa_id']}',
        if (param != null && param['wilaya_id'] != null)
          'Wilaya: ${param['wilaya_id']}',
        if (param != null &&
            param['gps_lat'] != null &&
            param['gps_lng'] != null)
          'GPS: ${param['gps_lat']}, ${param['gps_lng']}',
      ].where((e) => e.isNotEmpty).join(' | ');
    });
  }

  @override
  void dispose() {
    _nbTotalController.dispose();
    _nbHommesController.dispose();
    _nbFemmesController.dispose();
    _nbEnfantsController.dispose();
    _difficulteEauController.dispose();
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

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo obligatoire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final param = await db.getParametreUtilisateur();
    final data = {
      'type': 'etat_lieux_menage',
      'data_json': {
        'dateActivite': _dateActivite?.toIso8601String(),
        'nbTotal': _nbTotalController.text,
        'nbHommes': _nbHommesController.text,
        'nbFemmes': _nbFemmesController.text,
        'nbEnfants': _nbEnfantsController.text,
        'accesEau': _accesEau,
        'difficulteEau': _difficulteEauController.text,
        'latrinesExiste': _latrinesExiste,
        'typeLatrine': _typeLatrine,
        'latrineAmelioree': _latrineAmelioree,
        'latrineDegradee': _latrineDegradee,
        'latrineUsageToujours': _latrineUsageToujours,
        'latrineVoisin': _latrineVoisin,
        'latrineDefecation': _latrineDefecation,
        'latrineVoisinNon': _latrineVoisinNon,
        'latrineDefecationNon': _latrineDefecationNon,
        'dlmExiste': _dlmExiste,
        'typeDLM': _typeDLM,
        'photoPath': _photo?.path,
        'observations': _observationsController.text,
      }.toString(),
      'date': DateTime.now().toIso8601String(),
      'user_id': null,
      'localite_id': param != null ? param['localite_id'] : null,
      'photo_path': _photo?.path,
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
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo obligatoire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final param = await db.getParametreUtilisateur();
    final data = {
      'type': 'etat_lieux_menage',
      'data_json': {
        'dateActivite': _dateActivite?.toIso8601String(),
        'nbTotal': _nbTotalController.text,
        'nbHommes': _nbHommesController.text,
        'nbFemmes': _nbFemmesController.text,
        'nbEnfants': _nbEnfantsController.text,
        'accesEau': _accesEau,
        'difficulteEau': _difficulteEauController.text,
        'latrinesExiste': _latrinesExiste,
        'typeLatrine': _typeLatrine,
        'latrineAmelioree': _latrineAmelioree,
        'latrineDegradee': _latrineDegradee,
        'latrineUsageToujours': _latrineUsageToujours,
        'latrineVoisin': _latrineVoisin,
        'latrineDefecation': _latrineDefecation,
        'latrineVoisinNon': _latrineVoisinNon,
        'latrineDefecationNon': _latrineDefecationNon,
        'dlmExiste': _dlmExiste,
        'typeDLM': _typeDLM,
        'photoPath': _photo?.path,
        'observations': _observationsController.text,
      }.toString(),
      'date': DateTime.now().toIso8601String(),
      'user_id': null,
      'localite_id': param != null ? param['localite_id'] : null,
      'photo_path': _photo?.path,
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
      appBar: AppBar(title: const Text('État des Lieux – Ménage')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_localisationInfo != null &&
                      _localisationInfo!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.place, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _localisationInfo!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
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
                  // 3. Composition du ménage
                  const Text(
                    'Composition du ménage',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _nbTotalController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre total de personnes',
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
                  const Divider(height: 32),
                  // 4. Accès à l’eau
                  const Text(
                    'Accès à l’eau',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Text('Accès à l’eau ?'),
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
                  if (_accesEau == false)
                    TextFormField(
                      controller: _difficulteEauController,
                      decoration: const InputDecoration(
                        labelText: 'Type de difficulté (optionnel)',
                      ),
                    ),
                  const Divider(height: 32),
                  // 5. Latrines (logique conditionnelle)
                  const Text(
                    'Le ménage dispose-t-il d’une latrine ?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Oui'),
                          value: true,
                          groupValue: _latrinesExiste,
                          onChanged: (v) => setState(() => _latrinesExiste = v),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Non'),
                          value: false,
                          groupValue: _latrinesExiste,
                          onChanged: (v) => setState(() => _latrinesExiste = v),
                        ),
                      ),
                    ],
                  ),
                  if (_latrinesExiste == true) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _typeLatrine,
                      decoration: const InputDecoration(
                        labelText: 'Type de latrine',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'traditionnelle',
                          child: Text('Traditionnelle'),
                        ),
                        DropdownMenuItem(
                          value: 'amelioree',
                          child: Text('Améliorée'),
                        ),
                        DropdownMenuItem(value: 'autre', child: Text('Autre')),
                      ],
                      onChanged: (v) => setState(() => _typeLatrine = v),
                    ),
                    Row(
                      children: [
                        const Text('Latrine améliorée ?'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<bool>(
                            value: _latrineAmelioree,
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Oui')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Non'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _latrineAmelioree = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Latrine dégradée ?'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<bool>(
                            value: _latrineDegradee,
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Oui')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Non'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _latrineDegradee = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Utilisez-vous toujours cette latrine ?'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<bool>(
                            value: _latrineUsageToujours,
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Oui')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Non'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _latrineUsageToujours = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Utilisez-vous la latrine du voisin ?'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<bool>(
                            value: _latrineVoisin,
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Oui')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Non'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _latrineVoisin = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Pratiquez-vous la défécation à l’air libre ?',
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<bool>(
                            value: _latrineDefecation,
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Oui')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Non'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _latrineDefecation = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_latrinesExiste == false) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Utilisez-vous la latrine d’un voisin ?'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<bool>(
                            value: _latrineVoisinNon,
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Oui')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Non'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _latrineVoisinNon = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Pratiquez-vous la défécation à l’air libre ?',
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<bool>(
                            value: _latrineDefecationNon,
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Oui')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Non'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _latrineDefecationNon = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 32),
                  // 6. DLM
                  const Text(
                    'Dispositif de lavage des mains (DLM)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Disposez-vous d’un dispositif de lavage des mains ?',
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<bool>(
                          value: _dlmExiste,
                          items: const [
                            DropdownMenuItem(value: true, child: Text('Oui')),
                            DropdownMenuItem(value: false, child: Text('Non')),
                          ],
                          onChanged: (v) => setState(() => _dlmExiste = v),
                          validator: (v) => v == null ? 'Champ requis' : null,
                        ),
                      ),
                    ],
                  ),
                  if (_dlmExiste == true) ...[
                    Row(
                      children: [
                        const Text('Type de DLM :'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _typeDLM,
                            items: const [
                              DropdownMenuItem(
                                value: 'eau_savon',
                                child: Text('Eau + Savon'),
                              ),
                              DropdownMenuItem(
                                value: 'eau_seule',
                                child: Text('Eau seule'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _typeDLM = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_dlmExiste == false) const Text('Aucun dispositif'),
                  const Divider(height: 32),
                  // 7. Preuve photo
                  const Text(
                    'Preuve (photo obligatoire)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _photo == null
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Prendre une photo'),
                          onPressed: _pickPhoto,
                        )
                      : Column(
                          children: [
                            Image.file(File(_photo!.path), height: 180),
                            TextButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Changer la photo'),
                              onPressed: _pickPhoto,
                            ),
                          ],
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
