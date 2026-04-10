import 'package:flutter/material.dart';
import '../../services/rapport_service.dart';
import '../../services/pdf_service.dart';

class FicheSyntheseSiteScreen extends StatefulWidget {
  final int localiteId;

  const FicheSyntheseSiteScreen({super.key, required this.localiteId});

  @override
  State<FicheSyntheseSiteScreen> createState() => _FicheSyntheseSiteScreenState();
}

class _FicheSyntheseSiteScreenState extends State<FicheSyntheseSiteScreen> {
  final RapportService _rapportService = RapportService();
  final PdfService _pdfService = PdfService();
  bool _isLoading = true;
  Map<String, dynamic>? _siteData;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final data = await _rapportService.genererFicheSynthese(widget.localiteId);
    setState(() {
      _siteData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fiche de Synthèse Site')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final ident = _siteData?['identification'] ?? {};
    final avancement = _siteData?['avancement'] ?? 0.0;
    final cumuls = _siteData?['cumuls'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche de Synthèse Site'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter en PDF',
            onPressed: () => _pdfService.exporterFicheSynthese(_siteData!),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Identification du Site', [
            _row('Intitulé du projet', ident['intituleProjet']),
            _row('Type infrastructure', ident['typeSite']),
            _row('Nombre de blocs', ident['nbBlocs']?.toString()),
            _row('Nombre de cabines', ident['nbCabines']?.toString()),
            _row('Nombre de cabines réhabilitées', ident['nbCabinesRehabilitees']?.toString()),
          ]),
          const SizedBox(height: 16),
          _buildSection('Avancement Physique', [
            _row('Taux d\'avancement', '${(avancement as double).toStringAsFixed(1)}%'),
            _row('Modèle latrine', ident['typeLatrines']),
          ]),
          const SizedBox(height: 16),
          _buildSection('Indicateurs PGES & MGP (Cumulés)', [
            _row('Nb accidents enregistrés', cumuls['accidents']?.toString() ?? '0'),
            _row('Nb plaintes nuisance chantier', cumuls['plaintesNuisance']?.toString() ?? '0'),
            _row('Nb plaintes VBG', cumuls['plaintesVBG']?.toString() ?? '0'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueAccent),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
