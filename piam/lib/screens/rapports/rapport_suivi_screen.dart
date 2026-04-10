import 'package:flutter/material.dart';
import '../../services/rapport_service.dart';
import '../../services/pdf_service.dart';
import 'fiche_synthese_site_screen.dart';

class RapportSuiviScreen extends StatefulWidget {
  static const String routeName = '/rapport_suivi';

  const RapportSuiviScreen({super.key});

  @override
  State<RapportSuiviScreen> createState() => _RapportSuiviScreenState();
}

class _RapportSuiviScreenState extends State<RapportSuiviScreen> {
  final RapportService _rapportService = RapportService();
  final PdfService _pdfService = PdfService();
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _chargerRapport();
  }

  Future<void> _chargerRapport() async {
    try {
      final data = await _rapportService.genererRapportSuivi();
      if (mounted) {
        setState(() {
          _reportData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading rapport suivi: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des données: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rapport de Suivi (CV)'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final header = Map<String, dynamic>.from(_reportData?['header'] ?? {});
    final rawTableau = _reportData?['tableauAvancement'];
    final List<Map<String, dynamic>> tableau = (rawTableau is List)
        ? rawTableau.map((e) => Map<String, dynamic>.from(e)).toList()
        : [];
    final pges = Map<String, dynamic>.from(_reportData?['pges'] ?? {});

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Rapport de Suivi (CV)', style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter en PDF',
            onPressed: () => _pdfService.exporterRapportSuivi(_reportData!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('INFORMATIONS GÉNÉRALES', Icons.info_outline, Colors.indigo),
            const SizedBox(height: 12),
            _buildProjectHeader(header),
            const SizedBox(height: 32),

            _buildSectionHeader('A. AVANCEMENT DES TRAVAUX (CV)', Icons.analytics_outlined, Colors.blue.shade800),
            const SizedBox(height: 12),
            _buildAvancementTable(tableau),
            const SizedBox(height: 32),

            _buildSectionHeader('B. SUIVI DU PGES / MGP', Icons.eco_outlined, Colors.green.shade800),
            const SizedBox(height: 12),
            _buildPgesSection(pges),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: color.withOpacity(0.2))),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _headerRow('Projet', header['intituleProjet'], isTitle: true),
            const Divider(height: 24),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _headerRow('Marché n°', header['numeroMarche'])),
                  VerticalDivider(color: Colors.grey.shade200),
                  Expanded(child: _headerRow('Financement', header['sourceFinancement'])),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _headerRow('Entreprise', header['nomEntreprise'], icon: Icons.business),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _headerRow('Délai', '${header['delaiMarche']} mois', icon: Icons.timer_outlined),
                ),
                Expanded(
                  child: _headerRow('Démarrage', header['dateDemarrage'], icon: Icons.calendar_today_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerRow(String label, dynamic value, {bool isTitle = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value?.toString() ?? '-',
          style: TextStyle(
            fontSize: isTitle ? 16 : 13,
            fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
            color: isTitle ? Colors.indigo.shade900 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAvancementTable(List<Map<String, dynamic>> tableau) {
    if (tableau.isEmpty) {
      return _buildEmptyState('Aucune donnée d\'avancement disponible.');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
            fontSize: 13,
          ),
          headingRowColor: WidgetStateProperty.all(Colors.indigo.withOpacity(0.03)),
          columns: const [
            DataColumn(label: Text('Site')),
            DataColumn(label: Text('Progression')),
            DataColumn(label: Text('Ouvrage')),
            DataColumn(label: Text('Réception')),
          ],
          rows: tableau.map((row) {
            final avancement = _toDouble(row['avancement']);
            final localiteId = row['localiteId'] as int?;
            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true && localiteId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FicheSyntheseSiteScreen(localiteId: localiteId),
                    ),
                  );
                }
              },
              cells: [
                DataCell(
                  Text(
                    row['nomSite']?.toString() ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  _buildProgressIndicator(avancement),
                ),
                DataCell(
                  Text(
                    '${row['nbBlocs'] ?? 0}b / ${row['nbCabines'] ?? 0}c',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    row['dtRecepProv']?.toString() ?? '-',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double pct) {
    final color = _getProgressColor(pct);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPgesSection(Map<String, dynamic> pges) {
    return Column(
      children: [
        _buildPgesCard('Phase Préparatoire', [
          _pgesItem('Plan de gestion des déchets', pges['sitesPlanDechetsPct'], isPct: true),
          _pgesItem('Distance sources d\'eau', pges['sitesDistancePuitsPct'], isPct: true),
          _pgesItem('Sensibilisation ouvriers', pges['sitesSensibilisationPct'], isPct: true),
        ], Colors.blue),
        const SizedBox(height: 16),
        _buildPgesCard('Phase d\'Exécution', [
          _pgesItem('Respect du périmètre sécurité', pges['sitesPerimetreSecuritePct'], isPct: true),
          _pgesItem('Disponibilité eau potable', pges['sitesEauPotablePct'], isPct: true),
          _pgesItem('Port des EPI (%)', pges['tauxEPIPct'], isPct: true),
          _pgesItem('Total accidents', pges['accidentsTotal'], color: Colors.red),
          _pgesItem('Plaintes nuisance', pges['plaintesNuisanceTotal'], color: Colors.orange),
        ], Colors.green),
      ],
    );
  }

  Widget _buildPgesCard(String title, List<Widget> items, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _pgesItem(String label, dynamic value, {bool isPct = false, Color? color}) {
    final displayValue = isPct ? '${_toDouble(value).toStringAsFixed(1)}%' : (value?.toString() ?? '0');
    final valNum = _toDouble(value);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? (isPct ? _getScoreColor(valNum) : Colors.grey)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              displayValue,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color ?? (isPct ? _getScoreColor(valNum) : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _toDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val?.toString() ?? '0') ?? 0.0;
  }

  Color _getProgressColor(double pct) {
    if (pct >= 100) return Colors.green.shade600;
    if (pct >= 50) return Colors.blue.shade600;
    if (pct >= 25) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getScoreColor(double val) {
    if (val >= 80) return Colors.green.shade700;
    if (val >= 50) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}
