import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piam/data/datasources/remote/auth_repository.dart';
import 'package:piam/data/models/data_models.dart';
import 'package:piam/presentation/bloc/auth/auth_event.dart';
import 'package:piam/presentation/bloc/auth/auth_state.dart';
import 'package:piam/services/api_client.dart';
import 'package:logger/logger.dart';

/// BLoC pour la gestion de l'authentification.
///
/// Connecté à l'API Laravel via [AuthRepository].
/// Gère : login, logout, vérification de session, refresh token.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Logger _logger;
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc({required Logger logger})
    : _logger = logger,
      super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<VerifyDateTimeEvent>(_onVerifyDateTime);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RefreshTokenEvent>(_onRefreshToken);
  }

  /// Vérifier le statut d'authentification au lancement de l'app.
  ///
  /// Si un token existe en storage → vérifie avec GET /api/user
  /// Sinon → état non authentifié
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final hasToken = await _authRepository.hasToken();

      if (!hasToken) {
        emit(const AuthUnauthenticated());
        return;
      }

      // Vérifier le token avec l'API
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        final token = await ApiClient().getToken();
        final authToken = AuthToken(
          accessToken: token ?? '',
          refreshToken: '',
          expirationDate: DateTime.now().add(const Duration(hours: 24)),
        );
        _logger.i('Session restaurée: ${user.nom}');
        emit(AuthSuccess(token: authToken, utilisateur: user));
      } else {
        // Token invalide ou serveur inaccessible
        _logger.w('Token invalide ou serveur inaccessible');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      _logger.e('Erreur lors de la vérification du statut: $e');
      emit(const AuthUnauthenticated());
    }
  }

  /// Vérifier date/heure système
  Future<void> _onVerifyDateTime(
    VerifyDateTimeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(DateTimeVerifying());
    try {
      // Vérifier que l'heure est cohérente
      emit(state);
    } catch (e) {
      _logger.e('Erreur date/heure: $e');
      emit(DateTimeError('Date/Heure système incorrecte'));
    }
  }

  /// Connexion via l'API Laravel.
  ///
  /// Appelle POST /api/login → reçoit token Sanctum + user.
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthError('Email et mot de passe requis'));
        return;
      }

      _logger.i('Login tentative: ${event.email}');

      // Appel API réel via AuthRepository
      final result = await _authRepository.login(event.email, event.password);

      if (result.success && result.user != null && result.token != null) {
        _logger.i('Login réussi: ${result.user!.nom}');
        emit(AuthSuccess(token: result.token!, utilisateur: result.user!));
      } else {
        _logger.w('Login échoué: ${result.errorMessage}');
        emit(AuthError(result.errorMessage ?? 'Erreur de connexion'));
      }
    } catch (e) {
      _logger.e('Erreur login: $e');
      emit(AuthError('Erreur de connexion: ${e.toString()}'));
    }
  }

  /// Déconnexion : appelle POST /api/logout + supprime le token local.
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      _logger.i('Logout réussi');
      emit(const AuthLoggedOut());
      emit(const AuthUnauthenticated());
    } catch (e) {
      _logger.e('Erreur logout: $e');
      // Même en cas d'erreur, on déconnecte localement
      await ApiClient().clearToken();
      emit(const AuthUnauthenticated());
    }
  }

  /// Rafraîchir le token (pas de refresh dans Sanctum, re-login nécessaire).
  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Sanctum n'a pas de refresh token standard
      // On vérifie si le token actuel est encore valide
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        final token = await ApiClient().getToken();
        final authToken = AuthToken(
          accessToken: token ?? '',
          refreshToken: '',
          expirationDate: DateTime.now().add(const Duration(hours: 24)),
        );
        emit(AuthSuccess(token: authToken, utilisateur: user));
      } else {
        emit(const AuthError('Session expirée, reconnectez-vous'));
      }
    } catch (e) {
      _logger.e('Erreur refresh token: $e');
      emit(AuthError('Session expirée, reconnectez-vous'));
    }
  }
}
