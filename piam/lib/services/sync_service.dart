import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();

  SyncService._internal();

  factory SyncService() => _instance;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void start() {
    _sub = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> statusList,
    ) {
      if (statusList.any((status) => status != ConnectivityResult.none)) {
        // TODO: implémenter synchronisation des éléments en attente
      }
    });
  }

  void stop() {
    _sub?.cancel();
  }
}
