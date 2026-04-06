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
  String? observations;

  // Champs spécifiques
  int? nbMenagesEnquetes;
  int? nbLatrinesTotal;
  int? nbLatrinesAmeliorees;
  int? nbLatrinesNonAmeliorees;
  int? nbLatrinesAmelioreesHygienique;
  int? nbLatrinesAmelioreesPartagees;
  int? nbLatrinesNonFonctionnelles;
  int? nbLatrinesEndommagees;
  int? nbMenagesUtilisantLatrinesVoisin;
  int? nbMenagesDefecationAirLibre;
  int? nbNouvellesLatrinesConstruites;
  int? nbLatrinesAutofinancees;
  int? nbLatrinesAideExterieure;
  int? nbLatrinesFinanceesCommunaute;
  double? montantInvestiMenages;
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
      'nb_menages_enquetes': nbMenagesEnquetes,
      'nb_latrines_total': nbLatrinesTotal,
      'nb_latrines_ameliorees': nbLatrinesAmeliorees,
      'nb_latrines_non_ameliorees': nbLatrinesNonAmeliorees,
      'nb_latrines_ameliorees_hygienique': nbLatrinesAmelioreesHygienique,
      'nb_latrines_ameliorees_partagees': nbLatrinesAmelioreesPartagees,
      'nb_latrines_non_fonctionnelles': nbLatrinesNonFonctionnelles,
      'nb_latrines_endommagees': nbLatrinesEndommagees,
      'nb_menages_utilisant_latrines_voisin': nbMenagesUtilisantLatrinesVoisin,
      'nb_menages_defecation_air_libre': nbMenagesDefecationAirLibre,
      'nb_nouvelles_latrines_construites': nbNouvellesLatrinesConstruites,
      'nb_latrines_autofinancees': nbLatrinesAutofinancees,
      'nb_latrines_aide_exterieure': nbLatrinesAideExterieure,
      'nb_latrines_financees_communaute': nbLatrinesFinanceesCommunaute,
      'montant_investi_menages': montantInvestiMenages,
      'nb_latrines_avec_dlm': nbLatrinesAvecDLM,
      'nb_avec_eau_savon': nbAvecEauSavon,
      'nb_avec_eau_sans_savon': nbAvecEauSansSavon,
      'nb_menages_sans_dlm': nbMenagesSansDLM,
    };
    await db.insertQuestionnaire({
      'type': 'Dernier suivi localité',
      'data_json': data.toString(),
      'date': dateActivite?.toIso8601String(),
      'localite_id': _adminData?['localite_id'],
      'sync_status': 'local',
      'photo_path': null,
    });
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
              decoration: const InputDecoration(
                labelText: 'Nombre de ménages enquêtés',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbMenagesEnquetes = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre total de latrines',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesTotal = int.tryParse(v),
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
                labelText:
                    'Nombre de latrines améliorées de manière hygiénique',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  nbLatrinesAmelioreesHygienique = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText:
                    'Nombre de latrines améliorées de manière équitable et partagée',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesAmelioreesPartagees = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines non fonctionnelles',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesNonFonctionnelles = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines endommagées (hivernage)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesEndommagees = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de ménages utilisant latrines voisin',
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
                labelText: 'Nombre de nouvelles latrines construites',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  nbNouvellesLatrinesConstruites = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines autofinancées',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesAutofinancees = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines avec aide extérieure',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesAideExterieure = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines financées par la communauté',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => nbLatrinesFinanceesCommunaute = int.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Montant investi par les ménages',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => montantInvestiMenages = double.tryParse(v),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de latrines avec DLM',
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
                labelText: 'Nombre de ménages sans DLM',
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
