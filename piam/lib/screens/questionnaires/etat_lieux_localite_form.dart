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
  String? observations;

  // Champs spécifiques
  int? populationTotale;
  int? nbHommes;
  int? nbFemmes;
  int? nbEnfantsMoins5;
  int? nbMenages;
  bool? accesEau;
  int? nbLatrinesFamiliales;
  int? nbLatrinesAmeliorees;
  int? nbLatrinesNonAmeliorees;
  int? nbLatrinesEndommagees;
  int? nbMenagesUtilisantLatrinesVoisin;
  int? nbMenagesDefecationAirLibre;
  int? nbLatrinesAvecDLM;
  int? nbAvecEauSavon;
  int? nbAvecEauSansSavon;
  int? nbMenagesSansDLM;

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
      'population_totale': populationTotale,
      'nb_hommes': nbHommes,
      'nb_femmes': nbFemmes,
      'nb_enfants_moins_5': nbEnfantsMoins5,
      'nb_menages': nbMenages,
      'acces_eau': accesEau,
      'nb_latrines_familiales': nbLatrinesFamiliales,
      'nb_latrines_ameliorees': nbLatrinesAmeliorees,
      'nb_latrines_non_ameliorees': nbLatrinesNonAmeliorees,
      'nb_latrines_endommagees': nbLatrinesEndommagees,
      'nb_menages_utilisant_latrines_voisin': nbMenagesUtilisantLatrinesVoisin,
      'nb_menages_defecation_air_libre': nbMenagesDefecationAirLibre,
      'nb_latrines_avec_dlm': nbLatrinesAvecDLM,
      'nb_avec_eau_savon': nbAvecEauSavon,
      'nb_avec_eau_sans_savon': nbAvecEauSansSavon,
      'nb_menages_sans_dlm': nbMenagesSansDLM,
    };
    await db.insertQuestionnaire({
      'type': 'État des lieux localité',
      'data_json': data.toString(),
      'date': dateActivite?.toIso8601String(),
      'localite_id': _adminData?['localite_id'],
      'sync_status': 'local',
      'photo_path': null,
    });
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
              decoration: const InputDecoration(labelText: 'Population totale'),
              keyboardType: TextInputType.number,
              onChanged: (v) => populationTotale = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre d’hommes'),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbHommes = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre de femmes'),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbFemmes = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre d’enfants < 5 ans',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbEnfantsMoins5 = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre de ménages'),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbMenages = int.tryParse(v),
            ),
            SwitchListTile(
              title: const Text('Accès à l’eau'),
              value: accesEau ?? false,
              onChanged: (v) => setState(() => accesEau = v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre total de latrines familiales',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesFamiliales = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines améliorées',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesAmeliorees = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines non améliorées',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesNonAmeliorees = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines endommagées',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesEndommagees = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText:
                    'Nombre de ménages utilisant les latrines des voisins',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  nbMenagesUtilisantLatrinesVoisin = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText:
                    'Nombre de ménages pratiquant la défécation à l’air libre',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbMenagesDefecationAirLibre = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText:
                    'Nombre de latrines avec dispositif de lavage des mains',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesAvecDLM = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre avec eau + savon',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbAvecEauSavon = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre avec eau sans savon',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbAvecEauSansSavon = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de ménages sans dispositif',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbMenagesSansDLM = int.tryParse(v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveForm, child: const Text('Envoyer')),
          ],
        ),
      ),
    );
  }
}
