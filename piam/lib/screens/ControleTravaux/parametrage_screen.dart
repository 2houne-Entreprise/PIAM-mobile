import 'package:flutter/material.dart';
import 'configurer_site_screen.dart';
import 'niveau1_donnees_generales.dart';
import 'rapports/dashboard_rapports.dart';

class ParametrageScreen extends StatefulWidget {
  static const String routeName = '/parametrage';

  const ParametrageScreen({super.key});

  @override
  State<ParametrageScreen> createState() => _ParametrageScreenState();
}

class _ParametrageScreenState extends State<ParametrageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramétrage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Centre de configuration PIAM',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Préparez les données initiales et accédez aux rapports',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF4CAF50)),
                title: const Text('Configurez le site'),
                subtitle: const Text('Wilaya → Moughataa → Commune → Localité'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ConfigurerSiteScreen.routeName),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.business, color: Color(0xFF4CAF50)),
                title: const Text('Sélection projet + entreprise'),
                subtitle: const Text('Accès direct aux rapports et tableaux'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(DashboardRapportsScreen.routeName),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(Niveau1DonneesGenerales.routeName);
              },
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Accéder aux Données Générales (Niveau 1)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(DashboardRapportsScreen.routeName);
              },
              icon: const Icon(Icons.assessment_outlined),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              label: const Text('Consulter les Tableaux de Synthèse'),
            ),
          ],
        ),
      ),
    );
  }
}
