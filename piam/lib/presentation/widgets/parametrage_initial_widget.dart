import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/reference_data.dart';
import '../../services/database_service.dart';
import 'package:geolocator/geolocator.dart';

/// Widget de param\u00e9trage initial utilisant ReferenceData en m\u00e9moire.
/// Fonctionne sur Web ET Mobile sans SQLite.
class ParametrageInitialWidget extends StatefulWidget {
  final VoidCallback? onGoToDashboard;

  const ParametrageInitialWidget({Key? key, this.onGoToDashboard}) : super(key: key);

  @override
  ParametrageInitialWidgetState createState() =>
      ParametrageInitialWidgetState();
}

class ParametrageInitialWidgetState
    extends State<ParametrageInitialWidget> {
  double? latitude;
  double? longitude;
  bool isGettingLocation = false;

  int? selectedWilayaId;
  int? selectedMoughataaId;
  int? selectedCommuneId;

  // Cascades calcul\u00e9es en m\u00e9moire depuis ReferenceData \u2014 aucune DB requise
  List<Map<String, dynamic>> get moughataas => selectedWilayaId == null
      ? []
      : ReferenceData.getMoughatasByWilaya(selectedWilayaId!);

  List<Map<String, dynamic>> get communes => selectedMoughataaId == null
      ? []
      : ReferenceData.getCommunesByMoughataa(selectedMoughataaId!);

  @override
  void initState() {
    super.initState();
    // Au d\u00e9marrage, on peut tenter de r\u00e9cup\u00e9rer silencieusement si n\u00e9cessaire,
    // mais g\u00e9n\u00e9ralement il vaut mieux que l'utilisateur le fasse manuellement.
  }

  Future<void> _getLocation() async {
    setState(() => isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Service d\u00e9sactiv\u00e9');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission refus\u00e9e');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permission refus\u00e9e d\u00e9finitivement');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
        isGettingLocation = false;
      });
    } catch (e) {
      setState(() => isGettingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur GPS: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Wilaya ──────────────────────────────────────────────────────────
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Wilaya',
              border: OutlineInputBorder(),
            ),
            value: selectedWilayaId,
            hint: const Text('Sélectionner une wilaya'),
            items: ReferenceData.wilayas
                .map(
                  (w) => DropdownMenuItem<int>(
                    value: w['id'] as int,
                    child: Text(w['intitule_fr'] as String),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedWilayaId = val;
                selectedMoughataaId = null;
                selectedCommuneId = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // ── Moughataa ────────────────────────────────────────────────────────
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Moughataa',
              border: OutlineInputBorder(),
            ),
            value: selectedMoughataaId,
            hint: const Text('Sélectionner une moughataa'),
            items: moughataas
                .map(
                  (m) => DropdownMenuItem<int>(
                    value: m['id'] as int,
                    child: Text(m['intitule_fr'] as String),
                  ),
                )
                .toList(),
            onChanged: selectedWilayaId == null
                ? null
                : (val) {
                    setState(() {
                      selectedMoughataaId = val;
                      selectedCommuneId = null;
                    });
                  },
          ),
          const SizedBox(height: 16),

          // ── Commune ──────────────────────────────────────────────────────────
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Commune',
              border: OutlineInputBorder(),
            ),
            value: selectedCommuneId,
            hint: const Text('Sélectionner une commune'),
            items: communes
                .map(
                  (c) => DropdownMenuItem<int>(
                    value: c['id'] as int,
                    child: Text(c['intitule_fr'] as String),
                  ),
                )
                .toList(),
            onChanged: selectedMoughataaId == null
                ? null
                : (val) {
                    setState(() {
                      selectedCommuneId = val;
                    });
                  },
          ),
          const SizedBox(height: 24),

          // ── GPS ──────────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.gps_fixed, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: isGettingLocation
                    ? const Text('Recherche GPS...')
                    : (latitude != null && longitude != null)
                        ? Text(
                            'Lat: ${latitude!.toStringAsFixed(6)}, '
                            'Lng: ${longitude!.toStringAsFixed(6)}',
                          )
                        : const Text('GPS non défini'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Rafraîchir la position',
                onPressed: isGettingLocation ? null : _getLocation,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Bouton Enregistrer ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
              onPressed: (selectedWilayaId != null &&
                      selectedMoughataaId != null &&
                      selectedCommuneId != null)
                  ? () async {
                      // Sauvegarde la configuration choisie
                      final db = DatabaseService();
                      await db.insertParametreUtilisateur({
                        'wilaya_id': selectedWilayaId,
                        'moughataa_id': selectedMoughataaId,
                        'commune_id': selectedCommuneId,
                        'localite_id': null, // Non sélectionné dans cette vue
                        'gps_lat': latitude,
                        'gps_lng': longitude,
                        'date': DateTime.now().toIso8601String(),
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Paramètres enregistrés !'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        if (widget.onGoToDashboard != null) {
                          widget.onGoToDashboard!();
                        }
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
