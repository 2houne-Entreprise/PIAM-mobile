import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/gps_service.dart'
    if (dart.library.html) '../services/gps_service_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/services.dart' show rootBundle;
import 'package:geocoding/geocoding.dart'
    if (dart.library.html) 'parametrage_initial_screen_noop.dart';

class ParametrageInitialScreen extends StatefulWidget {
  final VoidCallback? onGoToDashboard;
  const ParametrageInitialScreen({Key? key, this.onGoToDashboard})
    : super(key: key);

  @override
  State<ParametrageInitialScreen> createState() =>
      _ParametrageInitialScreenState();
}
// ...existing code...

class _ParametrageInitialScreenState extends State<ParametrageInitialScreen> {
  bool _dbReady = false;
  double? latitude;
  double? longitude;
  String? gpsPosition;
  // String? villeAuto;
  // String? communeAuto;
  int? selectedWilayaId;
  int? selectedMoughataaId;
  int? selectedCommuneId;
  int? selectedLocaliteId;
  String? selectedOperateur;
  String? selectedProjet;
  List<Map<String, dynamic>> wilayas = [];
  List<Map<String, dynamic>> moughataas = [];
  List<Map<String, dynamic>> communes = [];
  List<Map<String, dynamic>> localites = [];
  // Listes d'exemple pour opérateurs et projets
  List<String> operateurs = ['Opérateur A', 'Opérateur B', 'Opérateur C'];
  List<Map<String, dynamic>> projets = [
    {'name': 'Projet 1'},
    {'name': 'Projet 2'},
    {'name': 'Projet 3'},
  ];

  Future<void> _importAdminData() async {
    try {
      final dbService = DatabaseService();
      // Utilise ReferenceData intégré dans le code — pas besoin de fichiers JSON
      await dbService.seedFromReferenceData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données administratives importées avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _initDbAndImport();
    } catch (e) {
      debugPrint('Erreur importation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'importation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initDbAndImport();
  }

  Future<void> _initDbAndImport() async {
    try {
      final dbService = DatabaseService();

      // Si la table wilayas est vide, on seme automatiquement depuis ReferenceData
      List<Map<String, dynamic>> loadedWilayas = await dbService.getWilayas();
      if (loadedWilayas.isEmpty) {
        debugPrint('Base vide, initialisation depuis ReferenceData...');
        await dbService.seedFromReferenceData();
        loadedWilayas = await dbService.getWilayas();
      }

      // Charger le paramétrage utilisateur existant
      final existing = await dbService.getParametreUtilisateur();

      List<Map<String, dynamic>> loadedM = [];
      List<Map<String, dynamic>> loadedC = [];
      List<Map<String, dynamic>> loadedL = [];

      int? wId, mId, cId, lId;

      if (existing != null) {
        wId = existing['wilaya_id'];
        mId = existing['moughataa_id'];
        cId = existing['commune_id'];
        lId = existing['localite_id'];
        latitude = existing['gps_lat'];
        longitude = existing['gps_lng'];

        if (wId != null) loadedM = await dbService.getMoughataas(wId);
        if (mId != null) loadedC = await dbService.getCommunes(mId);
        if (cId != null) loadedL = await dbService.getLocalites(cId);
      }

      setState(() {
        wilayas = loadedWilayas;
        moughataas = loadedM;
        communes = loadedC;
        localites = loadedL;
        selectedWilayaId = wId;
        selectedMoughataaId = mId;
        selectedCommuneId = cId;
        selectedLocaliteId = lId;
        _dbReady = true;
      });
    } catch (e, stack) {
      debugPrint('Erreur lors de l\'initialisation de la DB: $e');
      debugPrint(stack.toString());
      setState(() {
        _dbReady = false;
      });
    }
  }

  Future<void> _getExactLocation() async {
    if (kIsWeb) {
      setState(() {
        gpsPosition = "Géolocalisation non supportée sur le web";
      });
      return;
    }
    dynamic position = await GPSService.getLastPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      gpsPosition = placemarks.isNotEmpty
          ? "${placemarks.first.locality}, ${placemarks.first.country}"
          : "Position obtenue";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !_dbReady
            ? (kIsWeb
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.wc, size: 80, color: Colors.blueAccent),
                          SizedBox(height: 16),
                          Text(
                            'Plateforme de suivi de la traîne intelligente',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()))
            : (wilayas.isEmpty)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucune donnée administrative trouvée !',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Veuillez vérifier l\'importation des wilayas, moughataas, communes et localités.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _importAdminData,
                      icon: const Icon(Icons.download),
                      label: const Text('Importer les données administratives'),
                    ),
                  ],
                ),
              )
            : ListView(
                children: [
                  // ...existing code du formulaire...
                  DropdownButtonFormField<String>(
                    value: selectedOperateur,
                    items: operateurs
                        .map(
                          (o) => DropdownMenuItem<String>(
                            value: o,
                            child: Text(o),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedOperateur = value),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Projet'),
                    value: selectedProjet,
                    items: projets
                        .map(
                          (p) => DropdownMenuItem<String>(
                            value: p['name'] as String,
                            child: Text(p['name'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedProjet = value),
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Wilaya'),
                    value: selectedWilayaId,
                    items: wilayas
                        .map(
                          (w) => DropdownMenuItem(
                            value: w['id'] as int,
                            child: Text(w['nom'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      final list = await DatabaseService().getMoughataas(value);
                      setState(() {
                        selectedWilayaId = value;
                        moughataas = list;
                        selectedMoughataaId = null;
                        communes = [];
                        selectedCommuneId = null;
                        localites = [];
                        selectedLocaliteId = null;
                      });
                    },
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Moughataa'),
                    value: selectedMoughataaId,
                    items: moughataas
                        .where(
                          (m) =>
                              selectedWilayaId == null ||
                              m['wilaya_id'] == selectedWilayaId,
                        )
                        .map(
                          (m) => DropdownMenuItem(
                            value: m['id'] as int,
                            child: Text(m['nom'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      final list = await DatabaseService().getCommunes(value);
                      setState(() {
                        selectedMoughataaId = value;
                        communes = list;
                        selectedCommuneId = null;
                        localites = [];
                        selectedLocaliteId = null;
                      });
                    },
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Commune'),
                    value: selectedCommuneId,
                    items: communes
                        .where(
                          (c) =>
                              selectedMoughataaId == null ||
                              c['moughataa_id'] == selectedMoughataaId,
                        )
                        .map(
                          (c) => DropdownMenuItem(
                            value: c['id'] as int,
                            child: Text(c['nom'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      final list = await DatabaseService().getLocalites(value);
                      setState(() {
                        selectedCommuneId = value;
                        localites = list;
                        selectedLocaliteId = null;
                      });
                    },
                  ),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Localité'),
                    value: selectedLocaliteId,
                    items: localites
                        .where(
                          (l) =>
                              selectedCommuneId == null ||
                              l['commune_id'] == selectedCommuneId,
                        )
                        .map(
                          (l) => DropdownMenuItem(
                            value: l['id'] as int,
                            child: Text(l['nom'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLocaliteId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Position GPS',
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: (latitude != null && longitude != null)
                                ? 'Lat: $latitude\nLng: $longitude'
                                : (gpsPosition ?? ''),
                          ),
                          enabled: false,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.gps_fixed),
                        onPressed: () async {
                          await _getExactLocation();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedLocaliteId == null ||
                          selectedProjet == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Veuillez sélectionner une localité et un projet',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      final dbService = DatabaseService();
                      await dbService.insertParametreUtilisateur({
                        'wilaya_id': selectedWilayaId,
                        'moughataa_id': selectedMoughataaId,
                        'commune_id': selectedCommuneId,
                        'localite_id': selectedLocaliteId,
                        'gps_lat': latitude,
                        'gps_lng': longitude,
                        'date': DateTime.now().toIso8601String(),
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Paramétrage initial enregistré.'),
                          ),
                        );
                        if (widget.onGoToDashboard != null) {
                          widget.onGoToDashboard!();
                        }
                      }
                    },
                    child: const Text('Enregistrer et continuer'),
                  ),
                ],
              ),
      ),
    );
  }
}
