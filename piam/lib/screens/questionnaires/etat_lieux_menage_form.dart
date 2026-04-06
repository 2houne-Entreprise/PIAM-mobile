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
  String? observations;

  // Champs spécifiques
  int? nbTotal;
  int? nbHommes;
  int? nbFemmes;
  int? nbEnfantsMoins5;
  bool? accesEau;
  bool? possedeLatrine;
  bool? latrineAmelioree;
  bool? latrineDegradee;
  bool? utilisationLatrine;
  bool? utilisationLatrineVoisin;
  bool? defecationAirLibre;
  bool? dispositifLavageMains;
  String? dlmType; // "eau + savon", "eau seule", "aucun"
  String? photoPath;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final db = DatabaseService();
    final param = await db.getParametreUtilisateur();
    setState(() {
      _adminData = param;
      latitude = param?['gps_lat'];
      longitude = param?['gps_lng'];
      dateActivite = DateTime.now();
      _loading = false;
    });
  }

  Future<void> _saveForm() async {
    if (dateActivite == null) return;
    final db = DatabaseService();
    final data = {
      'wilaya_id': _adminData?['wilaya_id'],
      'moughataa_id': _adminData?['moughataa_id'],
      'commune_id': _adminData?['commune_id'],
      'localite_id': _adminData?['localite_id'],
      'gps_lat': latitude,
      'gps_lng': longitude,
      'date_activite': dateActivite?.toIso8601String(),
      'observations': observations,
      'nb_total': nbTotal,
      'nb_hommes': nbHommes,
      'nb_femmes': nbFemmes,
      'nb_enfants_moins_5': nbEnfantsMoins5,
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
    await db.insertQuestionnaire({
      'type': 'État des lieux ménage',
      'data_json': data.toString(),
      'date': dateActivite?.toIso8601String(),
      'localite_id': _adminData?['localite_id'],
      'sync_status': 'local',
      'photo_path': photoPath,
    });
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
            Text('Localité: ${_adminData?['localite_id'] ?? '-'}'),
            Text('GPS: ${latitude ?? '-'}, ${longitude ?? '-'}'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date de l’activité'),
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
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Observations'),
              maxLines: 3,
              onChanged: (v) => observations = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre total'),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbTotal = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Hommes'),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbHommes = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Femmes'),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbFemmes = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Enfants < 5 ans'),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbEnfantsMoins5 = int.tryParse(v),
            ),
            SwitchListTile(
              title: const Text('Accès à l’eau'),
              value: accesEau ?? false,
              onChanged: (v) => setState(() => accesEau = v),
            ),
            SwitchListTile(
              title: const Text('Possède une latrine'),
              value: possedeLatrine ?? false,
              onChanged: (v) => setState(() => possedeLatrine = v),
            ),
            if (possedeLatrine == true) ...[
              SwitchListTile(
                title: const Text('Latrine améliorée'),
                value: latrineAmelioree ?? false,
                onChanged: (v) => setState(() => latrineAmelioree = v),
              ),
              SwitchListTile(
                title: const Text('Latrine dégradée'),
                value: latrineDegradee ?? false,
                onChanged: (v) => setState(() => latrineDegradee = v),
              ),
              SwitchListTile(
                title: const Text('Utilisation latrine'),
                value: utilisationLatrine ?? false,
                onChanged: (v) => setState(() => utilisationLatrine = v),
              ),
              SwitchListTile(
                title: const Text('Utilisation latrine voisin'),
                value: utilisationLatrineVoisin ?? false,
                onChanged: (v) => setState(() => utilisationLatrineVoisin = v),
              ),
              SwitchListTile(
                title: const Text('Défécation à l’air libre'),
                value: defecationAirLibre ?? false,
                onChanged: (v) => setState(() => defecationAirLibre = v),
              ),
            ] else ...[
              SwitchListTile(
                title: const Text('Utilisation latrine voisin'),
                value: utilisationLatrineVoisin ?? false,
                onChanged: (v) => setState(() => utilisationLatrineVoisin = v),
              ),
              SwitchListTile(
                title: const Text('Défécation à l’air libre'),
                value: defecationAirLibre ?? false,
                onChanged: (v) => setState(() => defecationAirLibre = v),
              ),
            ],
            SwitchListTile(
              title: const Text('Dispositif lavage mains'),
              value: dispositifLavageMains ?? false,
              onChanged: (v) => setState(() => dispositifLavageMains = v),
            ),
            if (dispositifLavageMains == true) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type DLM'),
                value: dlmType,
                items: const [
                  DropdownMenuItem(
                    value: 'eau + savon',
                    child: Text('Eau + savon'),
                  ),
                  DropdownMenuItem(
                    value: 'eau seule',
                    child: Text('Eau seule'),
                  ),
                  DropdownMenuItem(value: 'aucun', child: Text('Aucun')),
                ],
                onChanged: (v) => setState(() => dlmType = v),
              ),
            ],
            // TODO: Ajout de la prise de photo (mobile/desktop)
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveForm, child: const Text('Envoyer')),
          ],
        ),
      ),
    );
  }
}
