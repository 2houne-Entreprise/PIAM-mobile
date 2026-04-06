import 'package:equatable/equatable.dart';
import 'package:piam/data/models/data_models.dart';

/// États du BLoC Authentification
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// État de chargement
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// État de vérification date/heure
class DateTimeVerifying extends AuthState {
  const DateTimeVerifying();
}

/// Erreur date/heure
class DateTimeError extends AuthState {
  final String message;

  const DateTimeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// État connecté (authentifié)
class AuthSuccess extends AuthState {
  final AuthToken token;
  final Utilisateur utilisateur;

  const AuthSuccess({required this.token, required this.utilisateur});

  @override
  List<Object?> get props => [token, utilisateur];
}

/// État déconnecté
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

/// État d'erreur
class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// État non authentifié (aucun token)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
