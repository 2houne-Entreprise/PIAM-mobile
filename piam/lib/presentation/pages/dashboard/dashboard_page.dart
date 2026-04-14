import 'package:flutter/material.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/services/database_service.dart';
import 'package:piam/services/sync_service.dart';
import 'package:piam/services/questionnaire_api_service.dart';
import 'package:piam/services/api_client.dart';
import 'package:piam/data/reference_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Dashboard affichant les 9 formulaires disponibles
/// avec données hybrides (SQLite local + API) et indicateur de sync.

typedef GoToParametrageCallback = void Function();

class DashboardPage extends StatefulWidget {
  final dynamic user;
  final dynamic localite;
  final GoToParametrageCallback? onGoToParametrage;

  const DashboardPage({
    Key? key,
    this.user,
    this.localite,
    this.onGoToParametrage,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Statuts des 9 formulaires
  Map<String, String> formulaireStatuts = {
    'Déclenchement': 'brouillon',
    'Certification FDAL': 'brouillon',
    'État des Lieux Localité': 'brouillon',
    'État des Lieux Ménage': 'brouillon',
    'Dernier Suivi Localité': 'brouillon',
    'Dernier Suivi Ménage': 'brouillon',
    'Programmation des Travaux': 'brouillon',
    'Inventaire': 'brouillon',
  };

  Map<String, int> stats = {'complète': 0, 'validée': 0, 'brouillon': 0};
  String? projectName;
  String? localiteName;
  bool isLoading = true;
  bool _isSyncing = false;
  int _pendingSync = 0;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final status = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = status.any((s) => s != ConnectivityResult.none);
      });
    }
    // Écouter les changements
    Connectivity().onConnectivityChanged.listen((statusList) {
      if (mounted) {
        setState(() {
          _isOnline = statusList.any((s) => s != ConnectivityResult.none);
        });
      }
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final dbService = DatabaseService();
      final param = await dbService.getParametreUtilisateur();

      // Nombre de questionnaires en attente de sync
      _pendingSync = await SyncService().getPendingCount();

      if (param != null) {
        // Charger les questionnaires pour le statut
        final questionnaires = await dbService.getQuestionnaires();
        // Statuts dynamiques
        Map<String, String> dynamicStatuses = {};
        for (var q in questionnaires) {
          dynamicStatuses[q['type']] = q['sync_status'] ?? 'brouillon';
        }
        // Statistiques
        Map<String, int> dynamicStats = {
          'complète': 0,
          'validée': 0,
          'brouillon': 0,
        };
        // Compter les formulaires avec des données
        int synced = 0;
        int local = 0;
        for (var q in questionnaires) {
          final syncStatus = q['sync_status'] ?? 'local';
          if (syncStatus == 'synced') {
            synced++;
          } else {
            local++;
          }
        }
        dynamicStats['complète'] = synced;
        dynamicStats['brouillon'] = local;

        // --- Résolution du nom via ReferenceData ---
        int? locId = param['localite_id'];
        int? communeId = param['commune_id'];
        String resolvedName = 'Localité non définie';

        if (locId != null) {
          final foundLoc = ReferenceData.localites
              .where((l) => l['id'] == locId)
              .toList();
          if (foundLoc.isNotEmpty) {
            resolvedName =
                (foundLoc.first['intitule_fr'] ?? foundLoc.first['intitule'])
                    .toString();
          } else {
            resolvedName = 'Localité ($locId)';
          }
        } else if (communeId != null) {
          final foundCom = ReferenceData.communes
              .where((c) => c['id'] == communeId)
              .toList();
          if (foundCom.isNotEmpty) {
            resolvedName =
                (foundCom.first['intitule_fr'] ?? foundCom.first['intitule'])
                    .toString();
          } else {
            resolvedName = 'Commune ($communeId)';
          }
        }

        setState(() {
          formulaireStatuts.addAll(dynamicStatuses);
          stats = dynamicStats;
          projectName = 'Projet PIAM';
          localiteName = resolvedName;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.dashboard),
        elevation: 0,
        actions: [
          // Indicateur de connectivité
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              _isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: _isOnline ? Colors.green : Colors.grey,
              size: 20,
            ),
          ),
          // Badge sync en attente
          if (_pendingSync > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: const Icon(Icons.sync, size: 16, color: Colors.white),
                label: Text(
                  '$_pendingSync',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Colors.orange,
                visualDensity: VisualDensity.compact,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showUserProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête utilisateur
            _buildUserHeader(),
            const SizedBox(height: 24),

            // Statistiques
            _buildStats(),
            const SizedBox(height: 24),

            // Titre section formulaires
            Text(
              AppStrings.formulaires,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grille des formulaires
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                final formulaireNames = [
                  'Déclenchement',
                  'Certification FDAL',
                  'État des Lieux Localité',
                  'État des Lieux Ménage',
                  'Dernier Suivi Localité',
                  'Dernier Suivi Ménage',
                  'Programmation des Travaux',
                  'Inventaire',
                ];
                final name = formulaireNames[index];
                final status = formulaireStatuts[name] ?? 'brouillon';

                return _buildFormulaireCard(
                  name: name,
                  status: status,
                  index: index + 1,
                  onTap: () => _openFormulaire(context, name),
                );
              },
            ),
            const SizedBox(height: 24),

            // Bouton synchroniser
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isSyncing
                    ? 'Synchronisation...'
                    : _pendingSync > 0
                        ? 'Synchroniser ($_pendingSync en attente)'
                        : 'Tout est synchronisé ✓'),
                onPressed: _isSyncing ? null : _syncData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pendingSync > 0
                      ? AppTheme.colorBlue
                      : Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colorBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colorBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.colorBlue,
                child: Text(
                  (widget.user.nom.isEmpty ? 'U' : widget.user.nom[0])
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      projectName ?? widget.localite.nom,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Indicateur sync
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOnline ? Icons.cloud_done : Icons.cloud_off,
                      size: 14,
                      color: _isOnline ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isOnline ? 'En ligne' : 'Hors ligne',
                      style: TextStyle(
                        fontSize: 11,
                        color: _isOnline ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppTheme.colorBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localiteName ?? widget.localite.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final dashboardStats = [
      (stats['complète']?.toString() ?? '0', 'Synchronisés', AppTheme.colorGreen),
      (stats['brouillon']?.toString() ?? '0', 'En attente', AppTheme.colorYellow),
      ('${stats['complète']! + stats['brouillon']!}', 'Total', AppTheme.colorBlue),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: dashboardStats
          .map(
            (stat) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: stat.$3.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stat.$3.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      stat.$1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: stat.$3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFormulaireCard({
    required String name,
    required String status,
    required int index,
    required VoidCallback onTap,
  }) {
    final statusConfig = _getStatusConfig(status);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              top: BorderSide(color: statusConfig.color, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Badge de statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusConfig.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusConfig.label,
                    style: TextStyle(
                      color: statusConfig.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Numéro du formulaire
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusConfig.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: statusConfig.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nom du formulaire
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Icône de progression
                Icon(statusConfig.icon, color: statusConfig.color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'brouillon':
        return _StatusConfig(
          label: 'Brouillon',
          color: AppTheme.colorGray,
          icon: Icons.edit_outlined,
        );
      case 'local':
        return _StatusConfig(
          label: 'Local',
          color: AppTheme.colorYellow,
          icon: Icons.phone_android,
        );
      case 'synced':
        return _StatusConfig(
          label: 'Synchronisé',
          color: AppTheme.colorGreen,
          icon: Icons.cloud_done_outlined,
        );
      case 'complète':
        return _StatusConfig(
          label: 'Complète',
          color: AppTheme.colorYellow,
          icon: Icons.check_circle_outline,
        );
      case 'validée':
        return _StatusConfig(
          label: 'Validée',
          color: AppTheme.colorGreen,
          icon: Icons.verified_outlined,
        );
      case 'envoyée':
        return _StatusConfig(
          label: 'Envoyée',
          color: AppTheme.colorBlue,
          icon: Icons.cloud_done_outlined,
        );
      case 'erreur':
        return _StatusConfig(
          label: 'Erreur',
          color: AppTheme.colorRed,
          icon: Icons.error_outline,
        );
      default:
        return _StatusConfig(
          label: 'Brouillon',
          color: AppTheme.colorGray,
          icon: Icons.edit_outlined,
        );
    }
  }

  void _openFormulaire(BuildContext context, String formulaireName) {
    switch (formulaireName) {
      case 'Déclenchement':
        Navigator.of(
          context,
        ).pushNamed('/formulaires/declenchement', arguments: 'new');
        break;
      case 'Certification FDAL':
        Navigator.of(context).pushNamed('/certification_fdal');
        break;
      case 'État des Lieux Localité':
        Navigator.of(
          context,
        ).pushNamed('/formulaires/etat_lieux_localite', arguments: 'new');
        break;
      case 'État des Lieux Ménage':
        Navigator.of(
          context,
        ).pushNamed('/formulaires/etat_lieux_menage', arguments: 'new');
        break;
      case 'Dernier Suivi Localité':
        Navigator.of(
          context,
        ).pushNamed('/formulaires/dernier_suivi_localite', arguments: 'new');
        break;
      case 'Dernier Suivi Ménage':
        Navigator.of(
          context,
        ).pushNamed('/formulaires/dernier_suivi_menage', arguments: 'new');
        break;
      case 'Programmation des Travaux':
        Navigator.of(
          context,
        ).pushNamed('/formulaires/programmation_travaux', arguments: 'new');
        break;
      case 'Inventaire':
        Navigator.of(
          context,
        ).pushNamed('/formulaires/inventaire', arguments: 'new');
        break;
    }
  }

  /// Synchronise les données locales avec l'API.
  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    final result = await SyncService().syncAll();

    if (mounted) {
      setState(() => _isSyncing = false);

      // Recharger les données du dashboard
      await _loadDashboardData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.synced > 0 ? Icons.check_circle : Icons.info,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(result.message)),
            ],
          ),
          backgroundColor:
              result.synced > 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showUserProfile() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil utilisateur')));
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({required this.label, required this.color, required this.icon});
}
