import 'package:flutter/material.dart';
import 'rapport_suivi_screen.dart';
import 'rapport_synthese_screen.dart';

class DashboardRapportsScreen extends StatelessWidget {
  static const String routeName = '/rapports_dashboard';

  const DashboardRapportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableaux de Synthèse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Sélectionnez le type de rapport à générer :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue, size: 40),
                title: const Text('Rapport de Suivi'),
                subtitle: const Text('Avancement détaillé et suivi environnemental'),
                onTap: () {
                  Navigator.pushNamed(context, RapportSuiviScreen.routeName);
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.summarize, color: Colors.green, size: 40),
                title: const Text('Rapport de Synthèse'),
                subtitle: const Text('Vue globale des chantiers réceptionnés'),
                onTap: () {
                  Navigator.pushNamed(context, RapportSyntheseScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
