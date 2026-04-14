import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';

/// Client HTTP centralisé basé sur Dio.
///
/// Singleton qui gère :
/// - L'injection automatique du token d'auth dans chaque requête
/// - Le refresh/redirect si 401 reçu
/// - Le timeout et les headers par défaut
class ApiClient {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _initialized = false;

  // ── Initialisation ────────────────────────────────────────────────────────

  void init({String? baseUrl}) {
    if (_initialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Intercepteur d'authentification
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expiré ou invalide — on nettoie
          await clearToken();
          debugPrint('[ApiClient] 401 — Token invalide, nettoyé');
        }
        return handler.next(error);
      },
    ));

    // Intercepteur de logging en mode debug
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (msg) => debugPrint('[API] $msg'),
      ));
    }

    _initialized = true;
    debugPrint('[ApiClient] Initialisé avec baseUrl: ${_dio.options.baseUrl}');
  }

  // ── Accès Dio ─────────────────────────────────────────────────────────────

  Dio get dio {
    assert(_initialized, 'ApiClient.init() doit être appelé avant utilisation');
    return _dio;
  }

  // ── Gestion du token ──────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.authTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: AppConstants.authTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Raccourcis HTTP ───────────────────────────────────────────────────────

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return dio.delete(path);
  }
}
