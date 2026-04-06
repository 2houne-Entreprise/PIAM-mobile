import 'package:equatable/equatable.dart';

/// Événements du BLoC Authentification
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Événement de connexion
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Événement de déconnexion
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Événement pour rafraîchir le token
class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

/// Événement pour vérifier la date/heure système
class VerifyDateTimeEvent extends AuthEvent {
  const VerifyDateTimeEvent();
}

/// Événement pour initialiser l'auth (check token existant)
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
