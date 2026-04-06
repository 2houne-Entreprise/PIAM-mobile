/// Validateurs pour l'application
class AppValidators {
  /// Valide un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  /// Valide une localisation GPS
  static String? validateGPS(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'GPS non capturé';
    }
    if (latitude < -90 || latitude > 90) {
      return 'Latitude invalide';
    }
    if (longitude < -180 || longitude > 180) {
      return 'Longitude invalide';
    }
    return null;
  }

  /// Valide GPS pour Mauritania (booléen)
  static bool isValidGPS(String latitude, String longitude) {
    try {
      final lat = double.parse(latitude);
      final lon = double.parse(longitude);
      // Mauritanie: Latitude 16-27, Longitude -8 à -14
      return lat >= 16 && lat <= 27 && lon >= -14 && lon <= -8;
    } catch (e) {
      return false;
    }
  }

  /// Valide une date
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Date requise';
    }
    if (date.isAfter(DateTime.now())) {
      return 'La date ne peut pas être dans le futur';
    }
    return null;
  }

  /// Valide une valeur dropdown (pas de doublon)
  static String? validateDropdownValue(
    dynamic value,
    List<dynamic> validValues,
  ) {
    if (value == null || value.toString().isEmpty) {
      return 'Sélection requise';
    }
    if (!validValues.contains(value)) {
      return 'Valeur invalide';
    }
    return null;
  }

  /// Valide un texte court
  static String? validateTextShort(String? value, {int maxLength = 100}) {
    if (value == null || value.isEmpty) {
      return 'Requis';
    }
    if (value.length > maxLength) {
      return 'Max $maxLength caractères';
    }
    return null;
  }

  /// Valide un nombre
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Nombre requis';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Nombre invalide';
    }
    if (min != null && number < min) {
      return 'Minimum: $min';
    }
    if (max != null && number > max) {
      return 'Maximum: $max';
    }
    return null;
  }

  /// Valide une photo
  static String? validatePhoto(int? fileSizeBytes) {
    if (fileSizeBytes == null) {
      return 'Photo requise';
    }
    const minSize = 100000; // 100KB
    if (fileSizeBytes < minSize) {
      return 'Photo trop petite (min 100KB)';
    }
    return null;
  }
}
