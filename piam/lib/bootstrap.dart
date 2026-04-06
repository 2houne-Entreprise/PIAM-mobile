import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:piam/presentation/bloc/auth/auth_bloc.dart';
import 'package:piam/presentation/bloc/formulaire/formulaire_bloc.dart';

/// Service de logging
final logger = Logger();

/// Initialise les dépendances de l'application
Future<void> bootstrap() async {
  final getIt = GetIt.instance;

  // Logger
  getIt.registerSingleton<Logger>(logger);

  // BLoCs
  getIt.registerSingleton<AuthBloc>(AuthBloc(logger: logger));
  getIt.registerSingleton<FormulaireBloc>(FormulaireBloc(logger: logger));

  // À continuer dans les prochaines phases...
  // Services
  // Repositories
  // UseCases
}
