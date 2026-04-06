import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/utils/validators.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/data/reference_data.dart';
import 'package:geolocator/geolocator.dart';

/// Formulaire de Déclenchement
class DeeclenchementPage extends StatefulWidget {
  final String formulaireId;

  const DeeclenchementPage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<DeeclenchementPage> createState() => _DeeclenchementPageState();
}

class _DeeclenchementPageState extends State<DeeclenchementPage> {
  String? _localisationInfo;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _dateController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _localiteController;
  late final TextEditingController _remarquesController;

  bool _isLoading = false;
  String? _selectedLocalite;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _dateController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _localiteController = TextEditingController();
    _remarquesController = TextEditingController();
    _loadLocalisation();
  }

  Future<void> _loadLocalisation() async {
    final db = DatabaseService();
    final param = await db.getParametreUtilisateur();
    if (mounted && param != null) {
      // 1. Auto-fill GPS si disponible depuis le paramétrage
      if (param['gps_lat'] != null) {
        _latitudeController.text = param['gps_lat'].toString();
      }
      if (param['gps_lng'] != null) {
        _longitudeController.text = param['gps_lng'].toString();
      }

      // 2. Traduction de l'ID en Nom pour que l'utilisateur comprenne
      int? locId = param['localite_id'];
      int? communeId = param['commune_id'];
      String resolvedName = 'Inconnue';

      if (locId != null) {
        final found = ReferenceData.localites.where((l) => l['id'] == locId).toList();
        if (found.isNotEmpty) resolvedName = (found.first['intitule_fr'] ?? found.first['intitule']).toString();
      } else if (communeId != null) {
        final found = ReferenceData.communes.where((c) => c['id'] == communeId).toList();
        if (found.isNotEmpty) resolvedName = (found.first['intitule_fr'] ?? found.first['intitule']).toString();
      }

      setState(() {
        _selectedLocalite = resolvedName;
        _localiteController.text = resolvedName;
        _localisationInfo = [
          if (param['wilaya_id'] != null) 'Wilaya: ${param['wilaya_id']}',
          if (param['moughataa_id'] != null) 'Moughataa: ${param['moughataa_id']}',
          if (communeId != null) 'Commune: $communeId',
          if (locId != null) 'Localité: $locId',
        ].where((e) => e.isNotEmpty).join(' | ');
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _localiteController.dispose();
    _remarquesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.declenchementTitle),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bloc localisation (paramétrage initial)
              if (_localisationInfo != null && _localisationInfo!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.place, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _localisationInfo ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              // ...existing code...

              // Champ Date
              Text(
                AppStrings.dateChantier,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  // Validation: date not in future
                  if (_selectedDate != null &&
                      _selectedDate!.isAfter(DateTime.now())) {
                    return AppStrings.invalidDate;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: AppStrings.dateChantierHint,
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _dateController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _dateController.clear();
                            _selectedDate = null;
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Champ GPS
              Text(
                AppStrings.positionGPS,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Latitude
              TextFormField(
                controller: _latitudeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  if (!AppValidators.isValidGPS(
                    value,
                    _longitudeController.text,
                  )) {
                    return AppStrings.invalidGPS;
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: AppStrings.latitude,
                  hintText: '16.0 / 27.0',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),

              // Longitude
              TextFormField(
                controller: _longitudeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  if (!AppValidators.isValidGPS(
                    _latitudeController.text,
                    value,
                  )) {
                    return AppStrings.invalidGPS;
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: '-8.0 / -14.0',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Format: Latitude 16-27 | Longitude -8 à -14',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 20),

              // Bouton capturer GPS
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Capturer position GPS'),
                  onPressed: _captureGPS,
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown Localité
              Text(
                AppStrings.selectLocalite,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLocalite,
                hint: const Text('Sélectionner une localité'),
                validator: (value) {
                  if (value == null) {
                    return AppStrings.requiredField;
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedLocalite = value;
                    _localiteController.text = value ?? '';
                  });
                },
                items: _buildLocaliteItems(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.public),
                ),
              ),
              const SizedBox(height: 20),

              // Champ Remarques
              Text(
                AppStrings.remarques,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _remarquesController,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: AppStrings.remarquesHint,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Icon(Icons.note),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDraft,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(AppStrings.save),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bouton Envoyer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text(AppStrings.send),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colorGreen,
                  ),
                  onPressed: _isLoading ? null : _submit,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildLocaliteItems() {
    // Liste temporaire - Dans une version finale, on filtre la liste ReferenceData par commune
    final localites = [
      'Chinguetti',
      'Ouadane',
      'Araouane',
      'Tichit',
      'Walata',
      'Ouata',
      'Bir Moghrein',
      'Kaedi',
    ];

    // Important : On s'assure que la valeur auto-remplie depuis le paramétrage fait bien partie de la liste,
    // sinon le DropdownButton va crasher (AssertionError sur 'items == null || items.isEmpty').
    if (_selectedLocalite != null && !localites.contains(_selectedLocalite)) {
      localites.insert(0, _selectedLocalite!);
    }

    return localites
        .toSet() // Évite les doublons
        .map(
          (localite) =>
              DropdownMenuItem(value: localite, child: Text(localite)),
        )
        .toList();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
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
            content: Text('Position GPS mise à jour'),
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

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseService();
      final param = await db.getParametreUtilisateur();
      final data = {
        'type': 'declenchement',
        'data_json': {
          'date': _dateController.text,
          'latitude': _latitudeController.text,
          'longitude': _longitudeController.text,
          'localite': _selectedLocalite,
          'remarques': _remarquesController.text,
        }.toString(),
        'date': DateTime.now().toIso8601String(),
        'user_id': null,
        'localite_id': param != null ? param['localite_id'] : null,
      };
      await db.insertQuestionnaire(data);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formulaire sauvegardé'),
            backgroundColor: Color.fromARGB(255, 16, 185, 129),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseService();
      final param = await db.getParametreUtilisateur();
      final data = {
        'type': 'declenchement',
        'data_json': {
          'date': _dateController.text,
          'latitude': _latitudeController.text,
          'longitude': _longitudeController.text,
          'localite': _selectedLocalite,
          'remarques': _remarquesController.text,
        }.toString(),
        'date': DateTime.now().toIso8601String(),
        'user_id': null,
        'localite_id': param != null ? param['localite_id'] : null,
      };
      await db.insertQuestionnaire(data);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formulaire envoyé'),
            backgroundColor: Color.fromARGB(255, 16, 185, 129),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
