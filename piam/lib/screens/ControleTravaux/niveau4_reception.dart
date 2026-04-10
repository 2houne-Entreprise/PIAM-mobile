import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/database_service.dart';
import '../../presentation/widgets/form_header_widget.dart';
import '../rapports/dashboard_rapports.dart' as new_dashboard;

class Niveau4Reception extends StatefulWidget {
  static const String routeName = '/niveau4';

  const Niveau4Reception({super.key});

  @override
  State<Niveau4Reception> createState() => _Niveau4ReceptionState();
}

class _Niveau4ReceptionState extends State<Niveau4Reception> {
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  int? _localiteId;
  dynamic _userId;

  final TextEditingController _dateReceptionTechniqueController = TextEditingController();
  final TextEditingController _reservesTechniqueController = TextEditingController();
  final TextEditingController _delaiTechniqueController = TextEditingController();

  final TextEditingController _dateReceptionProvisoireController = TextEditingController();
  final TextEditingController _reservesProvisoireController = TextEditingController();
  final TextEditingController _delaiProvisoireController = TextEditingController();

  final Map<String, String?> _photos = {
    'receptionTechnique': null,
    'receptionProvisoire': null,
  };

  final Map<String, Map<String, String>?> _photosGps = {
    'receptionTechnique': null,
    'receptionProvisoire': null,
  };

  @override
  void dispose() {
    _dateReceptionTechniqueController.dispose();
    _reservesTechniqueController.dispose();
    _delaiTechniqueController.dispose();
    _dateReceptionProvisoireController.dispose();
    _reservesProvisoireController.dispose();
    _delaiProvisoireController.dispose();
    super.dispose();
  }

  void _onLocalisationLoaded(int? localiteId, dynamic userId) {
    setState(() {
      _localiteId = localiteId;
      _userId = userId;
    });
    if (localiteId != null) _loadSavedData(localiteId);
  }

  Future<void> _loadSavedData(int localiteId) async {
    final data = await _dbService.getQuestionnaire(
      type: 'reception',
      localiteId: localiteId,
    );
    if (data == null || !mounted) return;

    setState(() {
      final rt = data['reception_technique'] ?? {};
      final rp = data['reception_provisoire'] ?? {};
      
      _dateReceptionTechniqueController.text = rt['date'] ?? '';
      _reservesTechniqueController.text = rt['reserves'] ?? '';
      _delaiTechniqueController.text = rt['delai_levee_reserves'] ?? '';
      
      _dateReceptionProvisoireController.text = rp['date'] ?? '';
      _reservesProvisoireController.text = rp['reserves'] ?? '';
      _delaiProvisoireController.text = rp['delai_levee_reserves'] ?? '';
      
      _photos['receptionTechnique'] = rt['photo'];
      _photos['receptionProvisoire'] = rp['photo'];
      
      _photosGps['receptionTechnique'] = (rt['photoGps'] as Map?)?.cast<String, String>();
      _photosGps['receptionProvisoire'] = (rp['photoGps'] as Map?)?.cast<String, String>();
    });
  }

  Future<void> _takePhoto(String sectionKey) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obtention de la position GPS...')),
      );

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission GPS refusée')));
        setState(() {
          _photos[sectionKey] = photo.path;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _photos[sectionKey] = photo.path;
        _photosGps[sectionKey] = {
          'lat': position.latitude.toString(),
          'lng': position.longitude.toString(),
        };
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la prise de photo: $error')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPhotoField(String photoKey, String label) {
    final photoPath = _photos[photoKey];
    final gps = _photosGps[photoKey];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _takePhoto(photoKey),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Prendre la photo'),
            ),
            if (photoPath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: photoPath.startsWith('/') 
                    ? Image.file(File(photoPath), height: 180, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(photoPath, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            if (gps != null) ...[
              const SizedBox(height: 8),
              Text(
                'GPS: ${gps['lat']}, ${gps['lng']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceptionCard({
    required String title,
    required IconData icon,
    required TextEditingController dateController,
    required TextEditingController reservesController,
    required TextEditingController delaiController,
    required String photoKey,
    required String photoLabel,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: Colors.green.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        children: [
          _buildTextField('Date', dateController),
          _buildTextField('Réserves émises', reservesController, maxLines: 3),
          _buildTextField('Délai fixé pour levée des réserves', delaiController),
          _buildPhotoField(photoKey, photoLabel),
        ],
      ),
    );
  }

  Future<void> _saveNiveau4() async {
    if (_localiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un site')));
      return;
    }

    final dataMap = {
      'reception_technique': {
        'date': _dateReceptionTechniqueController.text,
        'reserves': _reservesTechniqueController.text,
        'delai_levee_reserves': _delaiTechniqueController.text,
        'photo': _photos['receptionTechnique'],
        'photoGps': _photosGps['receptionTechnique'],
      },
      'reception_provisoire': {
        'date': _dateReceptionProvisoireController.text,
        'reserves': _reservesProvisoireController.text,
        'delai_levee_reserves': _delaiProvisoireController.text,
        'photo': _photos['receptionProvisoire'],
        'photoGps': _photosGps['receptionProvisoire'],
      },
    };

    await _dbService.upsertQuestionnaire(
      type: 'reception',
      localiteId: _localiteId,
      dataMap: dataMap,
      userId: _userId,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Niveau 4 enregistré avec succès')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Niveau 4 - Réception')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormHeaderWidget(onDataLoaded: _onLocalisationLoaded),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Questionnaire de réception', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Renseigner les dates, réserves, délais et joindre les photos obligatoires prévues au formulaire.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildReceptionCard(
            title: 'i. Réception technique',
            icon: Icons.rule_folder_outlined,
            dateController: _dateReceptionTechniqueController,
            reservesController: _reservesTechniqueController,
            delaiController: _delaiTechniqueController,
            photoKey: 'receptionTechnique',
            photoLabel: 'Photo des éléments à reprendre',
          ),
          const SizedBox(height: 12),
          _buildReceptionCard(
            title: 'ii. Réception provisoire',
            icon: Icons.fact_check_outlined,
            dateController: _dateReceptionProvisoireController,
            reservesController: _reservesProvisoireController,
            delaiController: _delaiProvisoireController,
            photoKey: 'receptionProvisoire',
            photoLabel: 'Photo',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveNiveau4,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Enregistrer Niveau 4'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/rapports_dashboard'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
            child: const Text('Aller aux Tableaux de Synthèse'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
