// Dart Models pour PIAM - Générés automatiquement depuis la structure
// Fichier supprimé (remplacé par database_service.dart)
// Utilisez 'freezed' pour l'immutabilité: flutter pub add freezed_annotation build_runner

// ============================================================================
// MODELS DE BASE
// ============================================================================

/// Représentation d'une localité (lieu géographique)
class Localite {
  final String id;
  final String nom;
  final String wilaya;
  final String moughataa;
  final String commune;
  final GpsLocation gps;
  final DateTime dateCreation;
  final DateTime dateModification;
  final String? description;
  final String statut; // "approuvée", "en_attente", "rejetée"

  Localite({
    required this.id,
    required this.nom,
    required this.wilaya,
    required this.moughataa,
    required this.commune,
    required this.gps,
    required this.dateCreation,
    required this.dateModification,
    this.description,
    this.statut = "approuvée",
  });

  factory Localite.fromJson(Map<String, dynamic> json) {
    return Localite(
      id: json['id'],
      nom: json['nom'],
      wilaya: json['wilaya'],
      moughataa: json['moughataa'],
      commune: json['commune'],
      gps: GpsLocation.fromJson(json['gps']),
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
      description: json['description'],
      statut: json['statut'] ?? 'approuvée',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'wilaya': wilaya,
    'moughataa': moughataa,
    'commune': commune,
    'gps': gps.toJson(),
    'dateCreation': dateCreation.toIso8601String(),
    'dateModification': dateModification.toIso8601String(),
    'description': description,
    'statut': statut,
  };

  /// Factory pour créer une localité vide
  factory Localite.empty() {
    return Localite(
      id: '',
      nom: '',
      wilaya: '',
      moughataa: '',
      commune: '',
      gps: GpsLocation(latitude: 0, longitude: 0, precision: 0),
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
      description: null,
      statut: 'approuvée',
    );
  }
}

/// Localisation GPS
class GpsLocation {
  final double latitude;
  final double longitude;
  final double precision; // En mètres

  GpsLocation({
    required this.latitude,
    required this.longitude,
    required this.precision,
  });

  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  factory GpsLocation.fromJson(Map<String, dynamic> json) {
    return GpsLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      precision: (json['precision'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'precision': precision,
  };

  @override
  String toString() => '$latitude, $longitude (±${precision}m)';
}

/// Photo capturée avec métadonnées
class Photo {
  final String id;
  final String filePath;
  final GpsLocation? gpsLocation;
  final DateTime dateCapture;
  final int sizeBytes;
  final String format; // "jpg", "png"
  final String? description;

  Photo({
    required this.id,
    required this.filePath,
    this.gpsLocation,
    required this.dateCapture,
    required this.sizeBytes,
    required this.format,
    this.description,
  });

  bool get isValid => sizeBytes >= 100000 && ["jpg", "png"].contains(format);

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      filePath: json['filePath'],
      gpsLocation: json['gpsLocation'] != null
          ? GpsLocation.fromJson(json['gpsLocation'])
          : null,
      dateCapture: DateTime.parse(json['dateCapture']),
      sizeBytes: json['sizeBytes'],
      format: json['format'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'gpsLocation': gpsLocation?.toJson(),
    'dateCapture': dateCapture.toIso8601String(),
    'sizeBytes': sizeBytes,
    'format': format,
    'description': description,
  };
}

// ============================================================================
// MODELS GÉNÉRIQUE POUR TOUS LES FORMULAIRES
// ============================================================================

/// Formulaire générique (superclasse pour tous les types)
class Formulaire {
  final String id;
  final String type; // "declenchement", "certification_fdal", etc.
  final String localiteId;
  final DateTime date;
  final GpsLocation gps;
  final Map<String, dynamic> reponses; // {champ_id: valeur}
  final List<Photo> photos;
  final String remarques;
  final String statut; // "brouillon", "complète", "validée", "envoyée"
  final DateTime dateCreation;
  final DateTime dateModification;
  final String? utilisateurId;

  Formulaire({
    required this.id,
    required this.type,
    required this.localiteId,
    required this.date,
    required this.gps,
    this.reponses = const {},
    this.photos = const [],
    this.remarques = "",
    this.statut = "brouillon",
    required this.dateCreation,
    required this.dateModification,
    this.utilisateurId,
  });

  bool isComplete() => reponses.isNotEmpty && gps.isValid;
  bool isValid() => isComplete() && photos.isNotEmpty;

  factory Formulaire.fromJson(Map<String, dynamic> json) {
    return Formulaire(
      id: json['id'],
      type: json['type'],
      localiteId: json['localiteId'],
      date: DateTime.parse(json['date']),
      gps: GpsLocation.fromJson(json['gps']),
      reponses: Map<String, dynamic>.from(json['reponses'] ?? {}),
      photos: List<Photo>.from(
        (json['photos'] as List?)?.map((p) => Photo.fromJson(p)) ?? [],
      ),
      remarques: json['remarques'] ?? "",
      statut: json['statut'] ?? "brouillon",
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
      utilisateurId: json['utilisateurId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'localiteId': localiteId,
    'date': date.toIso8601String(),
    'gps': gps.toJson(),
    'reponses': reponses,
    'photos': photos.map((p) => p.toJson()).toList(),
    'remarques': remarques,
    'statut': statut,
    'dateCreation': dateCreation.toIso8601String(),
    'dateModification': dateModification.toIso8601String(),
    'utilisateurId': utilisateurId,
  };
}

// ============================================================================
// MODELS SPÉCIFIQUES PAR FORMULAIRE (Optionnel - héritage de Formulaire)
// ============================================================================

class FormulaireDeeclenchement extends Formulaire {
  final String localiteNom;

  FormulaireDeeclenchement({
    required String id,
    required String localiteId,
    required this.localiteNom,
    required DateTime date,
    required GpsLocation gps,
    Map<String, dynamic>? reponses,
    List<Photo>? photos,
    String remarques = "",
    String statut = "brouillon",
    required DateTime dateCreation,
    required DateTime dateModification,
  }) : super(
         id: id,
         type: "declenchement",
         localiteId: localiteId,
         date: date,
         gps: gps,
         reponses: reponses ?? {},
         photos: photos ?? [],
         remarques: remarques,
         statut: statut,
         dateCreation: dateCreation,
         dateModification: dateModification,
       );
}

class FormulaireCertificationFDAL extends Formulaire {
  final bool certificationFDAL;
  final List<String> raisonsNon; // Si OUI

  FormulaireCertificationFDAL({
    required String id,
    required String localiteId,
    required DateTime date,
    required GpsLocation gps,
    required this.certificationFDAL,
    this.raisonsNon = const [],
    Map<String, dynamic>? reponses,
    String statut = "brouillon",
    required DateTime dateCreation,
    required DateTime dateModification,
  }) : super(
         id: id,
         type: "certification_fdal",
         localiteId: localiteId,
         date: date,
         gps: gps,
         reponses: reponses ?? {},
         statut: statut,
         dateCreation: dateCreation,
         dateModification: dateModification,
       );
}

class FormulaireEtatLieuxMenage extends Formulaire {
  final int nbMenagesVisites;
  final bool existenceLatrines;
  final bool dispositifLavageMains;
  final bool? eauSavon;

  FormulaireEtatLieuxMenage({
    required String id,
    required String localiteId,
    required DateTime date,
    required GpsLocation gps,
    required this.nbMenagesVisites,
    required this.existenceLatrines,
    required this.dispositifLavageMains,
    this.eauSavon,
    List<Photo>? photos,
    Map<String, dynamic>? reponses,
    String statut = "brouillon",
    required DateTime dateCreation,
    required DateTime dateModification,
  }) : super(
         id: id,
         type: "etat_lieux_menage",
         localiteId: localiteId,
         date: date,
         gps: gps,
         photos: photos ?? [],
         reponses: reponses ?? {},
         statut: statut,
         dateCreation: dateCreation,
         dateModification: dateModification,
       );

  /// Retourne le formulaire conditionnel à afficher
  String getFormulaireConditionnel() {
    return existenceLatrines
        ? "formulaire_a_details"
        : "formulaire_b_problemes";
  }
}

class FormulaireInventaire extends Formulaire {
  final int nbPointsEau;
  final bool acesAssainissement;
  final int nbLatrinesPubliques;
  final String etatInfrastructure;

  FormulaireInventaire({
    required String id,
    required String localiteId,
    required DateTime date,
    required GpsLocation gps,
    required this.nbPointsEau,
    required this.acesAssainissement,
    required this.nbLatrinesPubliques,
    required this.etatInfrastructure,
    List<Photo>? photos,
    Map<String, dynamic>? reponses,
    String statut = "brouillon",
    required DateTime dateCreation,
    required DateTime dateModification,
  }) : super(
         id: id,
         type: "inventaire",
         localiteId: localiteId,
         date: date,
         gps: gps,
         photos: photos ?? [],
         reponses: reponses ?? {},
         statut: statut,
         dateCreation: dateCreation,
         dateModification: dateModification,
       );

  String getFormulaireConditionnel() {
    return acesAssainissement
        ? "formulaire_a_infrastructure"
        : "formulaire_b_absence";
  }
}

class FormulaireProgrammationTravaux extends Formulaire {
  final String descriptionTravaux;
  final int budgetEstime;
  final String equipeDassignee;
  final String? materiaux;
  final List<DateTime>? datesEtapes;

  FormulaireProgrammationTravaux({
    required String id,
    required String localiteId,
    required DateTime date,
    required GpsLocation gps,
    required this.descriptionTravaux,
    required this.budgetEstime,
    required this.equipeDassignee,
    this.materiaux,
    this.datesEtapes,
    Map<String, dynamic>? reponses,
    String statut = "brouillon",
    required DateTime dateCreation,
    required DateTime dateModification,
  }) : super(
         id: id,
         type: "programmation_travaux",
         localiteId: localiteId,
         date: date,
         gps: gps,
         reponses: reponses ?? {},
         statut: statut,
         dateCreation: dateCreation,
         dateModification: dateModification,
       );
}

class FormulaireReception extends Formulaire {
  final int nbTravauxCompletes;
  final int qualiteGenerale; // Note 1-5
  final String rapportInspection;
  final String signatureResponsable;
  final int budgetFinal;
  final bool acceptee;

  FormulaireReception({
    required String id,
    required String localiteId,
    required DateTime date,
    required GpsLocation gps,
    required this.nbTravauxCompletes,
    required this.qualiteGenerale,
    required this.rapportInspection,
    required this.signatureResponsable,
    required this.budgetFinal,
    required this.acceptee,
    required List<Photo> photos,
    Map<String, dynamic>? reponses,
    String statut = "brouillon",
    required DateTime dateCreation,
    required DateTime dateModification,
  }) : super(
         id: id,
         type: "travaux_receptiones",
         localiteId: localiteId,
         date: date,
         gps: gps,
         photos: photos,
         reponses: reponses ?? {},
         statut: statut,
         dateCreation: dateCreation,
         dateModification: dateModification,
       );

  bool get estAcceptable =>
      photos.length >= 2 &&
      qualiteGenerale >= 3 &&
      budgetFinal <= (budgetFinal * 1.10).toInt(); // +10% tolérance
}

// ============================================================================
// MODELS UTILISATEUR ET AUTHENTIFICATION
// ============================================================================

class Utilisateur {
  final String id;
  final String username;
  final String email;
  final String nom;
  final String prenom;
  final String role; // "collecteur", "superviseur", "admin"
  final String localiteAssignee;
  final DateTime dateCreation;
  final DateTime lastLogin;
  final bool actif;

  Utilisateur({
    required this.id,
    required this.username,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.localiteAssignee,
    required this.dateCreation,
    required this.lastLogin,
    this.actif = true,
  });

  String get fullName => "$prenom $nom";

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      role: json['role'],
      localiteAssignee: json['localiteAssignee'],
      dateCreation: DateTime.parse(json['dateCreation']),
      lastLogin: DateTime.parse(json['lastLogin']),
      actif: json['actif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'nom': nom,
    'prenom': prenom,
    'role': role,
    'localiteAssignee': localiteAssignee,
    'dateCreation': dateCreation.toIso8601String(),
    'lastLogin': lastLogin.toIso8601String(),
    'actif': actif,
  };
}

class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expirationDate;
  final String tokenType; // "Bearer"

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expirationDate,
    this.tokenType = "Bearer",
  });

  bool get estExpire => DateTime.now().isAfter(expirationDate);

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expirationDate: DateTime.parse(json['expirationDate']),
      tokenType: json['tokenType'] ?? "Bearer",
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expirationDate': expirationDate.toIso8601String(),
    'tokenType': tokenType,
  };
}

// ============================================================================
// MODELS DE RAPPORTS
// ============================================================================

class RapportLocalite {
  final String localiteId;
  final String localiteNom;
  final int totalVisites;
  final int completes;
  final int enCours;
  final int echouees;
  final double tauxCompletion;
  final DateTime derniereVisite;
  final int nbPlaintes;
  final int nbAccidents;
  final int nbTravauxCompletes;
  final int budgetTotal;
  final double tauxSatisfaction;

  RapportLocalite({
    required this.localiteId,
    required this.localiteNom,
    required this.totalVisites,
    required this.completes,
    required this.enCours,
    required this.echouees,
    required this.tauxCompletion,
    required this.derniereVisite,
    required this.nbPlaintes,
    required this.nbAccidents,
    required this.nbTravauxCompletes,
    required this.budgetTotal,
    required this.tauxSatisfaction,
  });

  int get avancementGlobal => (tauxCompletion * 100).toInt();

  Map<String, dynamic> toJson() => {
    'localiteId': localiteId,
    'localiteNom': localiteNom,
    'totalVisites': totalVisites,
    'completes': completes,
    'enCours': enCours,
    'echouees': echouees,
    'tauxCompletion': tauxCompletion,
    'derniereVisite': derniereVisite.toIso8601String(),
    'nbPlaintes': nbPlaintes,
    'nbAccidents': nbAccidents,
    'nbTravauxCompletes': nbTravauxCompletes,
    'budgetTotal': budgetTotal,
    'tauxSatisfaction': tauxSatisfaction,
  };
}

// ============================================================================
// MODELS DE SYNCHRONISATION
// ============================================================================

class SyncLog {
  final String id;
  final DateTime dateSync;
  final String type; // "formulaire", "photo", "utilisateur"
  final String objectId;
  final String status; // "succès", "erreur", "en_attente"
  final String? messageErreur;
  final int tentatives;

  SyncLog({
    required this.id,
    required this.dateSync,
    required this.type,
    required this.objectId,
    required this.status,
    this.messageErreur,
    this.tentatives = 0,
  });

  factory SyncLog.fromJson(Map<String, dynamic> json) {
    return SyncLog(
      id: json['id'],
      dateSync: DateTime.parse(json['dateSync']),
      type: json['type'],
      objectId: json['objectId'],
      status: json['status'],
      messageErreur: json['messageErreur'],
      tentatives: json['tentatives'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateSync': dateSync.toIso8601String(),
    'type': type,
    'objectId': objectId,
    'status': status,
    'messageErreur': messageErreur,
    'tentatives': tentatives,
  };
}
