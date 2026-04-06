import 'package:piam/presentation/pages/home_page.dart';
import 'package:piam/presentation/pages/formulaires/etat_lieux_localite_page.dart';
import 'package:piam/presentation/pages/formulaires/etat_lieux_menage_page.dart';
import 'package:piam/presentation/pages/formulaires/dernier_suivi_localite_page.dart';
import 'package:piam/presentation/pages/formulaires/dernier_suivi_menage_page.dart';
import 'package:piam/presentation/pages/formulaires/inventaire_page.dart';

import 'package:piam/presentation/pages/formulaires/travaux_receptionnes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:piam/bootstrap.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/data/models/data_models.dart';
import 'package:piam/presentation/bloc/auth/auth_bloc.dart';
import 'package:piam/presentation/bloc/auth/auth_event.dart';
import 'package:piam/presentation/bloc/auth/auth_state.dart';
import 'package:piam/presentation/bloc/formulaire/formulaire_bloc.dart';
import 'package:piam/presentation/pages/auth/login_page.dart';
import 'package:piam/presentation/pages/dashboard/dashboard_page.dart';
import 'package:piam/presentation/pages/formulaires/calendrier_page.dart';
import 'package:piam/presentation/pages/formulaires/cloture_page.dart';
import 'package:piam/presentation/pages/formulaires/conformite_page.dart';
import 'package:piam/presentation/pages/formulaires/deelechement_page.dart';
import 'package:piam/presentation/pages/formulaires/equipes_page.dart';
import 'package:piam/presentation/pages/formulaires/identification_page.dart';
import 'package:piam/presentation/pages/formulaires/organisation_page.dart';
import 'package:piam/presentation/pages/formulaires/rapports_page.dart';
import 'package:piam/presentation/pages/formulaires/sites_page.dart';
import 'screens/parametrage_initial_screen.dart';
import 'screens/ControleTravaux/parametrage_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              getIt<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<FormulaireBloc>(
          create: (context) => getIt<FormulaireBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'PIAM',
        theme: AppTheme.lightTheme(),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              // Redirige vers la nouvelle page d'accueil avec menu bas
              return HomePage(
                user: state.utilisateur,
                localite: Localite.empty(),
              );
            }
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const LoginPage();
          },
        ),
        onGenerateRoute: (settings) {
          WidgetBuilder builder;

          switch (settings.name) {
            case '/parametrage':
              builder = (context) => const ParametrageInitialScreen();
              break;
            case '/certification_fdal':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => ConformitePage(formulaireId: id);
              break;
            case '/formulaires/etat_lieux_localite':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => EtatLieuxLocalitePage(formulaireId: id);
              break;
            case '/formulaires/etat_lieux_menage':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => EtatLieuxMenagePage(formulaireId: id);
              break;
            case '/formulaires/dernier_suivi_localite':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => DernierSuiviLocalitePage(formulaireId: id);
              break;
            case '/formulaires/dernier_suivi_menage':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => DernierSuiviMenagePage(formulaireId: id);
              break;
            case '/formulaires/inventaire':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => InventairePage(formulaireId: id);
              break;
            case '/formulaires/programmation_travaux':
              builder = (context) => const ParametrageScreen();
              break;
            case '/formulaires/travaux_receptionnes':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => TravauxReceptionnesPage(formulaireId: id);
              break;
            case '/dashboard':
              // Normally handled by HomePage
              builder = (context) => Scaffold(body: Center(child: Text('Dashboard')));
              break;
            case '/formulaires/declenchement':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => DeeclenchementPage(formulaireId: id);
              break;
            case '/formulaires/identification':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => IdentificationPage(formulaireId: id);
              break;
            case '/formulaires/organisation':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => OrganisationPage(formulaireId: id);
              break;
            case '/formulaires/sites':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => SitesPage(formulaireId: id);
              break;
            case '/formulaires/equipes':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => EquipesPage(formulaireId: id);
              break;
            case '/formulaires/calendrier':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => CalendrierPage(formulaireId: id);
              break;
            case '/formulaires/rapports':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => RapportsPage(formulaireId: id);
              break;
            case '/formulaires/cloture':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => CloturePage(formulaireId: id);
              break;
            case '/formulaires/conformite':
              final id = settings.arguments as String? ?? 'new';
              builder = (context) => ConformitePage(formulaireId: id);
              break;
            default:
              builder = (context) => Scaffold(body: Center(child: Text('Route introuvable')));
          }

          return MaterialPageRoute<dynamic>(
            builder: builder,
            settings: settings,
          );
        },
      ),
    );
  }
}
