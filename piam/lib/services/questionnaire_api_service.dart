import 'dart:convert';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'api_client.dart';

/// Service API pour les questionnaires.
///
/// Gère la communication avec l'API Laravel pour :
/// - Envoyer un questionnaire (sync individuel ou batch)
/// - Récupérer les questionnaires depuis le serveur
/// - Récupérer les stats du dashboard
class QuestionnaireApiService {
  final ApiClient _api = ApiClient();

  // ── Envoi individuel ──────────────────────────────────────────────────────

  /// Envoie un questionnaire à l'API (POST /api/questionnaires).
  ///
  /// [questionnaire] doit contenir les clés : type, data_json, localite_id, etc.
  /// Retourne la réponse du serveur ou null en cas d'erreur.
  Future<Map<String, dynamic>?> syncQuestionnaire(
    Map<String, dynamic> questionnaire,
  ) async {
    try {
      // 1. Préparer les données de base
      final Map<String, dynamic> payload = _preparePayload(questionnaire);
      
      dynamic data;
      final String? localPhotoPath = questionnaire['photo_path'];

      // 2. Si on a un chemin de photo local, on utilise FormData pour envoyer le fichier
      if (localPhotoPath != null && 
          localPhotoPath.isNotEmpty && 
          !localPhotoPath.startsWith('http')) {
        
        final Map<String, dynamic> formDataMap = Map.from(payload);
        
        // Ajouter le fichier image
        if (kIsWeb) {
           // Correction: Sur web avec ImagePicker, on peut utiliser MultipartFile.fromFile avec le path
           formDataMap['photo'] = await MultipartFile.fromFile(
             localPhotoPath,
             filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
           );
        } else {
          if (await File(localPhotoPath).exists()) {
            formDataMap['photo'] = await MultipartFile.fromFile(
              localPhotoPath,
              filename: path.basename(localPhotoPath),
            );
          }
        }
        data = FormData.fromMap(formDataMap);
      } else {
        data = payload;
      }

      final response = await _api.post(
        '/questionnaires',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('[QuestionnaireApiService] syncQuestionnaire error: ${e.message}');
      return null;
    }
  }

  // ── Envoi en batch ────────────────────────────────────────────────────────

  /// Envoie plusieurs questionnaires d'un coup (POST /api/questionnaires/sync-batch).
  ///
  /// Retourne la liste des questionnaires synchronisés ou une liste vide.
  Future<List<Map<String, dynamic>>> syncBatch(
    List<Map<String, dynamic>> questionnaires,
  ) async {
    if (questionnaires.isEmpty) return [];

    try {
      final payloads = questionnaires.map(_preparePayload).toList();

      final response = await _api.post(
        '/questionnaires/sync-batch',
        data: {'questionnaires': payloads},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>?;
        return data?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[QuestionnaireApiService] syncBatch error: ${e.message}');
      return [];
    }
  }

  // ── Récupération ──────────────────────────────────────────────────────────

  /// Récupère les questionnaires depuis l'API.
  ///
  /// Filtres optionnels : [type], [localiteId]
  Future<List<Map<String, dynamic>>> fetchQuestionnaires({
    String? type,
    int? localiteId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (localiteId != null) queryParams['localite_id'] = localiteId;

      final response = await _api.get(
        '/questionnaires',
        queryParams: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[QuestionnaireApiService] fetchQuestionnaires error: ${e.message}');
      return [];
    }
  }

  /// Récupère un questionnaire spécifique.
  Future<Map<String, dynamic>?> fetchQuestionnaire(int id) async {
    try {
      final response = await _api.get('/questionnaires/$id');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('[QuestionnaireApiService] fetchQuestionnaire error: ${e.message}');
      return null;
    }
  }

  // ── Dashboard Stats ───────────────────────────────────────────────────────

  /// Récupère les statistiques du dashboard depuis l'API.
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _api.get('/dashboard-stats');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('[QuestionnaireApiService] getDashboardStats error: ${e.message}');
      return null;
    }
  }

  // ── Rapports ───────────────────────────────────────────────────────────────
  
  /// Récupère le rapport de suivi pour une localité spécifique (Source MySQL).
  Future<Map<String, dynamic>?> fetchReportSuivi(int localiteId) async {
    try {
      final response = await _api.get('/reports/suivi/$localiteId');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('[QuestionnaireApiService] fetchReportSuivi error: ${e.message}');
      return null;
    }
  }

  /// Récupère les données de synthèse globale (Source MySQL).
  Future<Map<String, dynamic>?> fetchReportSynthese() async {
    try {
      final response = await _api.get('/reports/synthese');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('[QuestionnaireApiService] fetchReportSynthese error: ${e.message}');
      return null;
    }
  }

  // ── Utilitaires ───────────────────────────────────────────────────────────

  /// Prépare un questionnaire SQLite pour envoi à l'API.
  Map<String, dynamic> _preparePayload(Map<String, dynamic> questionnaire) {
    // data_json : s'assurer que c'est bien un objet JSON (pas une string)
    var dataJson = questionnaire['data_json'];
    if (dataJson is String) {
      try {
        dataJson = jsonDecode(dataJson);
      } catch (_) {
        // Garder comme string si pas parseable
      }
    }

    return {
      'type': questionnaire['type'],
      'data_json': dataJson,
      'localite_id': questionnaire['localite_id'],
      'photo_path': questionnaire['photo_path'],
    };
  }
}
