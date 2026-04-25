import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/questionnaire_api_service.dart';
import 'package:piam/services/api_client.dart';
import 'dart:async';

/// Mixin pour ajouter la synchronisation automatique aux formulaires.
///
/// Usage dans un State de formulaire :
/// ```dart
/// class _MyFormState extends State<MyForm> with FormAutoSyncMixin {
///   Future<void> _save() async {
///     await saveAndSync(
///       type: 'declenchement',
///       localiteId: _localiteId,
///       dataMap: {'date_activite': _dateController.text},
///       userId: _userId,
///     );
///   }
/// }
/// ```
mixin FormAutoSyncMixin {
  final DatabaseService _dbService = DatabaseService();
  final QuestionnaireApiService _apiService = QuestionnaireApiService();
  Timer? _debounceTimer;

  /// Callback optionnel pour notifier l'UI après une sauvegarde.
  void Function(String status)? onSyncStatusChanged;

  Future<void> saveDraft({
    required String type,
    required int? localiteId,
    required Map<String, dynamic> dataMap,
    dynamic userId,
    String? niveau,
  }) async {
    try {
      Map<String, dynamic> finalData = Map<String, dynamic>.from(dataMap);

      if (niveau != null) {
        // Chargement du brouillon global depuis SQLite
        final existing = await _dbService.getQuestionnaire(type: type, localiteId: localiteId);
        final existingMap = existing != null ? Map<String, dynamic>.from(existing) : <String, dynamic>{};
        
        // Mise à jour uniquement du niveau actuel
        existingMap[niveau] = Map<String, dynamic>.from(dataMap);
        finalData = existingMap;
      }
      
      // Sauvegarde dans SQLite avec le statut 'draft'
      await _dbService.upsertQuestionnaire(
        type: type,
        localiteId: localiteId,
        dataMap: finalData,
        userId: userId,
        status: 'draft',
      );
      
      debugPrint('[FormAutoSync] Brouillon SQLite "$type" sauvegardé (status: draft)');
      onSyncStatusChanged?.call('draft');
    } catch (e) {
      debugPrint('[FormAutoSync] Erreur sauvegarde brouillon SQLite: $e');
    }
  }

  /// Helper pour sauvegarder automatiquement avec un délai (debounce).
  /// À appeler dans les onChanged des champs.
  void onFieldChanged({
    required String type,
    required int? localiteId,
    required Map<String, dynamic> Function() dataProvider,
    dynamic userId,
    String? niveau,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () async {
      await saveDraft(
        type: type,
        localiteId: localiteId,
        dataMap: dataProvider(),
        userId: userId,
        niveau: niveau,
      );
    });
  }

  /// Sauvegarde en local (SQLite) puis tente la sync API en arrière-plan.
  ///
  /// La sauvegarde locale est toujours prioritaire et ne dépend pas de l'API.
  /// La sync API est fire-and-forget (ne bloque pas l'UI).
  Future<void> saveAndSync({
    required String type,
    required int? localiteId,
    required Map<String, dynamic> dataMap,
    dynamic userId,
    String? niveau,
  }) async {
    Map<String, dynamic> finalData = Map<String, dynamic>.from(dataMap);

    // 1. Sauvegarde locale (statut complété) dans SQLite
    await _dbService.upsertQuestionnaire(
      type: type,
      localiteId: localiteId,
      dataMap: finalData,
      userId: userId,
      status: 'completed',
    );

    // 2. Tentative de sync API en arrière-plan
    _trySyncInBackground(type, localiteId);
  }

  /// Tente de synchroniser un questionnaire en arrière-plan.
  void _trySyncInBackground(String type, int? localiteId) async {
    try {
      // Vérifier la connexion
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity.any((s) => s != ConnectivityResult.none);
      if (!isOnline) return;

      // Vérifier le token
      final hasToken = await ApiClient().hasToken();
      if (!hasToken) return;

      // Récupérer le questionnaire fraîchement sauvegardé
      final questionnaire = await _getFullQuestionnaire(type, localiteId);
      if (questionnaire == null) return;

      // Envoyer à l'API
      final result = await _apiService.syncQuestionnaire(questionnaire);

      if (result != null) {
        // Marquer comme synchronisé
        final id = questionnaire['id'];
        if (id != null) {
          await _dbService.updateQuestionnaireSyncStatus(id as int, 'synced');
        }
        debugPrint('[FormAutoSync] "$type" synchronisé avec succès');
      }
    } catch (e) {
      // Fire-and-forget — on ignore les erreurs
      debugPrint('[FormAutoSync] Sync en arrière-plan échouée: $e');
    }
  }

  /// Récupère le questionnaire complet depuis SQLite pour envoi API.
  Future<Map<String, dynamic>?> _getFullQuestionnaire(
    String type,
    int? localiteId,
  ) async {
    final questionnaires = await _dbService.getQuestionnaires(type: type);
    
    for (final q in questionnaires) {
      if (q['localite_id'] == localiteId) {
        return q;
      }
    }
    return questionnaires.isNotEmpty ? questionnaires.first : null;
  }
}
