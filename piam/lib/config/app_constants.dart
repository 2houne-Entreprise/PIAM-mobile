/// Constantes de l'application
class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.piam.com';
  static const String apiTimeout = '30';

  // Storage
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String localiteIdKey = 'localite_id';
  static const String projectIdKey = 'project_id';

  // Database
  static const String dbName = 'piam.db';
  static const int dbVersion = 1;

  // Formulaires
  static const List<String> formulaireTypes = [
    'declenchement',
    'certification_fdal',
    'etat_lieux_localite',
    'etat_lieux_menage',
    'dernier_suivi_localite',
    'dernier_suivi_menage',
    'inventaire',
    'programmation_travaux',
    'travaux_receptiones',
  ];

  // ⚠️ TODO(prod): Supprimer ces credentials avant la mise en production
  // Compte de test unique pour la version de démonstration
  static const String testEmail = 'test@piam.mr';
  static const String testPassword = 'Piam2026!';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 255;
  static const int maxDescriptionLength = 5000;

  // GPS
  static const double gpsAccuracyThreshold = 50.0; // mètres

  // Sync
  static const int syncRetryCount = 3;
  static const Duration syncInterval = Duration(minutes: 5);

  // Date
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
}
