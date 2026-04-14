import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'questionnaire_api_service.dart';
import 'api_client.dart';

/// Service de synchronisation offline/online.
///
/// Fonctionnement :
/// 1. Écoute les changements de connectivité
/// 2. Quand online → récupère les questionnaires locaux non synchronisés
/// 3. Les envoie en batch à l'API Laravel
/// 4. Met à jour le sync_status à 'synced' après succès
///
/// Ce service remplace l'ancien FormSyncService + SyncManager + SyncService.
class SyncService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();
  final DatabaseService _db = DatabaseService();
  final QuestionnaireApiService _apiService = QuestionnaireApiService();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;
  bool _initialized = false;

  // Callbacks pour notifier l'UI
  final List<VoidCallback> _listeners = [];

  // ── État ───────────────────────────────────────────────────────────────────

  bool get isSyncing => _isSyncing;
  bool get isInitialized => _initialized;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Démarre l'écoute de la connectivité et tente une sync initiale.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Écouter les changements réseau
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> statusList) async {
        final isOnline = statusList.any(
          (status) => status != ConnectivityResult.none,
        );
        if (isOnline) {
          debugPrint('[SyncService] Connexion détectée → sync en cours...');
          await syncAll();
        }
      },
    );

    // Sync initiale si online
    if (await _isOnline()) {
      await syncAll();
    }

    debugPrint('[SyncService] Initialisé');
  }

  /// Arrête l'écoute.
  void dispose() {
    _subscription?.cancel();
    _listeners.clear();
    _initialized = false;
  }

  // ── Listeners ─────────────────────────────────────────────────────────────

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // ── Synchronisation ───────────────────────────────────────────────────────

  /// Synchronise tous les questionnaires locaux non synchronisés avec l'API.
  Future<SyncResult> syncAll() async {
    if (_isSyncing) return SyncResult(synced: 0, failed: 0, message: 'Sync déjà en cours');

    // Vérifier qu'on a un token
    final hasToken = await ApiClient().hasToken();
    if (!hasToken) {
      return SyncResult(synced: 0, failed: 0, message: 'Non authentifié');
    }

    _isSyncing = true;
    _notifyListeners();

    try {
      // 1. Récupérer les questionnaires non synchronisés
      final unsyncedList = await _db.getQuestionnaires(syncStatus: 'local');

      if (unsyncedList.isEmpty) {
        debugPrint('[SyncService] Aucun questionnaire à synchroniser');
        return SyncResult(synced: 0, failed: 0, message: 'Tout est à jour');
      }

      debugPrint('[SyncService] ${unsyncedList.length} questionnaire(s) à synchroniser');

      // 2. Envoyer en batch
      final results = await _apiService.syncBatch(unsyncedList);

      // 3. Mettre à jour les statuts locaux
      int synced = 0;
      int failed = 0;

      if (results.isNotEmpty) {
        // Succès — marquer comme synchronisés
        for (final local in unsyncedList) {
          final localId = local['id'];
          if (localId != null) {
            await _db.updateQuestionnaireSyncStatus(localId as int, 'synced');
            synced++;
          }
        }
      } else {
        failed = unsyncedList.length;
      }

      final result = SyncResult(
        synced: synced,
        failed: failed,
        message: synced > 0
            ? '$synced questionnaire(s) synchronisé(s)'
            : 'Échec de la synchronisation',
      );

      debugPrint('[SyncService] Résultat: ${result.message}');
      return result;
    } catch (e) {
      debugPrint('[SyncService] Erreur: $e');
      return SyncResult(synced: 0, failed: 0, message: 'Erreur: $e');
    } finally {
      _isSyncing = false;
      _notifyListeners();
    }
  }

  /// Synchronise un seul questionnaire (appelé après sauvegarde locale).
  ///
  /// Fire-and-forget : ne bloque pas l'UI même si ça échoue.
  Future<bool> syncOne(Map<String, dynamic> questionnaire) async {
    if (!await _isOnline()) return false;

    final hasToken = await ApiClient().hasToken();
    if (!hasToken) return false;

    try {
      final result = await _apiService.syncQuestionnaire(questionnaire);
      if (result != null) {
        // Marquer comme synchronisé
        final localId = questionnaire['id'];
        if (localId != null) {
          await _db.updateQuestionnaireSyncStatus(localId as int, 'synced');
        }
        debugPrint('[SyncService] Questionnaire "${questionnaire['type']}" synchronisé');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SyncService] syncOne error: $e');
      return false;
    }
  }

  // ── Utilitaires ───────────────────────────────────────────────────────────

  Future<bool> _isOnline() async {
    final status = await _connectivity.checkConnectivity();
    return status.any((s) => s != ConnectivityResult.none);
  }

  /// Nombre de questionnaires en attente de sync.
  Future<int> getPendingCount() async {
    final list = await _db.getQuestionnaires(syncStatus: 'local');
    return list.length;
  }
}

/// Résultat d'une opération de synchronisation.
class SyncResult {
  final int synced;
  final int failed;
  final String message;

  SyncResult({required this.synced, required this.failed, required this.message});
}
