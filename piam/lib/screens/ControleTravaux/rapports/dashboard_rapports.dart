// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:piam/services/database_service.dart';

class DashboardRapportsScreen extends StatefulWidget {
  static const String routeName = '/dashboard_rapports';

  const DashboardRapportsScreen({super.key});

  @override
  State<DashboardRapportsScreen> createState() =>
      _DashboardRapportsScreenState();
}

class _DashboardRapportsScreenState extends State<DashboardRapportsScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic> _reportData = {};
  String? _selectedWilaya;
  List<String> _wilayasList = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      // Récupérer tous les questionnaires pour générer les stats
      final db = await _dbService.database;
      final List<Map<String, dynamic>> questionnaires = await db.query(
        'questionnaires',
      );
      // Exemple de stats : nombre de formulaires par type
      final Map<String, int> stats = {};
      for (final q in questionnaires) {
        final type = q['type'] as String? ?? 'inconnu';
        stats[type] = (stats[type] ?? 0) + 1;
      }
      setState(() {
        _reportData = {
          'stats': stats,
          'totalProjects': stats.values.fold(0, (a, b) => a + b),
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading report data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final stats = _reportData['stats'] as Map<String, int>? ?? {};
    final totalProjects = _reportData['totalProjects'] as int? ?? 0;
    final regional =
        _reportData['regional'] as List<Map<String, dynamic>>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableaux de Synthèse'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReportData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFilteringSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('État Global des Projets'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Projets',
                    totalProjects.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Validées',
                    stats['validée']?.toString() ?? '0',
                    Icons.verified,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Complètes',
                    stats['complète']?.toString() ?? '0',
                    Icons.done_all,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Brouillons',
                    stats['brouillon']?.toString() ?? '0',
                    Icons.edit_note,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Répartition par Wilaya'),
            const SizedBox(height: 12),
            if (regional.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Aucune donnée régionale disponible.'),
                ),
              )
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: regional.map((row) {
                      final name = row['wilaya']?.toString() ?? 'Inconnue';
                      final count = row['count'] as int? ?? 0;
                      final percent = totalProjects > 0
                          ? count / totalProjects
                          : 0.0;
                      return _buildRegionalRow(name, count, percent);
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildSectionHeader('Progression Relative'),
            const SizedBox(height: 12),
            _buildProgressCard(stats, totalProjects),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Filtres'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Filtrer par Wilaya',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          value: _selectedWilaya,
          hint: const Text('Toutes les Wilayas'),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Toutes les Wilayas'),
            ),
            ..._wilayasList.map(
              (w) => DropdownMenuItem(value: w, child: Text(w)),
            ),
          ],
          onChanged: (val) {
            setState(() {
              _selectedWilaya = val;
            });
            _loadReportData();
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalRow(String name, int count, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '$count projet(s)',
                style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade200,
              color: Colors.green.shade400,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Map<String, int> stats, int total) {
    // Total forms expected = projects * 10
    final totalExpected = total * 10;
    final totalDone = (stats['complète'] ?? 0) + (stats['validée'] ?? 0);
    final globalPercent = totalExpected > 0 ? totalDone / totalExpected : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: globalPercent,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade100,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Taux de Complétude Global',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(globalPercent * 100).toStringAsFixed(1)}% des formulaires remplis',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
