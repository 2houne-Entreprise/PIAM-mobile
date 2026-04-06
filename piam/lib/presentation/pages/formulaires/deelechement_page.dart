import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/data/reference_data.dart';

/// Formulaire de Déclenchement (Simplifié)
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

  bool _isLoading = false;
  DateTime? _selectedDate;
  int? _localiteId;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _dateController = TextEditingController();
    _loadLocalisation();
  }

  Future<void> _loadLocalisation() async {
    final db = DatabaseService();
    final param = await db.getParametreUtilisateur();
    if (mounted && param != null) {
      _localiteId = param['localite_id'] as int?;
      int? communeId = param['commune_id'] as int?;
      int? wilayaId = param['wilaya_id'] as int?;
      int? moughataaId = param['moughataa_id'] as int?;

      String resolvedWilaya = wilayaId?.toString() ?? '';
      String resolvedMoughataa = moughataaId?.toString() ?? '';
      String resolvedCommune = communeId?.toString() ?? '';
      String resolvedLoc = _localiteId?.toString() ?? '';

      try {
        if (wilayaId != null) {
          final w = ReferenceData.wilayas.where((w) => w['id'] == wilayaId).toList();
          if (w.isNotEmpty) resolvedWilaya = w.first['intitule_fr']?.toString() ?? w.first['intitule'].toString();
        }
        if (moughataaId != null && wilayaId != null) {
          final m = ReferenceData.getMoughatasByWilaya(wilayaId).where((m) => m['id'] == moughataaId).toList();
          if (m.isNotEmpty) resolvedMoughataa = m.first['intitule_fr']?.toString() ?? m.first['intitule'].toString();
        }
        if (communeId != null && moughataaId != null) {
          final c = ReferenceData.getCommunesByMoughataa(moughataaId).where((c) => c['id'] == communeId).toList();
          if (c.isNotEmpty) resolvedCommune = c.first['intitule_fr']?.toString() ?? c.first['intitule'].toString();
        }
        if (_localiteId != null) {
          final l = ReferenceData.localites.where((l) => l['id'] == _localiteId).toList();
          if (l.isNotEmpty) resolvedLoc = l.first['intitule_fr']?.toString() ?? l.first['intitule'].toString();
        }
      } catch (_) {}

      setState(() {
        _localisationInfo = [
          if (resolvedWilaya.isNotEmpty) '📍 Wilaya: $resolvedWilaya',
          if (resolvedMoughataa.isNotEmpty) '📍 Moughataa: $resolvedMoughataa',
          if (resolvedCommune.isNotEmpty) '📍 Commune: $resolvedCommune',
          if (resolvedLoc.isNotEmpty) '📍 Localité: $resolvedLoc',
          if (param['gps_lat'] != null) '🌐 GPS: ${param['gps_lat']}, ${param['gps_lng']}'
        ].where((e) => e.isNotEmpty).join('\n');
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseService();
      // On récupère activement les données du paramétrage pour lier le user_id etc.
      // D'après la règle 11: user_id viendra du login (ex stocké dans prefs/db)
      // En l'occurence il y a "user_id" dans SQLite mais pour le moment on le set de façon générique 
      // ou on récupère du parametre si dispo.
      final param = await db.getParametreUtilisateur();
      
      final data = {
        'type': 'declenchement',
        'data_json': {
          'date_activite': _dateController.text,
          // on ne sauvegarde que l'essentiel
        }.toString(),
        'date': DateTime.now().toIso8601String(),
        'user_id': param != null ? param['user_id'] : null, // Liaison à l'utilisateur
        'localite_id': _localiteId, // Liaison à la localité du paramétrage
      };
      
      await db.insertQuestionnaire(data);
      await Future.delayed(const Duration(milliseconds: 600)); // feedback visuel
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déclenchement enregistré avec succès'),
            backgroundColor: Color.fromARGB(255, 16, 185, 129),
          ),
        );
        Navigator.pop(context); // Retour automatique au Dashboard !
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
              // Bloc localisation (Lecture Seule)
              if (_localisationInfo != null && _localisationInfo!.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DONNÉES DU PARAMÉTRAGE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _localisationInfo!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),

              // Titre de section "Saisie de l'information"
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                  border: const Border(left: BorderSide(color: AppTheme.primaryColor, width: 4)),
                ),
                child: const Text(
                  'SAISIE DU DÉCLENCHEMENT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Champ Date d'activité (Unique interaction)
              Text(
                'Date de l\'activité *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                  if (_selectedDate != null && _selectedDate!.isAfter(DateTime.now())) {
                    return AppStrings.invalidDate;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Sélectionnez la date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _dateController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dateController.clear();
                              _selectedDate = null;
                            });
                          },
                        )
                      : null,
                ),
              ),
              
              const SizedBox(height: 48),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colorGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              AppStrings.send,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
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
}
