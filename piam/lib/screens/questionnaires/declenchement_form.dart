import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class DeclenchementForm extends StatefulWidget {
  static const String routeName = '/declenchement';
  const DeclenchementForm({Key? key}) : super(key: key);

  @override
  State<DeclenchementForm> createState() => _DeclenchementFormState();
}

class _DeclenchementFormState extends State<DeclenchementForm> {
  bool _loading = true;
  Map<String, dynamic>? _adminData;
  double? latitude;
  double? longitude;
  DateTime? dateActivite;
  String? observations;

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
    };
    await db.insertQuestionnaire({
      'type': 'Déclenchement',
      'data_json': data.toString(),
      'date': dateActivite?.toIso8601String(),
      'localite_id': _adminData?['localite_id'],
      'sync_status': 'local',
      'photo_path': null,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déclenchement enregistré.')),
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
      appBar: AppBar(title: const Text('Déclenchement')),
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
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveForm, child: const Text('Envoyer')),
          ],
        ),
      ),
    );
  }
}
