import 'package:flutter/material.dart';

/// Thème Material 3 pour PIAM
class AppTheme {
  static const Color primaryColor = Color(0xFF3B82F6); // Bleu
  static const Color successColor = Color(0xFF10B981); // Vert
  static const Color warningColor = Color(0xFFFBBF24); // Jaune
  static const Color errorColor = Color(0xFFEF4444); // Rouge
  static const Color neutralColor = Color(0xFF9CA3AF); // Gris
  static const Color surfaceColor = Color(0xFFFFFFFF); // Blanc
  static const Color backgroundColor = Color(0xFFF3F4F6); // Gris clair

  // Alias pour les couleurs nommées
  static const Color colorBlue = Color(0xFF3B82F6); // Bleu
  static const Color colorGreen = Color(0xFF10B981); // Vert
  static const Color colorYellow = Color(0xFFFBBF24); // Jaune
  static const Color colorRed = Color(0xFFEF4444); // Rouge
  static const Color colorGray = Color(0xFF9CA3AF); // Gris

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        elevation: 2,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
