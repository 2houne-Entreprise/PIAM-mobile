import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/parametrage_screen.dart';
import 'screens/niveau1_donnees_generales.dart';
import 'screens/configurer_site_screen.dart';
import 'screens/niveau2_organisation_chantier.dart';
import 'screens/niveau3_controle_travaux.dart';
import 'screens/niveau4_reception.dart';
import 'screens/rapports/dashboard_rapports.dart';
import 'screens/rapports/rapport_suivi_screen.dart';
import 'screens/rapports/rapport_synthese_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PiamApp());
}

class PiamApp extends StatelessWidget {
  const PiamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PIAM Contrôle Latrines Publiques',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade700),
          ),
          labelStyle: TextStyle(color: Colors.green[700]),
          errorStyle: const TextStyle(color: Colors.red),
          suffixIconColor: Colors.red,
        ),
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        ParametrageScreen.routeName: (context) => const ParametrageScreen(),
        ConfigurerSiteScreen.routeName: (context) =>
            const ConfigurerSiteScreen(),
        Niveau1DonneesGenerales.routeName: (context) =>
            const Niveau1DonneesGenerales(),
        Niveau2OrganisationChantier.routeName: (context) =>
            const Niveau2OrganisationChantier(),
        Niveau3ControleTravaux.routeName: (context) =>
            const Niveau3ControleTravaux(),
        Niveau4Reception.routeName: (context) => const Niveau4Reception(),
        DashboardRapportsScreen.routeName: (context) =>
            const DashboardRapportsScreen(),
        RapportSuiviScreen.routeName: (context) => const RapportSuiviScreen(),
        RapportSyntheseScreen.routeName: (context) =>
            const RapportSyntheseScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/niveau3' ||
            settings.name == '#/niveau3' ||
            settings.name == '/#/niveau3') {
          return MaterialPageRoute(
            builder: (context) => const Niveau3ControleTravaux(),
            settings: settings,
          );
        } else if (settings.name == '/niveau4' ||
            settings.name == '#/niveau4' ||
            settings.name == '/#/niveau4') {
          return MaterialPageRoute(
            builder: (context) => Niveau4Reception(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
