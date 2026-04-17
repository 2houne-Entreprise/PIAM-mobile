import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class EtatLieuxLocaliteForm extends StatefulWidget {
  static const String routeName = '/etat_lieux_localite';
  const EtatLieuxLocaliteForm({Key? key}) : super(key: key);

  @override
  State<EtatLieuxLocaliteForm> createState() => _EtatLieuxLocaliteFormState();
}

class _EtatLieuxLocaliteFormState extends State<EtatLieuxLocaliteForm> {
  bool _loading = true;
  Map<String, dynamic>? _adminData;
  double? latitude;
  double? longitude;
  DateTime? dateActivite;
  bool? accesEau;

  // Controllers pour pré-remplissage
  final _observationsController = TextEditingController();
  final _populationTotaleController = TextEditingController();
  final _nbHommesController = TextEditingController();
  final _nbFemmesController = TextEditingController();
  final _nbEnfantsMoins5Controller = TextEditingController();
  final _nbMenagesController = TextEditingController();
  final _nbLatrinesFamilialesController = TextEditingController();
  final _nbLatrinesAmelioreesController = TextEditingController();
  final _nbLatrinesNonAmelioreesController = TextEditingController();
  final _nbLatrinesEndommageeController = TextEditingController();
  final _nbMenagesUtilisantLatrinesVoisinController = TextEditingController();
  final _nbMenagesDefecationAirLibreController = TextEditingController();
  final _nbLatrinesAvecDLMController = TextEditingController();
  final _nbAvecEauSavonController = TextEditingController();
  final _nbAvecEauSansSavonController = TextEditingController();
  final _nbMenagesSansDLMController = TextEditingController();

  final _db = DatabaseService();
  static const String _formType = 'etat_lieux_localite';

  int? get _localiteId => _adminData?['localite_id'] as int?;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _populationTotaleController.dispose();
    _nbHommesController.dispose();
    _nbFemmesController.dispose();
    _nbEnfantsMoins5Controller.dispose();
    _nbMenagesController.dispose();
    _nbLatrinesFamilialesController.dispose();
    _nbLatrinesAmelioreesController.dispose();
    _nbLatrinesNonAmelioreesController.dispose();
    _nbLatrinesEndommageeController.dispose();
    _nbMenagesUtilisantLatrinesVoisinController.dispose();
    _nbMenagesDefecationAirLibreController.dispose();
    _nbLatrinesAvecDLMController.dispose();
    _nbAvecEauSavonController.dispose();
    _nbAvecEauSansSavonController.dispose();
    _nbMenagesSansDLMController.dispose();
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

  /// Charge le brouillon et pré-remplit tous les champs
  Future<void> _loadDraft() async {
    final draft = await _db.getQuestionnaire(
      type: _formType,
      localiteId: _localiteId,
    );
    if (draft == null) return;

    _observationsController.text = draft['observations'] ?? '';
    _populationTotaleController.text = draft['population_totale']?.toString() ?? '';
    _nbHommesController.text = draft['nb_hommes']?.toString() ?? '';
    _nbFemmesController.text = draft['nb_femmes']?.toString() ?? '';
    _nbEnfantsMoins5Controller.text = draft['nb_enfants_moins_5']?.toString() ?? '';
    _nbMenagesController.text = draft['nb_menages']?.toString() ?? '';
    _nbLatrinesFamilialesController.text = draft['nb_latrines_familiales']?.toString() ?? '';
    _nbLatrinesAmelioreesController.text = draft['nb_latrines_ameliorees']?.toString() ?? '';
    _nbLatrinesNonAmelioreesController.text = draft['nb_latrines_non_ameliorees']?.toString() ?? '';
    _nbLatrinesEndommageeController.text = draft['nb_latrines_endommagees']?.toString() ?? '';
    _nbMenagesUtilisantLatrinesVoisinController.text =
        draft['nb_menages_utilisant_latrines_voisin']?.toString() ?? '';
    _nbMenagesDefecationAirLibreController.text =
        draft['nb_menages_defecation_air_libre']?.toString() ?? '';
    _nbLatrinesAvecDLMController.text = draft['nb_latrines_avec_dlm']?.toString() ?? '';
    _nbAvecEauSavonController.text = draft['nb_avec_eau_savon']?.toString() ?? '';
    _nbAvecEauSansSavonController.text = draft['nb_avec_eau_sans_savon']?.toString() ?? '';
    _nbMenagesSansDLMController.text = draft['nb_menages_sans_dlm']?.toString() ?? '';

    if (draft['acces_eau'] != null) {
      accesEau = draft['acces_eau'] == true || draft['acces_eau'] == 1;
    }
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
        'population_totale': int.tryParse(_populationTotaleController.text),
        'nb_hommes': int.tryParse(_nbHommesController.text),
        'nb_femmes': int.tryParse(_nbFemmesController.text),
        'nb_enfants_moins_5': int.tryParse(_nbEnfantsMoins5Controller.text),
        'nb_menages': int.tryParse(_nbMenagesController.text),
        'acces_eau': accesEau,
        'nb_latrines_familiales': int.tryParse(_nbLatrinesFamilialesController.text),
        'nb_latrines_ameliorees': int.tryParse(_nbLatrinesAmelioreesController.text),
        'nb_latrines_non_ameliorees': int.tryParse(_nbLatrinesNonAmelioreesController.text),
        'nb_latrines_endommagees': int.tryParse(_nbLatrinesEndommageeController.text),
        'nb_menages_utilisant_latrines_voisin':
            int.tryParse(_nbMenagesUtilisantLatrinesVoisinController.text),
        'nb_menages_defecation_air_libre':
            int.tryParse(_nbMenagesDefecationAirLibreController.text),
        'nb_latrines_avec_dlm': int.tryParse(_nbLatrinesAvecDLMController.text),
        'nb_avec_eau_savon': int.tryParse(_nbAvecEauSavonController.text),
        'nb_avec_eau_sans_savon': int.tryParse(_nbAvecEauSansSavonController.text),
        'nb_menages_sans_dlm': int.tryParse(_nbMenagesSansDLMController.text),
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
        const SnackBar(content: Text('État des lieux localité enregistré.')),
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
      appBar: AppBar(title: const Text('État des lieux – Localité')),
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
              controller: _populationTotaleController,
              decoration: const InputDecoration(labelText: 'Population totale'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbHommesController,
              decoration: const InputDecoration(labelText: 'Nombre d\'hommes'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbFemmesController,
              decoration: const InputDecoration(labelText: 'Nombre de femmes'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbEnfantsMoins5Controller,
              decoration: const InputDecoration(labelText: 'Nombre d\'enfants < 5 ans'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbMenagesController,
              decoration: const InputDecoration(labelText: 'Nombre de ménages'),
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
            TextFormField(
              controller: _nbLatrinesFamilialesController,
              decoration: const InputDecoration(labelText: 'Nombre total de latrines familiales'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesAmelioreesController,
              decoration: const InputDecoration(labelText: 'Nombre de latrines améliorées'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesNonAmelioreesController,
              decoration: const InputDecoration(labelText: 'Nombre de latrines non améliorées'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesEndommageeController,
              decoration: const InputDecoration(labelText: 'Nombre de latrines endommagées'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbMenagesUtilisantLatrinesVoisinController,
              decoration: const InputDecoration(
                labelText: 'Nombre de ménages utilisant les latrines des voisins',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbMenagesDefecationAirLibreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de ménages pratiquant la défécation à l\'air libre',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesAvecDLMController,
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines avec dispositif de lavage des mains',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbAvecEauSavonController,
              decoration: const InputDecoration(labelText: 'Nombre avec eau + savon'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbAvecEauSansSavonController,
              decoration: const InputDecoration(labelText: 'Nombre avec eau sans savon'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbMenagesSansDLMController,
              decoration: const InputDecoration(labelText: 'Nombre de ménages sans dispositif'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveForm, child: const Text('Envoyer')),
          ],
        ),
      ),
    );
  }
}
