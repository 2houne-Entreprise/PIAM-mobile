import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/data/reference_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:piam/services/database_service.dart';

/// Page de paramétrage avec cascades de localités (source : ReferenceData)
class ParametrageScreen extends StatefulWidget {
  const ParametrageScreen({Key? key}) : super(key: key);

  @override
  State<ParametrageScreen> createState() => _ParametrageScreenState();
}

class _ParametrageScreenState extends State<ParametrageScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  int? _selectedWilayaId;
  int? _selectedMoughataaId;
  int? _selectedCommuneId;
  int? _selectedLocaliteId;
  String? _selectedOperator;
  String? _selectedProject;

  bool _showNewLocaliteForm = false;
  final TextEditingController _newLocaliteController = TextEditingController();

  // Listes cascadées calculées depuis ReferenceData (en mémoire, fonctionne sur Web)
  List<Map<String, dynamic>> get _moughataas => _selectedWilayaId == null
      ? []
      : ReferenceData.getMoughatasByWilaya(_selectedWilayaId!);

  List<Map<String, dynamic>> get _communes => _selectedMoughataaId == null
      ? []
      : ReferenceData.getCommunesByMoughataa(_selectedMoughataaId!);

  List<Map<String, dynamic>> get _localites => _selectedCommuneId == null
      ? []
      : ReferenceData.getLocalitesByCommune(_selectedCommuneId!);

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseService().getParametreUtilisateur();
    if (settings != null && mounted) {
      setState(() {
        _selectedWilayaId = settings['wilaya_id'] as int?;
        _selectedMoughataaId = settings['moughataa_id'] as int?;
        _selectedCommuneId = settings['commune_id'] as int?;
        _selectedLocaliteId = settings['localite_id'] as int?;
        _selectedOperator = settings['operateur'] as String?;
        _selectedProject = settings['projet'] as String?;
        _latitudeController.text = settings['gps_lat']?.toString() ?? '';
        _longitudeController.text = settings['gps_lng']?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _newLocaliteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.parametrageTitle),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Localisation
              _buildSectionTitle(context, 'Localisation', Icons.location_on),
              const SizedBox(height: 12),

              // Wilaya
              DropdownButtonFormField<int>(
                value: _selectedWilayaId,
                hint: const Text(AppStrings.selectWilaya),
                validator: (v) => v == null ? AppStrings.requiredField : null,
                onChanged: (value) {
                  setState(() {
                    _selectedWilayaId = value;
                    _selectedMoughataaId = null;
                    _selectedCommuneId = null;
                    _selectedLocaliteId = null;
                  });
                },
                items: ReferenceData.wilayas
                    .map(
                      (w) => DropdownMenuItem<int>(
                        value: w['id'] as int,
                        child: Text(w['intitule_fr'] as String),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Wilaya'),
              ),
              const SizedBox(height: 16),

              // Moughataa (cascade 1)
              DropdownButtonFormField<int>(
                value: _selectedMoughataaId,
                hint: const Text(AppStrings.selectMoughataa),
                validator: (v) => v == null ? AppStrings.requiredField : null,
                onChanged: _selectedWilayaId == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedMoughataaId = value;
                          _selectedCommuneId = null;
                          _selectedLocaliteId = null;
                        });
                      },
                items: _moughataas
                    .map(
                      (m) => DropdownMenuItem<int>(
                        value: m['id'] as int,
                        child: Text(m['intitule_fr'] as String),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Moughataa'),
              ),
              const SizedBox(height: 16),

              // Commune (cascade 2)
              DropdownButtonFormField<int>(
                value: _selectedCommuneId,
                hint: const Text(AppStrings.selectCommune),
                validator: (v) => v == null ? AppStrings.requiredField : null,
                onChanged: _selectedMoughataaId == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCommuneId = value;
                          _selectedLocaliteId = null;
                        });
                      },
                items: _communes
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c['id'] as int,
                        child: Text(c['intitule_fr'] as String),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Commune'),
              ),
              const SizedBox(height: 16),

              // Localité (cascade 3)
              DropdownButtonFormField<int>(
                value: _selectedLocaliteId,
                hint: const Text(AppStrings.selectLocalite),
                validator: (v) =>
                    (!_showNewLocaliteForm && v == null)
                        ? AppStrings.requiredField
                        : null,
                onChanged: _selectedCommuneId == null
                    ? null
                    : (value) {
                        if (value == -1) {
                          setState(() {
                            _showNewLocaliteForm = true;
                            _selectedLocaliteId = null;
                          });
                        } else {
                          setState(() {
                            _selectedLocaliteId = value;
                            _showNewLocaliteForm = false;
                          });
                        }
                      },
                items: [
                  ..._localites.map(
                    (l) => DropdownMenuItem<int>(
                      value: l['id'] as int,
                      child: Text(l['intitule_fr'] as String),
                    ),
                  ),
                  const DropdownMenuItem<int>(
                    value: -1,
                    child: Text(
                      'Nouvelle localité non trouvée',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                decoration: const InputDecoration(labelText: 'Localité'),
              ),

              if (_showNewLocaliteForm) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newLocaliteController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la nouvelle localité',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.my_location),
                        label: const Text('Capturer position'),
                        onPressed: _captureGPS,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("Envoyer à l'admin"),
                        onPressed: _sendNewLocaliteRequest,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Statut : En attente de validation',
                  style: TextStyle(color: Colors.orange[800]),
                ),
                const SizedBox(height: 24),
              ],

              // Section 2: Position GPS
              _buildSectionTitle(context, 'Position GPS', Icons.gps_fixed),
              const SizedBox(height: 12),

              TextFormField(
                controller: _latitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.latitude,
                  hintText: 'Ex: 18.0735',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _longitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'Ex: -15.958',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text(AppStrings.captureGPS),
                  onPressed: _captureGPS,
                ),
              ),
              const SizedBox(height: 24),


              // Section 3: Projet
              _buildSectionTitle(context, 'Projet', Icons.work),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedOperator,
                hint: const Text(AppStrings.selectOperator),
                validator: (v) => v == null ? AppStrings.requiredField : null,
                onChanged: (v) => setState(() => _selectedOperator = v),
                items: ['Opérateur A', 'Opérateur B', 'Opérateur C']
                    .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: AppStrings.selectOperator,
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedProject,
                hint: const Text(AppStrings.selectProject),
                validator: (v) => v == null ? AppStrings.requiredField : null,
                onChanged: (v) => setState(() => _selectedProject = v),
                items: ['Projet Alpha', 'Projet Beta', 'Projet Gamma']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: AppStrings.selectProject,
                ),
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text(AppStrings.confirmButton),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.colorBlue),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Future<void> _captureGPS() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Capture GPS en cours...')),
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Service de localisation désactivé');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission GPS refusée');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permission GPS définitivement refusée');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latitudeController.text = pos.latitude.toString();
        _longitudeController.text = pos.longitude.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Position GPS récupérée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendNewLocaliteRequest() {
    if (_newLocaliteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez saisir le nom de la localité.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Demande envoyée à l'administrateur"),
        backgroundColor: Colors.blue,
      ),
    );
    setState(() {
      _showNewLocaliteForm = false;
      _newLocaliteController.clear();
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await DatabaseService().insertParametreUtilisateur({
        'wilaya_id': _selectedWilayaId,
        'moughataa_id': _selectedMoughataaId,
        'commune_id': _selectedCommuneId,
        'localite_id': _selectedLocaliteId,
        'operateur': _selectedOperator,
        'projet': _selectedProject,
        'gps_lat': double.tryParse(_latitudeController.text),
        'gps_lng': double.tryParse(_longitudeController.text),
        'user_id': 'user_1', // Temporaire
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres sauvegardés avec succès'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde : $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
