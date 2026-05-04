import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color royalBlue = Color(0xFF6366F1);
  static const Color royalBlue10 = Color(0xFFEEF2FF);
  static const Color whiteZyrcon = Color(0xFFF8FAFC);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static const Color hummingBird = Color(0xFFD1FAE5);
  static const Color foam = Color(0xFFFEF3C7);
  static const Color mountainMeadow = Color(0xFF10B981);
  static const Color detailOrange = Color(0xFFFAD7A0);

  static const Color ebony = Color(0xFF0F172A);
  static const Color fiord = Color(0xFF475569);
  static const Color gullGray = Color(0xFF94A3B8);

  static const Color focusBlack = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkDetail = Color(0xFFE0E0E0);

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: royalBlue,
    onPrimary: pureWhite,
    secondary: royalBlue10,
    onSecondary: fiord,
    surface: pureWhite,
    onSurface: ebony,
    onSurfaceVariant: fiord,
    outline: gullGray,
    error: Color(0xFFDC2626),
    onError: Color(0xFFFEE2E2),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: whiteZyrcon,
      colorScheme: lightColorScheme,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onSurface,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: lightColorScheme.onSurfaceVariant,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.outline,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: pureWhite,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hourMinuteColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? lightColorScheme.primary
                : lightColorScheme.secondary),
        hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? pureWhite
                : lightColorScheme.onSurface),
        dialHandColor: lightColorScheme.primary,
        dialBackgroundColor: lightColorScheme.secondary,
        dialTextColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? pureWhite
                : lightColorScheme.onSurface),
        entryModeIconColor: lightColorScheme.onSurfaceVariant,
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  static TextStyle get timerDisplay => GoogleFonts.nunito(
        fontSize: 96,
        fontWeight: FontWeight.w800,
        color: ebony,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
