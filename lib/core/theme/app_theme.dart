import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===========================================================================
  // 1. PALETA DE COLORES
  // ===========================================================================

  // Colores Principales
  static const Color royalBlue = Color(0xFF6366F1);
  static const Color royalBlue10 = Color(0xFFEEF2FF);
  static const Color whiteZyrcon = Color(0xFFF8FAFC);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Estados y Detalles
  static const Color hummingBird = Color(0xFFD1FAE5);
  static const Color foam = Color(0xFFFEF3C7);
  static const Color mountainMeadow = Color(0xFF10B981);
  static const Color detailOrange = Color(0xFFFAD7A0);

  // Escala de Grises (Textos e Iconos)
  static const Color ebony = Color(0xFF0F172A); // Texto Principal
  static const Color fiord = Color(0xFF475569); // Texto/Icono Secundario
  static const Color gullGray = Color(0xFF94A3B8); // Texto/Icono Inactivo

  // Oscuros
  static const Color focusBlack = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkDetail = Color(0xFFE0E0E0);

  // ===========================================================================
  // 2. CONFIGURACIÓN DEL TEMA
  // ===========================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: whiteZyrcon,
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalBlue,
        primary: royalBlue,
        secondary: fiord,
        surface: pureWhite,
        onPrimary: pureWhite,
        onSurface: ebony,
      ),
      // Tipografía base para toda la app
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        // Heading H1
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ebony,
        ),
        // Heading H2
        displayMedium: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600, // SemiBold
          color: ebony,
        ),
        // Body M
        bodyLarge: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w500, // Medium
          color: ebony,
        ),
        // Body S
        bodyMedium: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w400, // Regular
          color: fiord,
        ),
        // Caption
        bodySmall: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: gullGray,
        ),
      ),
      // Estilo por defecto para los botones principales
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalBlue,
          foregroundColor: pureWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. ESTILOS ESPECÍFICOS
  // ===========================================================================

  // Display XL para el Temporizador
  static TextStyle get timerDisplay => GoogleFonts.nunito(
        fontSize: 96,
        fontWeight: FontWeight.w800, // ExtraBold
        color: ebony,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
