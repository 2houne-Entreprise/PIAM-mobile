import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class DernierSuiviLocaliteForm extends StatefulWidget {
  static const String routeName = '/dernier_suivi_localite';
  const DernierSuiviLocaliteForm({Key? key}) : super(key: key);

  @override
  State<DernierSuiviLocaliteForm> createState() =>
      _DernierSuiviLocaliteFormState();
}

class _DernierSuiviLocaliteFormState extends State<DernierSuiviLocaliteForm> {
  bool _loading = true;
  Map<String, dynamic>? _adminData;
  double? latitude;
  double? longitude;
  DateTime? dateActivite;

  // Controllers pour pré-remplissage
  final _observationsController = TextEditingController();
  final _nbMenagesEnquetesController = TextEditingController();
  final _nbLatrinesTotalController = TextEditingController();
  final _nbLatrinesAmelioreesController = TextEditingController();
  final _nbLatrinesNonAmelioreesController = TextEditingController();
  final _nbLatrinesAmelioreesHygieniqueController = TextEditingController();
  final _nbLatrinesAmelioreesPartageesController = TextEditingController();
  final _nbLatrinesNonFonctionnellesController = TextEditingController();
  final _nbLatrinesEndommageeController = TextEditingController();
  final _nbMenagesUtilisantLatrinesVoisinController = TextEditingController();
  final _nbMenagesDefecationAirLibreController = TextEditingController();
  final _nbNouvellesLatrinesConstructionController = TextEditingController();
  final _nbLatrinesAutofinanceesController = TextEditingController();
  final _nbLatrinesAideExterieureController = TextEditingController();
  final _nbLatrinesFinanceesCommunauteController = TextEditingController();
  final _montantInvestiMenagesController = TextEditingController();
  final _nbLatrinesAvecDLMController = TextEditingController();
  final _nbAvecEauSavonController = TextEditingController();
  final _nbAvecEauSansSavonController = TextEditingController();
  final _nbMenagesSansDLMController = TextEditingController();

  final _db = DatabaseService();
  static const String _formType = 'dernier_suivi_localite';

  int? get _localiteId => _adminData?['localite_id'] as int?;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _nbMenagesEnquetesController.dispose();
    _nbLatrinesTotalController.dispose();
    _nbLatrinesAmelioreesController.dispose();
    _nbLatrinesNonAmelioreesController.dispose();
    _nbLatrinesAmelioreesHygieniqueController.dispose();
    _nbLatrinesAmelioreesPartageesController.dispose();
    _nbLatrinesNonFonctionnellesController.dispose();
    _nbLatrinesEndommageeController.dispose();
    _nbMenagesUtilisantLatrinesVoisinController.dispose();
    _nbMenagesDefecationAirLibreController.dispose();
    _nbNouvellesLatrinesConstructionController.dispose();
    _nbLatrinesAutofinanceesController.dispose();
    _nbLatrinesAideExterieureController.dispose();
    _nbLatrinesFinanceesCommunauteController.dispose();
    _montantInvestiMenagesController.dispose();
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

  Future<void> _loadDraft() async {
    final draft = await _db.getQuestionnaire(
      type: _formType,
      localiteId: _localiteId,
    );
    if (draft == null) return;

    _observationsController.text = draft['observations'] ?? '';
    _nbMenagesEnquetesController.text = draft['nb_menages_enquetes']?.toString() ?? '';
    _nbLatrinesTotalController.text = draft['nb_latrines_total']?.toString() ?? '';
    _nbLatrinesAmelioreesController.text = draft['nb_latrines_ameliorees']?.toString() ?? '';
    _nbLatrinesNonAmelioreesController.text =
        draft['nb_latrines_non_ameliorees']?.toString() ?? '';
    _nbLatrinesAmelioreesHygieniqueController.text =
        draft['nb_latrines_ameliorees_hygienique']?.toString() ?? '';
    _nbLatrinesAmelioreesPartageesController.text =
        draft['nb_latrines_ameliorees_partagees']?.toString() ?? '';
    _nbLatrinesNonFonctionnellesController.text =
        draft['nb_latrines_non_fonctionnelles']?.toString() ?? '';
    _nbLatrinesEndommageeController.text =
        draft['nb_latrines_endommagees']?.toString() ?? '';
    _nbMenagesUtilisantLatrinesVoisinController.text =
        draft['nb_menages_utilisant_latrines_voisin']?.toString() ?? '';
    _nbMenagesDefecationAirLibreController.text =
        draft['nb_menages_defecation_air_libre']?.toString() ?? '';
    _nbNouvellesLatrinesConstructionController.text =
        draft['nb_nouvelles_latrines_construites']?.toString() ?? '';
    _nbLatrinesAutofinanceesController.text =
        draft['nb_latrines_autofinancees']?.toString() ?? '';
    _nbLatrinesAideExterieureController.text =
        draft['nb_latrines_aide_exterieure']?.toString() ?? '';
    _nbLatrinesFinanceesCommunauteController.text =
        draft['nb_latrines_financees_communaute']?.toString() ?? '';
    _montantInvestiMenagesController.text =
        draft['montant_investi_menages']?.toString() ?? '';
    _nbLatrinesAvecDLMController.text = draft['nb_latrines_avec_dlm']?.toString() ?? '';
    _nbAvecEauSavonController.text = draft['nb_avec_eau_savon']?.toString() ?? '';
    _nbAvecEauSansSavonController.text = draft['nb_avec_eau_sans_savon']?.toString() ?? '';
    _nbMenagesSansDLMController.text = draft['nb_menages_sans_dlm']?.toString() ?? '';

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
        'nb_menages_enquetes': int.tryParse(_nbMenagesEnquetesController.text),
        'nb_latrines_total': int.tryParse(_nbLatrinesTotalController.text),
        'nb_latrines_ameliorees': int.tryParse(_nbLatrinesAmelioreesController.text),
        'nb_latrines_non_ameliorees':
            int.tryParse(_nbLatrinesNonAmelioreesController.text),
        'nb_latrines_ameliorees_hygienique':
            int.tryParse(_nbLatrinesAmelioreesHygieniqueController.text),
        'nb_latrines_ameliorees_partagees':
            int.tryParse(_nbLatrinesAmelioreesPartageesController.text),
        'nb_latrines_non_fonctionnelles':
            int.tryParse(_nbLatrinesNonFonctionnellesController.text),
        'nb_latrines_endommagees': int.tryParse(_nbLatrinesEndommageeController.text),
        'nb_menages_utilisant_latrines_voisin':
            int.tryParse(_nbMenagesUtilisantLatrinesVoisinController.text),
        'nb_menages_defecation_air_libre':
            int.tryParse(_nbMenagesDefecationAirLibreController.text),
        'nb_nouvelles_latrines_construites':
            int.tryParse(_nbNouvellesLatrinesConstructionController.text),
        'nb_latrines_autofinancees':
            int.tryParse(_nbLatrinesAutofinanceesController.text),
        'nb_latrines_aide_exterieure':
            int.tryParse(_nbLatrinesAideExterieureController.text),
        'nb_latrines_financees_communaute':
            int.tryParse(_nbLatrinesFinanceesCommunauteController.text),
        'montant_investi_menages':
            double.tryParse(_montantInvestiMenagesController.text),
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
        const SnackBar(content: Text('Dernier suivi localité enregistré.')),
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
      appBar: AppBar(title: const Text('Dernier suivi – Localité')),
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
              controller: _nbMenagesEnquetesController,
              decoration: const InputDecoration(labelText: 'Nombre de ménages enquêtés'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesTotalController,
              decoration: const InputDecoration(labelText: 'Nombre total de latrines'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesAmelioreesController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de latrines améliorées'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesNonAmelioreesController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de latrines non améliorées'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesAmelioreesHygieniqueController,
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines améliorées de manière hygiénique',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesAmelioreesPartageesController,
              decoration: const InputDecoration(
                labelText:
                    'Nombre de latrines améliorées de manière équitable et partagée',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesNonFonctionnellesController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de latrines non fonctionnelles'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesEndommageeController,
              decoration: const InputDecoration(
                  labelText: 'Nombre de latrines endommagées (hivernage)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbMenagesUtilisantLatrinesVoisinController,
              decoration: const InputDecoration(
                  labelText: 'Nombre de ménages utilisant latrines voisin'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbMenagesDefecationAirLibreController,
              decoration: const InputDecoration(
                labelText:
                    'Nombre de ménages pratiquant la défécation à l\'air libre',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbNouvellesLatrinesConstructionController,
              decoration: const InputDecoration(
                  labelText: 'Nombre de nouvelles latrines construites'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesAutofinanceesController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de latrines autofinancées'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesAideExterieureController,
              decoration: const InputDecoration(
                  labelText: 'Nombre de latrines avec aide extérieure'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesFinanceesCommunauteController,
              decoration: const InputDecoration(
                  labelText: 'Nombre de latrines financées par la communauté'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _montantInvestiMenagesController,
              decoration:
                  const InputDecoration(labelText: 'Montant investi par les ménages'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbLatrinesAvecDLMController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de latrines avec DLM'),
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
              decoration:
                  const InputDecoration(labelText: 'Nombre avec eau sans savon'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _saveDraft(),
            ),
            TextFormField(
              controller: _nbMenagesSansDLMController,
              decoration:
                  const InputDecoration(labelText: 'Nombre de ménages sans DLM'),
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
