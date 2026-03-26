import 'package:flutter/material.dart';
import '../../services/rapport_service.dart';

class RapportSuiviScreen extends StatefulWidget {
  static const String routeName = '/rapport_suivi';

  const RapportSuiviScreen({super.key});

  @override
  State<RapportSuiviScreen> createState() => _RapportSuiviScreenState();
}

class _RapportSuiviScreenState extends State<RapportSuiviScreen> {
  final RapportService _rapportService = RapportService();
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _chargerRapport();
  }

  Future<void> _chargerRapport() async {
    final data = await _rapportService.genererRapportSuivi();
    setState(() {
      _reportData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rapport de Suivi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final rawTableau = _reportData?['tableauAvancement'];
    final tableau = (rawTableau is List)
        ? rawTableau.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Rapport de Suivi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A. Avancement des travaux',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.green.shade100),
                columns: const [
                  DataColumn(label: Text('Nom du site')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Ouvrage (Blocs/Cabines)')),
                  DataColumn(label: Text('Bénéf.')),
                  DataColumn(label: Text('Date remise site')),
                  DataColumn(label: Text('Dernier contrôle')),
                  DataColumn(label: Text('Avancement (%)')),
                  DataColumn(label: Text('Délai cons. (%)')),
                  DataColumn(label: Text('Retard (j)')),
                  DataColumn(label: Text('Réc Tech / Prov')),
                ],
                rows: tableau.map((row) {
                  final avancement =
                      (row['avancement'] as num?)?.toDouble() ?? 0.0;
                  final delaiConsommePct =
                      (row['delaiConsommePct'] as num?)?.toDouble() ?? 0.0;
                  final retardJours =
                      (row['retardJours'] as num?)?.toInt() ?? 0;

                  return DataRow(
                    cells: [
                      DataCell(Text(row['nomSite']?.toString() ?? '-')),
                      DataCell(Text(row['typeSite']?.toString() ?? '-')),
                      DataCell(
                        Text('${row['nbBlocs']} b. / ${row['nbCabines']} c.'),
                      ),
                      DataCell(Text(row['nbBeneficiaires']?.toString() ?? '0')),
                      DataCell(Text(row['dateRemiseSite']?.toString() ?? '-')),
                      DataCell(
                        Text(row['dateDernierControle']?.toString() ?? '-'),
                      ),
                      DataCell(
                        Text(
                          '${avancement.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: avancement >= 100
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${delaiConsommePct.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: delaiConsommePct > 100
                                ? Colors.red
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          retardJours.toString(),
                          style: TextStyle(
                            color: retardJours > 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Text('${row['dtRecepTech']} / ${row['dtRecepProv']}'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'B. Suivi du PGES/MGP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taux de sites avec Plan de gestion déchets : ${_reportData?['pges']['sitesPlanDechetsPct']}%',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Taux de sites avec tri des déchets : ${_reportData?['pges']['sitesTriDechetsPct']}%',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Taux de sites avec registre travailleurs à jour : ${_reportData?['pges']['sitesRegistreTravailleursPct']}%',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Taux de port EPI observé : ${_reportData?['pges']['tauxEpiPct']}%',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nombre total d\'accidents enregistrés : ${_reportData?['pges']['accidentsTotal']}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nombre total de plaintes (nuisance + VBG) : ${_reportData?['pges']['plaintesTotal']}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
