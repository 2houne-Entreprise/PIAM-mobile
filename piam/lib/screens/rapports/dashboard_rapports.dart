import 'package:flutter/material.dart';
import 'rapport_suivi_screen.dart';
import 'rapport_synthese_screen.dart';

class DashboardRapportsScreen extends StatelessWidget {
  static const String routeName = '/rapports_dashboard';

  const DashboardRapportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tableaux de Synthèse', style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
        child: Column(
          children: [
            const Text(
              'Génération des rapports décisionnels',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez le type de rapport à consulter :',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            _buildReportCard(
              context,
              title: 'Rapport des CV (Suivi)',
              subtitle: 'Avancement détaillé et suivi environnemental',
              icon: Icons.analytics_outlined,
              color: Colors.blue.shade700,
              routeName: RapportSuiviScreen.routeName,
            ),
            const SizedBox(height: 20),
            _buildReportCard(
              context,
              title: 'Synthèse Globale',
              subtitle: 'Synthèse des chantiers par catégorie de site',
              icon: Icons.summarize_outlined,
              color: Colors.green.shade700,
              routeName: RapportSyntheseScreen.routeName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String routeName,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: () {
            Navigator.pushNamed(context, routeName);
          },
        ),
      ),
    );
  }
}
