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

  final _observationsController = TextEditingController();

  final _db = DatabaseService();

  static const String _formType = 'declenchement';

  int? get _localiteId => _adminData?['localite_id'] as int?;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _observationsController.dispose();
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

  /// Charge le brouillon existant et pré-remplit les champs
  Future<void> _loadDraft() async {
    final draft = await _db.getQuestionnaire(
      type: _formType,
      localiteId: _localiteId,
    );
    if (draft == null) return;

    _observationsController.text = draft['observations'] ?? '';

    if (draft['date_activite'] != null) {
      try {
        dateActivite = DateTime.parse(draft['date_activite']);
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }

  /// Sauvegarde automatique en brouillon
  Future<void> _saveDraft() async {
    if (_localiteId == null) return;
    await _db.upsertQuestionnaire(
      type: _formType,
      localiteId: _localiteId,
      status: 'draft',
      dataMap: _buildDataMap(),
    );
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
      };

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
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _saveForm, child: const Text('Envoyer')),
          ],
        ),
      ),
    );
  }
}
