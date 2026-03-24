import 'package:flutter/material.dart';
import 'niveau1_donnees_generales.dart';

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
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF4CAF50)),
                title: const Text('Configurez le site'),
                subtitle: const Text(
                  'Wilaya → Moughataa → Commune → Localité (mock JSON)',
                ),
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
                subtitle: const Text('Filtrage et sélection rapide'),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(Niveau1DonneesGenerales.routeName);
              },
              child: const Text('Accéder aux Données Générales (Niveau 1)'),
            ),
          ],
        ),
      ),
    );
  }
}
