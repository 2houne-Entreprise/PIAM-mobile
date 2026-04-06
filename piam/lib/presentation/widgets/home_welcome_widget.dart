import 'package:flutter/material.dart';

class HomeWelcomeWidget extends StatelessWidget {
  const HomeWelcomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.home, size: 80, color: Colors.blueAccent),
          SizedBox(height: 16),
          Text(
            'Bienvenue sur PIAM',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Sélectionnez un onglet ci-dessous pour commencer.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
