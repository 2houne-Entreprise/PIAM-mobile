import 'package:flutter/material.dart';
import '../../services/rapport_service.dart';
import '../../services/pdf_service.dart';

class RapportSyntheseScreen extends StatefulWidget {
  static const String routeName = '/rapport_synthese';

  const RapportSyntheseScreen({super.key});

  @override
  State<RapportSyntheseScreen> createState() => _RapportSyntheseScreenState();
}

class _RapportSyntheseScreenState extends State<RapportSyntheseScreen> {
  final RapportService _rapportService = RapportService();
  final PdfService _pdfService = PdfService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tableau = [];
  Map<String, dynamic>? _fullData;
  Map<String, dynamic> _header = {};

  @override
  void initState() {
    super.initState();
    _chargerRapportSynthese();
  }

  Future<void> _chargerRapportSynthese() async {
    try {
      final data = await _rapportService.genererRapportSuivi();
      _fullData = data;
      _header = Map<String, dynamic>.from(data['header'] ?? {});
      final rows = (data['tableauSynthese'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          [];

      int totalSites = 0;
      int totalBenef = 0;
      int totalBlocs = 0;
      int totalCabines = 0;
      int totalRehabilitees = 0;

      _tableau = rows.map((row) {
        final Map<String, dynamic> safeRow = Map<String, dynamic>.from(row);
        final cible = (safeRow['cible'] as int?) ?? 0;
        final benef = (safeRow['benef'] as int?) ?? 0;
        final blocs = (safeRow['blocs'] as int?) ?? 0;
        final cabines = (safeRow['cabines'] as int?) ?? 0;
        final rehabilitees = (safeRow['rehabilitees'] as int?) ?? 0;

        totalSites += cible;
        totalBenef += benef;
        totalBlocs += blocs;
        totalCabines += cabines;
        totalRehabilitees += rehabilitees;

        return {
          'type': safeRow['type']?.toString() ?? 'Autre',
          'cible': cible,
          'benef': benef,
          'blocs': blocs,
          'cabines': cabines,
          'rehabilitees': rehabilitees,
        };
      }).toList();

      if (_tableau.isNotEmpty) {
        _tableau.add({
          'type': 'Total Global',
          'cible': totalSites,
          'benef': totalBenef,
          'blocs': totalBlocs,
          'cabines': totalCabines,
          'rehabilitees': totalRehabilitees,
          'isTotal': true,
        });
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading rapport synthese: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement de la synthèse: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rapport de Synthèse'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Rapport de Synthèse', style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter en PDF',
            onPressed: () => _pdfService.exporterRapportSynthese(_fullData!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('DONNÉES ADMINISTRATIVE', Icons.account_balance_outlined),
            const SizedBox(height: 12),
            _buildProjectHeader(_header),
            const SizedBox(height: 32),
            
            _buildSectionTitle('SYNTHÈSE PAR CATÉGORIE', Icons.table_chart_outlined),
            const SizedBox(height: 12),
            _buildDataTable(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade800, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.green.shade900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectHeader(Map<String, dynamic> header) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _headerField('Intitulé du projet', header['intituleProjet'], isBold: true),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(child: _headerField('Source Fin.', header['sourceFinancement'])),
                Expanded(child: _headerField('N° Marché', header['numeroMarche'])),
              ],
            ),
            const SizedBox(height: 12),
            _headerField('Entreprise', header['nomEntreprise'], icon: Icons.business),
          ],
        ),
      ),
    );
  }

  Widget _headerField(String label, dynamic value, {bool isBold = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.green.shade300),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                value?.toString() ?? '-',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: isBold ? Colors.green.shade900 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    if (_tableau.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('Aucune donnée de synthèse disponible.'),
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56,
          headingRowColor: WidgetStateProperty.all(Colors.green.shade50),
          columns: const [
            DataColumn(label: Text('Type de site', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
            DataColumn(label: Text('Nb sites', style: TextStyle(color: Colors.green))),
            DataColumn(label: Text('Bénéficiaires')),
            DataColumn(label: Text('Blocs')),
            DataColumn(label: Text('Cabines')),
            DataColumn(label: Text('Rénovées')),
          ],
          rows: _tableau.map((row) {
            final isTotal = row['isTotal'] == true;
            final style = TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
              color: isTotal ? Colors.green.shade900 : Colors.black87,
            );
            return DataRow(
              color: isTotal ? WidgetStateProperty.all(Colors.green.withOpacity(0.05)) : null,
              cells: [
                DataCell(Text(row['type'].toString(), style: style)),
                DataCell(Text(row['cible'].toString(), style: style)),
                DataCell(Text(row['benef'].toString(), style: style)),
                DataCell(Text(row['blocs'].toString(), style: style)),
                DataCell(Text(row['cabines'].toString(), style: style)),
                DataCell(Text(row['rehabilitees'].toString(), style: style)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
