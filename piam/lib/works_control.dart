import 'package:flutter/material.dart';
import 'work_detail_screen.dart';

class WorksControlScreen extends StatelessWidget {
  const WorksControlScreen({super.key});

  final List<String> workSections = const [
    'Installation du chantier',
    'Implantation et terrassement',
    'Béton en fondation et maçonnerie en fondation',
    'Béton et maçonnerie en élévation',
    'Dalles de plancher (toit)',
    'Enduits',
    'Menuiserie',
    'Plomberie',
    'Peinture',
    'Revêtement',
    'Dispositif de lave-mains (DLM)',
    'Garde-fou',
    'Suivi du PGES',
    'Mécanisme de réclamation',
    'Évaluation de la progression',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏗️ Contrôle des travaux')),
      body: ListView.builder(
        itemCount: workSections.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('${index + 1}'),
              ),
              title: Text(workSections[index]),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkDetailScreen(section: workSections[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
