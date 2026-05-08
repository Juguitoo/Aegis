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

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSecondary = Color(0xFF334155);
  static const Color darkDetail = Color(0xFF94A3B8);

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

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: royalBlue,
    onPrimary: pureWhite,
    secondary: darkSecondary,
    onSecondary: pureWhite,
    surface: darkSurface,
    onSurface: whiteZyrcon,
    onSurfaceVariant: darkDetail,
    outline: fiord,
    error: Color(0xFFEF4444),
    onError: Color(0xFFFEE2E2),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: whiteZyrcon,
      colorScheme: lightColorScheme,
      textTheme: _buildTextTheme(lightColorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(lightColorScheme),
      timePickerTheme: _buildTimePickerTheme(lightColorScheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: whiteZyrcon,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: gullGray,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: darkColorScheme,
      textTheme: _buildTextTheme(darkColorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(darkColorScheme),
      timePickerTheme: _buildTimePickerTheme(darkColorScheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: fiord,
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme scheme) {
    return GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: scheme.outline,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static TimePickerThemeData _buildTimePickerTheme(ColorScheme scheme) {
    return TimePickerThemeData(
      backgroundColor: scheme.surface,
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      hourMinuteColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.secondary),
      hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurface),
      dialHandColor: scheme.primary,
      dialBackgroundColor: scheme.secondary,
      dialTextColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurface),
      entryModeIconColor: scheme.onSurfaceVariant,
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  static TextStyle timerDisplay(Color textColor) => GoogleFonts.nunito(
        fontSize: 96,
        fontWeight: FontWeight.w800,
        color: textColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
