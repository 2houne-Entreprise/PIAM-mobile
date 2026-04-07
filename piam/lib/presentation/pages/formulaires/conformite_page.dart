import 'package:flutter/material.dart';
import 'package:piam/services/database_service.dart';

/// Formulaire 9 – Conformité FDAL / ATPC
class ConformitePage extends StatefulWidget {
  final String formulaireId;

  const ConformitePage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<ConformitePage> createState() => _ConformitePageState();
}

class _ConformitePageState extends State<ConformitePage> {
  String? _localisationInfo;
  DateTime? _dateCertification;
  bool? _certifie;
  final List<String> _raisonsNon = [];
  final TextEditingController _remarqueNonController = TextEditingController();
  final List<String> _optionsRaisonsNon = [
    'Pas de fonds disponibles',
    'Fonds mobilisés ailleurs',
    'Administration en retard',
    'Autre (spécifier)',
  ];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _remarqueNonController.dispose();
    super.dispose();
  }

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

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateCertification ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => _dateCertification = d);
  }

  Future<void> _saveFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final db = DatabaseService();
    final param = await db.getParametreUtilisateur();
    final data = {
      'type': 'certification_fdal',
      'data_json': {
        'gps': _localisationInfo,
        'date': _dateCertification?.toIso8601String(),
        'statut_fdal': _certifie,
        'raisons_non': _raisonsNon,
        'remarque_non': _remarqueNonController.text,
      }.toString(),
      'date': DateTime.now().toIso8601String(),
      'user_id': null,
      'localite_id': param != null ? param['localite_id'] : null,
    };
    await db.insertQuestionnaire(data);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conformité enregistrée'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _submitFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conformité soumise pour validation'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certification FDAL'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                  // Date de certification
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de certification',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateCertification != null
                            ? '${_dateCertification!.day.toString().padLeft(2, '0')}/'
                                  '${_dateCertification!.month.toString().padLeft(2, '0')}/'
                                  '${_dateCertification!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dateCertification != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Statut FDAL
                  const Text(
                    'Certification FDAL obtenue ?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _certifie,
                        onChanged: (v) => setState(() => _certifie = v),
                      ),
                      const Text('Oui'),
                      Radio<bool>(
                        value: false,
                        groupValue: _certifie,
                        onChanged: (v) => setState(() => _certifie = v),
                      ),
                      const Text('Non'),
                    ],
                  ),
                  if (_certifie == false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Raison(s) de non-certification :',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        ..._optionsRaisonsNon.map(
                          (option) => CheckboxListTile(
                            value: _raisonsNon.contains(option),
                            title: Text(option),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _raisonsNon.add(option);
                                } else {
                                  _raisonsNon.remove(option);
                                }
                              });
                            },
                          ),
                        ),
                        if (_raisonsNon.contains('Autre (spécifier)'))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextFormField(
                              controller: _remarqueNonController,
                              decoration: const InputDecoration(
                                labelText: 'Précisez la raison',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Enregistrer'),
                          onPressed: _saveFormulaire,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Soumettre'),
                          onPressed: _submitFormulaire,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // Suppression des widgets inutilisés
}
