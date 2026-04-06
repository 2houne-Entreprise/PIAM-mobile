import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
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
  DateTime? _dateDebutActivite;
  bool? _certifie;
  final List<String> _raisonsNon = [];
  final TextEditingController _remarqueNonController = TextEditingController();
  final List<String> _optionsRaisonsNon = [
    'Présence des DAL',
    'Moins de 80% des ménages disposent de latrines',
    'Autre (à préciser)',
  ];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateCertification;

  bool _statutFDAL = false;

  // Indicateurs en pourcentage (0–100 sous forme de slider)
  double _pctMenagesLatrines = 0;
  double _pctUtilisationLatrines = 0;
  double _pctLavageMains = 0;

  final _observationsController = TextEditingController();
  final _recommandationsController = TextEditingController();

  bool _validationTechnicien = false;
  bool _validationResponsable = false;

  String? _niveauFDAL;
  static const List<String> _niveauxFDAL = [
    'FDAL non atteint',
    'FDAL partiel (> 50 %)',
    'FDAL total (100 %)',
  ];

  @override
  void dispose() {
    _observationsController.dispose();
    _recommandationsController.dispose();
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
      ].where((e) => e != null && e.isNotEmpty).join(' | ');
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
      'type': 'conformite',
      'data_json': {
        'dateDebutActivite': _dateDebutActivite?.toIso8601String(),
        'certifie': _certifie,
        'raisonsNon': _raisonsNon,
        'remarqueNon': _remarqueNonController.text,
        'niveauFDAL': _niveauFDAL,
        'dateCertification': _dateCertification?.toIso8601String(),
        'pctMenagesLatrines': _pctMenagesLatrines,
        'pctUtilisationLatrines': _pctUtilisationLatrines,
        'pctLavageMains': _pctLavageMains,
        'observations': _observationsController.text,
        'recommandations': _recommandationsController.text,
        'validationTechnicien': _validationTechnicien,
        'validationResponsable': _validationResponsable,
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
        title: const Text('Conformité FDAL / ATPC'),
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
                  // Date début activité
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _dateDebutActivite ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (d != null) setState(() => _dateDebutActivite = d);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de début activité',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateDebutActivite != null
                            ? '${_dateDebutActivite!.day.toString().padLeft(2, '0')}/'
                                  '${_dateDebutActivite!.month.toString().padLeft(2, '0')}/'
                                  '${_dateDebutActivite!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dateDebutActivite != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Statut certification
                  const Text(
                    'Le village est-il certifié ce jour ?',
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
                          'Raison(s) de non certification :',
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
                        if (_raisonsNon.contains('Autre (à préciser)'))
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
                  const SizedBox(height: 20),

                  // ── Section A : Statut FDAL ────────────────────────────────
                  _buildSectionTitle(
                    'A. Statut FDAL (Fin de Défécation à l\'Air Libre)',
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _niveauFDAL,
                    items: _niveauxFDAL
                        .map(
                          (n) => DropdownMenuItem<String>(
                            value: n,
                            child: Text(n),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _niveauFDAL = v;
                        _statutFDAL = v == _niveauxFDAL.last;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Niveau FDAL *',
                      prefixIcon: Icon(Icons.verified),
                    ),
                    isExpanded: true,
                    validator: (v) => v == null ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),

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

                  // ── Section B : Indicateurs ATPC ──────────────────────────
                  _buildSectionTitle('B. Indicateurs ATPC'),
                  const SizedBox(height: 12),

                  _buildIndicateur(
                    '% ménages disposant de latrines',
                    _pctMenagesLatrines,
                    (v) => setState(() => _pctMenagesLatrines = v),
                  ),
                  const SizedBox(height: 12),
                  _buildIndicateur(
                    '% utilisation des latrines',
                    _pctUtilisationLatrines,
                    (v) => setState(() => _pctUtilisationLatrines = v),
                  ),
                  const SizedBox(height: 12),
                  _buildIndicateur(
                    '% pratique lavage des mains',
                    _pctLavageMains,
                    (v) => setState(() => _pctLavageMains = v),
                  ),
                  const SizedBox(height: 20),

                  // ── Section C : Observations ──────────────────────────────
                  _buildSectionTitle('C. Observations'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _observationsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Observations sur la conformité FDAL/ATPC...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section D : Recommandations ───────────────────────────
                  _buildSectionTitle('D. Recommandations'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _recommandationsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Recommandations pour améliorer la conformité...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section E : Validation ────────────────────────────────
                  _buildSectionTitle('E. Validation'),
                  const SizedBox(height: 8),

                  SwitchListTile(
                    title: const Text('Validé par le technicien'),
                    value: _validationTechnicien,
                    onChanged: (v) => setState(() => _validationTechnicien = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Validé par le responsable PIAM'),
                    value: _validationResponsable,
                    onChanged: (v) =>
                        setState(() => _validationResponsable = v),
                    contentPadding: EdgeInsets.zero,
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

  Widget _buildIndicateur(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${value.toInt()} %',
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                '${value.toInt()} %',
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.colorBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.colorBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.colorBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.colorBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.colorBlue,
      ),
    );
  }
}
