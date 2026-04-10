import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class PdfService {
  /// Génère et affiche le Rapport de Suivi au format PDF
  Future<void> exporterRapportSuivi(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final header = data['header'] ?? {};
    final tableau = (data['tableauAvancement'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final pges = data['pges'] ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(header),
            pw.SizedBox(height: 20),
            _buildTitle('A. AVANCEMENT DES TRAVAUX'),
            _buildAvancementTable(tableau),
            pw.SizedBox(height: 20),
            _buildTitle('B. SUIVI DU PGES/MGP'),
            _buildPgesSection(pges),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildHeader(Map<String, dynamic> header) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('PROJET PIAM - RAPPORT DE SUIVI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.Divider(color: PdfColors.grey300),
          _headerRow('Intitulé', header['intituleProjet']),
          _headerRow('Marché n°', header['numeroMarche']),
          _headerRow('Entreprise', header['nomEntreprise']),
          _headerRow('Source Fin.', header['sourceFinancement']),
        ],
      ),
    );
  }

  pw.Widget _headerRow(String label, dynamic value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 100, child: pw.Text('$label :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          pw.Expanded(child: pw.Text(value?.toString() ?? '-', style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  pw.Widget _buildTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blue800)),
    );
  }

  pw.Widget _buildAvancementTable(List<Map<String, dynamic>> tableau) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headers: ['Nom du site', 'Ouvrage', 'Remise site', 'Avancement', 'Appréciation'],
      data: tableau.map((row) {
        return [
          row['nomSite'] ?? '-',
          '${row['nbBlocs'] ?? 0}b/${row['nbCabines'] ?? 0}c',
          row['dateRemiseSite'] ?? '-',
          '${(row['avancement'] as double?)?.toStringAsFixed(1) ?? '0.0'}%',
          row['appreciation'] ?? '-',
        ];
      }).toList(),
    );
  }

  pw.Widget _buildPgesSection(Map<String, dynamic> pges) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _pgesItem('Existence plan de gestion déchets', '${_toPct(pges['sitesPlanDechetsPct'])}%'),
        _pgesItem('Distance > 30m puits/robinet', '${_toPct(pges['sitesDistancePuitsPct'])}%'),
        _pgesItem('Taux port EPI observé', '${_toPct(pges['tauxEPIPct'])}%'),
        _pgesItem('Nb total accidents', pges['accidentsTotal']?.toString() ?? '0'),
        _pgesItem('Nb total plaintes', pges['plaintesNuisanceTotal']?.toString() ?? '0'),
      ],
    );
  }

  pw.Widget _pgesItem(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  /// Génère et affiche le Rapport de Synthèse au format PDF
  Future<void> exporterRapportSynthese(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final header = data['header'] ?? {};
    final tableau = (data['tableauSynthese'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(header),
            pw.SizedBox(height: 20),
            _buildTitle('RAPPORT DE SYNTHÈSE DES LATRINES PUBLIQUES'),
            _buildSyntheseTable(tableau),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildSyntheseTable(List<Map<String, dynamic>> tableau) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headers: ['Type de site', 'Nb sites', 'Bénéficiaires', 'Blocs', 'Cabines', 'Réhabilitées'],
      data: tableau.map((row) {
        return [
          row['type'] ?? '-',
          row['cible']?.toString() ?? '0',
          row['benef']?.toString() ?? '0',
          row['blocs']?.toString() ?? '0',
          row['cabines']?.toString() ?? '0',
          row['rehabilitees']?.toString() ?? '0',
        ];
      }).toList(),
    );
  }

  /// Génère et affiche la Fiche de Synthèse d'un site au format PDF
  Future<void> exporterFicheSynthese(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final ident = data['identification'] ?? {};
    final avancement = data['avancement'] ?? 0.0;
    final cumuls = data['cumuls'] ?? {};

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FICHE DE SYNTHÈSE INDIVIDUELLE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildTitle('IDENTIFICATION DU SITE'),
              _pgesItem('Intitulé du projet', ident['intituleProjet']?.toString() ?? '-'),
              _pgesItem('Type infrastructure', ident['typeSite']?.toString() ?? '-'),
              _pgesItem('Modèle latrine', ident['typeLatrines']?.toString() ?? '-'),
              _pgesItem('Nombre de cabines', ident['nbCabines']?.toString() ?? '0'),
              pw.SizedBox(height: 15),
              _buildTitle('AVANCEMENT & CUMULS'),
              _pgesItem('Taux d\'avancement', '${(avancement as double).toStringAsFixed(1)}%'),
              _pgesItem('Nb accidents cumulés', cumuls['accidents']?.toString() ?? '0'),
              _pgesItem('Nb plaintes nuisance cumulés', cumuls['plaintesNuisance']?.toString() ?? '0'),
              _pgesItem('Nb plaintes VBG cumulés', cumuls['plaintesVBG']?.toString() ?? '0'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  double _toPct(dynamic val) => double.tryParse(val?.toString() ?? '0') ?? 0.0;
}
