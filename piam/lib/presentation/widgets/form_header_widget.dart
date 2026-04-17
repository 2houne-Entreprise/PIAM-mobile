import 'package:flutter/material.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/data/reference_data.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';

class FormHeaderWidget extends StatefulWidget {
  final Function(int? localiteId, dynamic userId) onDataLoaded;

  const FormHeaderWidget({Key? key, required this.onDataLoaded}) : super(key: key);

  @override
  State<FormHeaderWidget> createState() => _FormHeaderWidgetState();
}

class _FormHeaderWidgetState extends State<FormHeaderWidget> {
  String? _localisationInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalisation();
  }

  Future<void> _loadLocalisation() async {
    final db = DatabaseService();
    final param = await db.getParametreUtilisateur();
    
    if (mounted && param != null) {
      int? localiteId = param['localite_id'] as int?;
      int? communeId = param['commune_id'] as int?;
      int? wilayaId = param['wilaya_id'] as int?;
      int? moughataaId = param['moughataa_id'] as int?;
      dynamic userId = param['user_id'];

      String resolvedWilaya = wilayaId?.toString() ?? '';
      String resolvedMoughataa = moughataaId?.toString() ?? '';
      String resolvedCommune = communeId?.toString() ?? '';
      String resolvedLoc = localiteId?.toString() ?? '';

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
        if (localiteId != null) {
          final l = ReferenceData.localites.where((l) => l['id'] == localiteId).toList();
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
        _isLoading = false;
      });

      // On informe le formulaire parent avec 0 si null pour forcer le load
      widget.onDataLoaded(localiteId ?? 0, userId);
    } else {
      if (mounted) {
        setState(() {
           _isLoading = false;
           _localisationInfo = '⚠️ Aucune donnée de paramétrage trouvée.\nVeuillez configurer l\'application depuis l\'onglet Paramétrage.';
        });
        widget.onDataLoaded(0, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_localisationInfo != null && _localisationInfo!.startsWith('⚠️')) {
      return AppInfoBanner(
        message: _localisationInfo!.replaceAll('⚠️ ', ''),
        color: AppTheme.errorColor,
        icon: Icons.warning_amber_rounded,
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LOCALISATION SÉLECTIONNÉE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _localisationInfo ?? '',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
