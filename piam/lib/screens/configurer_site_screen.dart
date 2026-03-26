import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/sqlite_service.dart';
import 'niveau1_donnees_generales.dart';

class ConfigurerSiteScreen extends StatefulWidget {
  static const String routeName = '/configurer_site';

  const ConfigurerSiteScreen({super.key});

  @override
  State<ConfigurerSiteScreen> createState() => _ConfigurerSiteScreenState();
}

class _ConfigurerSiteScreenState extends State<ConfigurerSiteScreen> {
  final SQLiteService _db = SQLiteService();

  List<String> _wilayas = [];
  List<String> _moughataas = [];
  List<String> _communes = [];
  List<String> _localites = [];

  final Map<String, int> _wilayaIds = {};
  final Map<String, int> _moughataaIds = {};
  final Map<String, int> _communeIds = {};
  final Map<String, int> _localiteIds = {};
  final Map<String, String?> _localiteCodeAnsade = {};

  String? _wilaya;
  String? _moughataa;
  String? _commune;
  String? _localite;
  String? _gpsLat;
  String? _gpsLng;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadWilayas();
  }

  Future<void> _loadWilayas() async {
    final rows = await _db.getWilayas();
    if (!mounted) return;
    setState(() {
      _wilayaIds
        ..clear()
        ..addEntries(
          rows.map((row) {
            final name = (row['intitule_fr']?.toString().isNotEmpty ?? false)
                ? row['intitule_fr'].toString()
                : row['intitule'].toString();
            return MapEntry(name, (row['id'] as int?) ?? 0);
          }),
        );
      _wilayas = _wilayaIds.keys.toList();
    });
  }

  Future<void> _loadMoughataas(String wilaya) async {
    final id = _wilayaIds[wilaya];
    if (id == null) return;
    final rows = await _db.getMoughatas(id);
    if (!mounted) return;
    setState(() {
      _moughataaIds
        ..clear()
        ..addEntries(
          rows.map((row) {
            final name = (row['intitule_fr']?.toString().isNotEmpty ?? false)
                ? row['intitule_fr'].toString()
                : row['intitule'].toString();
            return MapEntry(name, (row['id'] as int?) ?? 0);
          }),
        );
      _moughataas = _moughataaIds.keys.toList();
      _moughataa = null;
      _commune = null;
      _localite = null;
      _communes = [];
      _localites = [];
    });
  }

  Future<void> _loadCommunes(String moughataa) async {
    final id = _moughataaIds[moughataa];
    if (id == null) return;
    final rows = await _db.getCommunes(id);
    if (!mounted) return;
    setState(() {
      _communeIds
        ..clear()
        ..addEntries(
          rows.map((row) {
            final name = (row['intitule_fr']?.toString().isNotEmpty ?? false)
                ? row['intitule_fr'].toString()
                : row['intitule'].toString();
            return MapEntry(name, (row['id'] as int?) ?? 0);
          }),
        );
      _communes = _communeIds.keys.toList();
      _commune = null;
      _localite = null;
      _localites = [];
    });
  }

  Future<void> _loadLocalites(String commune) async {
    final id = _communeIds[commune];
    if (id == null) return;
    final rows = await _db.getLocalites(id);
    if (!mounted) return;
    setState(() {
      _localiteIds.clear();
      _localiteCodeAnsade.clear();
      _localites = rows.map((row) {
        final name = (row['intitule_fr']?.toString().isNotEmpty ?? false)
            ? row['intitule_fr'].toString()
            : row['intitule'].toString();
        _localiteIds[name] = (row['id'] as int?) ?? 0;
        _localiteCodeAnsade[name] = row['code_ansade']?.toString();
        return name;
      }).toList();
      _localite = null;
    });
  }

  Future<void> _useGpsLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Permission GPS refusée')));
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;
    setState(() {
      _gpsLat = pos.latitude.toStringAsFixed(6);
      _gpsLng = pos.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _saveConfiguration() async {
    setState(() => _isSaving = true);
    await _db.setConfigValue('site.wilaya', _wilaya ?? '');
    await _db.setConfigValue('site.moughataa', _moughataa ?? '');
    await _db.setConfigValue('site.commune', _commune ?? '');
    await _db.setConfigValue('site.localite', _localite ?? '');
    await _db.setConfigValue(
      'site.codeAnsade',
      _localite != null ? (_localiteCodeAnsade[_localite] ?? '') : '',
    );
    await _db.setConfigValue('site.gps.lat', _gpsLat ?? '');
    await _db.setConfigValue('site.gps.lng', _gpsLng ?? '');
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration du site enregistrée')),
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text('Sélectionnez $label'),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurer le site')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Renseignez votre emplacement. Si la localité n\'est pas trouvée, utilisez la géolocalisation GPS.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _dropdown('Wilaya', _wilaya, _wilayas, (val) {
            setState(() => _wilaya = val);
            if (val != null) _loadMoughataas(val);
          }),
          const SizedBox(height: 10),
          _dropdown('Moughataa', _moughataa, _moughataas, (val) {
            setState(() => _moughataa = val);
            if (val != null) _loadCommunes(val);
          }),
          const SizedBox(height: 10),
          _dropdown('Commune', _commune, _communes, (val) {
            setState(() => _commune = val);
            if (val != null) _loadLocalites(val);
          }),
          const SizedBox(height: 10),
          _dropdown('Localité', _localite, _localites, (val) {
            setState(() => _localite = val);
          }),
          if (_commune != null && _localites.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Localité non retrouvée. Utilisez la localisation GPS ci-dessous.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          const SizedBox(height: 10),
          TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Code ANSADE',
              border: const OutlineInputBorder(),
              suffixText: _localite != null
                  ? (_localiteCodeAnsade[_localite] ?? '-')
                  : '-',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _useGpsLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Utiliser ma localisation GPS'),
          ),
          if (_gpsLat != null && _gpsLng != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('GPS: $_gpsLat, $_gpsLng'),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveConfiguration,
            icon: const Icon(Icons.save),
            label: Text(
              _isSaving ? 'Enregistrement...' : 'Enregistrer configuration',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(Niveau1DonneesGenerales.routeName),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuer vers Niveau 1'),
          ),
        ],
      ),
    );
  }
}
