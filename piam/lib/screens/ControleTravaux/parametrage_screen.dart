import 'package:flutter/material.dart';
import 'configurer_site_screen.dart';
import 'niveau1_donnees_generales.dart';
import 'rapports/dashboard_rapports.dart';

class ParametrageScreen extends StatelessWidget {
  static const String routeName = '/parametrage';

  const ParametrageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contrôle des travaux')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(DashboardRapportsScreen.routeName);
              },
              icon: const Icon(Icons.assessment_outlined),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(48),
              ),
              label: const Text('Consulter les Tableaux de Synthèse'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(Niveau1DonneesGenerales.routeName);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Accéder au Niveau 1'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/niveau2');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Accéder au Niveau 2'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/niveau3');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Accéder au Niveau 3'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/niveau4');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Accéder au Niveau 4'),
            ),
          ],
        ),
      ),
    );
  }
}
