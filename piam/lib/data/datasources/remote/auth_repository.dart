import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:piam/services/api_client.dart';
import 'package:piam/data/models/data_models.dart';

/// Repository d'authentification.
///
/// Gère la communication avec l'API Laravel pour :
/// - Login (email + password) → token Sanctum
/// - Logout → révocation du token
/// - Récupération du profil utilisateur
/// - Persistance du token via ApiClient / SecureStorage
class AuthRepository {
  final ApiClient _api = ApiClient();

  /// Login : appelle POST /api/login et retourne un [AuthResult].
  ///
  /// En cas de succès, le token est automatiquement sauvegardé.
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _api.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        // Sauvegarder le token
        await _api.saveToken(token);

        // Construire l'utilisateur
        final user = Utilisateur(
          id: userData['id'].toString(),
          username: userData['name'] ?? '',
          email: userData['email'] ?? '',
          nom: userData['name'] ?? '',
          prenom: '',
          role: userData['role'] ?? 'collecteur',
          localiteAssignee: '',
          dateCreation: userData['created_at'] != null
              ? DateTime.tryParse(userData['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          lastLogin: DateTime.now(),
        );

        final authToken = AuthToken(
          accessToken: token,
          refreshToken: '',
          expirationDate: DateTime.now().add(const Duration(hours: 24)),
        );

        return AuthResult(
          success: true,
          user: user,
          token: authToken,
        );
      }

      return AuthResult(
        success: false,
        errorMessage: 'Réponse inattendue du serveur',
      );
    } on DioException catch (e) {
      debugPrint('[AuthRepository] Login error: ${e.message}');

      if (e.response?.statusCode == 401) {
        return AuthResult(
          success: false,
          errorMessage: 'Email ou mot de passe incorrect',
        );
      }
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] ?? {};
        final message = errors.values.expand((v) => v).join('\n');
        return AuthResult(
          success: false,
          errorMessage: message.isNotEmpty ? message : 'Données invalides',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return AuthResult(
          success: false,
          errorMessage: 'Impossible de se connecter au serveur. Vérifiez votre connexion.',
        );
      }

      return AuthResult(
        success: false,
        errorMessage: 'Erreur réseau: ${e.message}',
      );
    } catch (e) {
      debugPrint('[AuthRepository] Unexpected error: $e');
      return AuthResult(
        success: false,
        errorMessage: 'Erreur inattendue: $e',
      );
    }
  }

  /// Logout : appelle POST /api/logout et supprime le token local.
  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (_) {
      // Même si l'API échoue, on supprime le token local
    } finally {
      await _api.clearToken();
    }
  }

  /// Récupère l'utilisateur connecté via GET /api/user.
  ///
  /// Retourne null si le token est invalide ou absent.
  Future<Utilisateur?> getCurrentUser() async {
    try {
      final hasToken = await _api.hasToken();
      if (!hasToken) return null;

      final response = await _api.get('/user');

      if (response.statusCode == 200) {
        final data = response.data;
        return Utilisateur(
          id: data['id'].toString(),
          username: data['name'] ?? '',
          email: data['email'] ?? '',
          nom: data['name'] ?? '',
          prenom: '',
          role: data['role'] ?? 'collecteur',
          localiteAssignee: '',
          dateCreation: data['created_at'] != null
              ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          lastLogin: DateTime.now(),
        );
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _api.clearToken();
      }
      return null;
    }
  }

  /// Vérifie si un token est enregistré localement.
  Future<bool> hasToken() => _api.hasToken();
}

/// Résultat d'une tentative d'authentification.
class AuthResult {
  final bool success;
  final Utilisateur? user;
  final AuthToken? token;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.token,
    this.errorMessage,
  });
}
