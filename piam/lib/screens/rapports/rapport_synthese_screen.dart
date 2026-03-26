import 'package:flutter/material.dart';
import '../../services/rapport_service.dart';

class RapportSyntheseScreen extends StatefulWidget {
  static const String routeName = '/rapport_synthese';

  const RapportSyntheseScreen({super.key});

  @override
  State<RapportSyntheseScreen> createState() => _RapportSyntheseScreenState();
}

class _RapportSyntheseScreenState extends State<RapportSyntheseScreen> {
  final RapportService _rapportService = RapportService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tableau = [];

  @override
  void initState() {
    super.initState();
    _chargerRapportSynthese();
  }

  Future<void> _chargerRapportSynthese() async {
    final data = await _rapportService.genererRapportSuivi();
    final rows =
        (data['tableauSynthese'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    int totalSites = 0;
    int totalBenef = 0;
    int totalBlocs = 0;
    int totalCabines = 0;
    _tableau = rows.map((row) {
      final cible = (row['cible'] as int?) ?? 0;
      final benef = (row['benef'] as int?) ?? 0;
      final blocs = (row['blocs'] as int?) ?? 0;
      final cabines = (row['cabines'] as int?) ?? 0;
      totalSites += cible;
      totalBenef += benef;
      totalBlocs += blocs;
      totalCabines += cabines;
      return {
        'type': row['type']?.toString() ?? 'Autre',
        'cible': cible,
        'benef': benef,
        'blocs': blocs,
        'cabines': cabines,
      };
    }).toList();

    _tableau.add({
      'type': 'Total',
      'cible': totalSites,
      'benef': totalBenef,
      'blocs': totalBlocs,
      'cabines': totalCabines,
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rapport de Synthèse')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rapport de Synthèse')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'RAPPORT DE SYNTHESE DES LATRINES PUBLIQUES RECEPTIONNEES',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Type de site',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(label: Text('Nb sites ciblés')),
                  DataColumn(label: Text('Nb bénéficiaires')),
                  DataColumn(label: Text('Nb blocs réalisés')),
                  DataColumn(label: Text('Nb cabines réalisées')),
                ],
                rows: _tableau.map((row) {
                  final isTotal = row['type'] == 'Total';
                  return DataRow(
                    color: isTotal
                        ? WidgetStateProperty.all(Colors.grey.shade200)
                        : null,
                    cells: [
                      DataCell(
                        Text(
                          row['type'].toString(),
                          style: TextStyle(
                            fontWeight: isTotal
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      DataCell(Text(row['cible'].toString())),
                      DataCell(Text(row['benef'].toString())),
                      DataCell(Text(row['blocs'].toString())),
                      DataCell(Text(row['cabines'].toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
