import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piam/config/app_constants.dart';
import 'package:piam/data/models/data_models.dart';
import 'package:piam/presentation/bloc/auth/auth_event.dart';
import 'package:piam/presentation/bloc/auth/auth_state.dart';
import 'package:logger/logger.dart';

/// BLoC pour la gestion de l'authentification
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Logger _logger;

  AuthBloc({required Logger logger})
    : _logger = logger,
      super(const AuthInitial()) {
    // Enregistrer les gestionnaires d'événements
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<VerifyDateTimeEvent>(_onVerifyDateTime);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
  }

  /// Gestionnaire: Vérifier le statut d'authentification
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implémenter la vérification du token existant
      // Si token existe → emit(AuthSuccess(...))
      // Sinon → emit(AuthUnauthenticated())

      emit(const AuthUnauthenticated());
    } catch (e) {
      _logger.e('Erreur lors de la vérification du statut: $e');
      emit(AuthError(e.toString()));
    }
  }

  /// Gestionnaire: Vérifier date/heure système
  Future<void> _onVerifyDateTime(
    VerifyDateTimeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(DateTimeVerifying());
    try {
      // Vérifier que l'heure est cohérente
      // (Ne pas avoir une date très différente du serveur)
      // TODO: Appeler serveur pour avoir heure serveur

      emit(state); // Retour à l'état précédent si OK
    } catch (e) {
      _logger.e('Erreur date/heure: $e');
      emit(DateTimeError('Date/Heure système incorrecte'));
    }
  }

  /// Gestionnaire: Connexion
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Step 1: Vérifier date/heure
      // TODO: Appeler serveur pour avoir heure serveur et comparer

      // Step 2: Créer les credentials
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthError('Email et mot de passe requis'));
        return;
      }

      // ⚠️ VERSION TEST — compte unique hardcodé (à remplacer par API)
      // TODO(prod): Remplacer par authRepository.login(email, password)
      _logger.i('Login tentative: ${event.email}');

      if (event.email.trim().toLowerCase() == AppConstants.testEmail &&
          event.password == AppConstants.testPassword) {
        final mockToken = AuthToken(
          accessToken: 'test-token-piam-2026',
          refreshToken: 'test-refresh-piam-2026',
          expirationDate: DateTime.now().add(const Duration(hours: 8)),
        );
        final mockUser = Utilisateur(
          id: 'usr-test-001',
          username: 'testeur',
          email: AppConstants.testEmail,
          nom: 'Test',
          prenom: 'Utilisateur',
          role: 'collecteur',
          localiteAssignee: '',
          dateCreation: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        _logger.i('Login test réussi: ${mockUser.fullName}');
        emit(AuthSuccess(token: mockToken, utilisateur: mockUser));
      } else {
        emit(const AuthError('Email ou mot de passe incorrect'));
      }
    } catch (e) {
      _logger.e('Erreur login: $e');
      emit(AuthError('Erreur de connexion: ${e.toString()}'));
    }
  }

  /// Gestionnaire: Déconnexion
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: Implémenter déconnexion
      // - Nettoyer tokensdu storage
      // - Logger serveur déconnexion

      emit(const AuthLoggedOut());
      emit(const AuthUnauthenticated());
    } catch (e) {
      _logger.e('Erreur logout: $e');
      emit(AuthError('Erreur lors de la déconnexion: ${e.toString()}'));
    }
  }

  /// Gestionnaire: Rafraîchir token
  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implémenter refresh token
      // - Récupérer ancien refresh token
      // - Appeler API refresh
      // - Sauvegarder nouveau access token

      emit(const AuthError('TODO: Implémenter refresh token'));
    } catch (e) {
      _logger.e('Erreur refresh token: $e');
      emit(AuthError('Session expirée, reconnectez-vous'));
    }
  }
}
