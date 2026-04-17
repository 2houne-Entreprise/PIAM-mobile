import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class EtatLieuxMenageForm extends StatefulWidget {
  static const String routeName = '/etat_lieux_menage';
  const EtatLieuxMenageForm({Key? key}) : super(key: key);

  @override
  State<EtatLieuxMenageForm> createState() => _EtatLieuxMenageFormState();
}

class _EtatLieuxMenageFormState extends State<EtatLieuxMenageForm> {
  bool _loading = true;
  Map<String, dynamic>? _adminData;
  double? latitude;
  double? longitude;
  DateTime? dateActivite;

  // Champs booléens (Switch)
  bool? accesEau;
  bool? possedeLatrine;
  bool? latrineAmelioree;
  bool? latrineDegradee;
  bool? utilisationLatrine;
  bool? utilisationLatrineVoisin;
  bool? defecationAirLibre;
  bool? dispositifLavageMains;
  String? dlmType;
  String? photoPath;

  // Controllers
  final _observationsController = TextEditingController();
  final _nbTotalController = TextEditingController();
  final _nbHommesController = TextEditingController();
  final _nbFemmesController = TextEditingController();
  final _nbEnfantsMoins5Controller = TextEditingController();

  final _db = DatabaseService();
  static const String _formType = 'etat_lieux_menage';

  int? get _localiteId => _adminData?['localite_id'] as int?;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _nbTotalController.dispose();
    _nbHommesController.dispose();
    _nbFemmesController.dispose();
    _nbEnfantsMoins5Controller.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final param = await _db.getParametreUtilisateur();
    setState(() {
      _adminData = param;
      latitude = param?['gps_lat'];
      longitude = param?['gps_lng'];
      dateActivite = DateTime.now();
    });
    await _loadDraft();
    setState(() => _loading = false);
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }

  Future<void> _loadDraft() async {
    final draft = await _db.getQuestionnaire(
      type: _formType,
      localiteId: _localiteId,
    );
    if (draft == null) return;

    _observationsController.text = draft['observations'] ?? '';
    _nbTotalController.text = draft['nb_total']?.toString() ?? '';
    _nbHommesController.text = draft['nb_hommes']?.toString() ?? '';
    _nbFemmesController.text = draft['nb_femmes']?.toString() ?? '';
    _nbEnfantsMoins5Controller.text = draft['nb_enfants_moins_5']?.toString() ?? '';

    accesEau = draft['acces_eau'] != null ? _parseBool(draft['acces_eau']) : null;
    possedeLatrine = draft['possede_latrine'] != null ? _parseBool(draft['possede_latrine']) : null;
    latrineAmelioree =
        draft['latrine_amelioree'] != null ? _parseBool(draft['latrine_amelioree']) : null;
    latrineDegradee =
        draft['latrine_degradee'] != null ? _parseBool(draft['latrine_degradee']) : null;
    utilisationLatrine =
        draft['utilisation_latrine'] != null ? _parseBool(draft['utilisation_latrine']) : null;
    utilisationLatrineVoisin = draft['utilisation_latrine_voisin'] != null
        ? _parseBool(draft['utilisation_latrine_voisin'])
        : null;
    defecationAirLibre =
        draft['defecation_air_libre'] != null ? _parseBool(draft['defecation_air_libre']) : null;
    dispositifLavageMains = draft['dispositif_lavage_mains'] != null
        ? _parseBool(draft['dispositif_lavage_mains'])
        : null;
    dlmType = draft['dlm_type'] as String?;
    photoPath = draft['photo_path'] as String?;

    if (draft['date_activite'] != null) {
      try {
        dateActivite = DateTime.parse(draft['date_activite']);
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }

  Map<String, dynamic> _buildDataMap() => {
        'wilaya_id': _adminData?['wilaya_id'],
        'moughataa_id': _adminData?['moughataa_id'],
        'commune_id': _adminData?['commune_id'],
        'localite_id': _localiteId,
        'gps_lat': latitude,
        'gps_lng': longitude,
        'date_activite': dateActivite?.toIso8601String(),
        'observations': _observationsController.text,
        'nb_total': int.tryParse(_nbTotalController.text),
        'nb_hommes': int.tryParse(_nbHommesController.text),
        'nb_femmes': int.tryParse(_nbFemmesController.text),
        'nb_enfants_moins_5': int.tryParse(_nbEnfantsMoins5Controller.text),
        'acces_eau': accesEau,
        'possede_latrine': possedeLatrine,
        'latrine_amelioree': latrineAmelioree,
        'latrine_degradee': latrineDegradee,
        'utilisation_latrine': utilisationLatrine,
        'utilisation_latrine_voisin': utilisationLatrineVoisin,
        'defecation_air_libre': defecationAirLibre,
        'dispositif_lavage_mains': dispositifLavageMains,
        'dlm_type': dlmType,
        'photo_path': photoPath,
      };

  Future<void> _saveDraft() async {
    if (_localiteId == null) return;
    await _db.upsertQuestionnaire(
      type: _formType,
      localiteId: _localiteId,
      status: 'draft',
      dataMap: _buildDataMap(),
    );
  }

  Future<void> _saveForm() async {
    if (dateActivite == null) return;
    await _db.upsertQuestionnaire(
      type: _formType,
      localiteId: _localiteId,
      status: 'completed',
      dataMap: _buildDataMap(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('État des lieux ménage enregistré.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('État des lieux – Ménage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Wilaya: ${_adminData?['wilaya_id'] ?? '-'}'),
            Text('Moughataa: ${_adminData?['moughataa_id'] ?? '-'}'),
            Text('Commune: ${_adminData?['commune_id'] ?? '-'}'),
            Text('Localité: ${_localiteId ?? '-'}'),
            Text('GPS: ${latitude ?? '-'}, ${longitude ?? '-'}'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date de l\'activité'),
              subtitle: Text(
                dateActivite != null
                    ? DateFormat('yyyy-MM-dd').format(dateActivite!)
                    : '-',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dateActivite ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => dateActivite = picked);
                    _saveDraft();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observationsController,
              decoration: const InputDecoration(labelText: 'Observations'),
              maxLines: 3,
              onChanged: (_) => _saveDraft(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nbTotalController,
              decoration: const InputDecoration(labelText: 'Nombre total'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbHommesController,
              decoration: const InputDecoration(labelText: 'Hommes'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbFemmesController,
              decoration: const InputDecoration(labelText: 'Femmes'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbEnfantsMoins5Controller,
              decoration: const InputDecoration(labelText: 'Enfants < 5 ans'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            SwitchListTile(
              title: const Text('Accès à l\'eau'),
              value: accesEau ?? false,
              onChanged: (v) {
                setState(() => accesEau = v);
                _saveDraft();
              },
            ),
            SwitchListTile(
              title: const Text('Possède une latrine'),
              value: possedeLatrine ?? false,
              onChanged: (v) {
                setState(() => possedeLatrine = v);
                _saveDraft();
              },
            ),
            if (possedeLatrine == true) ...[
              SwitchListTile(
                title: const Text('Latrine améliorée'),
                value: latrineAmelioree ?? false,
                onChanged: (v) {
                  setState(() => latrineAmelioree = v);
                  _saveDraft();
                },
              ),
              SwitchListTile(
                title: const Text('Latrine dégradée'),
                value: latrineDegradee ?? false,
                onChanged: (v) {
                  setState(() => latrineDegradee = v);
                  _saveDraft();
                },
              ),
              SwitchListTile(
                title: const Text('Utilisation latrine'),
                value: utilisationLatrine ?? false,
                onChanged: (v) {
                  setState(() => utilisationLatrine = v);
                  _saveDraft();
                },
              ),
              SwitchListTile(
                title: const Text('Utilisation latrine voisin'),
                value: utilisationLatrineVoisin ?? false,
                onChanged: (v) {
                  setState(() => utilisationLatrineVoisin = v);
                  _saveDraft();
                },
              ),
              SwitchListTile(
                title: const Text('Défécation à l\'air libre'),
                value: defecationAirLibre ?? false,
                onChanged: (v) {
                  setState(() => defecationAirLibre = v);
                  _saveDraft();
                },
              ),
            ] else ...[
              SwitchListTile(
                title: const Text('Utilisation latrine voisin'),
                value: utilisationLatrineVoisin ?? false,
                onChanged: (v) {
                  setState(() => utilisationLatrineVoisin = v);
                  _saveDraft();
                },
              ),
              SwitchListTile(
                title: const Text('Défécation à l\'air libre'),
                value: defecationAirLibre ?? false,
                onChanged: (v) {
                  setState(() => defecationAirLibre = v);
                  _saveDraft();
                },
              ),
            ],
            SwitchListTile(
              title: const Text('Dispositif lavage mains'),
              value: dispositifLavageMains ?? false,
              onChanged: (v) {
                setState(() => dispositifLavageMains = v);
                _saveDraft();
              },
            ),
            if (dispositifLavageMains == true) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type DLM'),
                value: dlmType,
                items: const [
                  DropdownMenuItem(value: 'eau + savon', child: Text('Eau + savon')),
                  DropdownMenuItem(value: 'eau seule', child: Text('Eau seule')),
                  DropdownMenuItem(value: 'aucun', child: Text('Aucun')),
                ],
                onChanged: (v) {
                  setState(() => dlmType = v);
                  _saveDraft();
                },
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveForm, child: const Text('Envoyer')),
          ],
        ),
      ),
    );
  }
}
