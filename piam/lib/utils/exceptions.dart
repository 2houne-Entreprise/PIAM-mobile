/// Exceptions personnalisées de l'application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

/// Exception réseau
class NetworkException extends AppException {
  NetworkException({required String message, String? code})
    : super(message: message, code: code);
}

/// Exception authentification
class AuthException extends AppException {
  AuthException({required String message, String? code})
    : super(message: message, code: code);
}

/// Exception validation
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException({required String message, this.errors, String? code})
    : super(message: message, code: code);
}

/// Exception base de données
class DatabaseException extends AppException {
  DatabaseException({required String message, String? code})
    : super(message: message, code: code);
}

/// Exception synchronisation
class SyncException extends AppException {
  SyncException({required String message, String? code})
    : super(message: message, code: code);
}

/// Exception générique
class GeneralException extends AppException {
  GeneralException({required String message, String? code})
    : super(message: message, code: code);
}
