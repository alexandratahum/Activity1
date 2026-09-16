import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF5B6CFF);
  static const _lightSurface = Color(0xFFF5F7FB);
  static const _darkSurface = Color(0xFF10141D);
  static const _darkCard = Color(0xFF1B2230);

  static ThemeData get light {
    return _buildTheme(Brightness.light, Colors.white);
  }

  static ThemeData get dark {
    return _buildTheme(Brightness.dark, _darkCard);
  }

  static ThemeData _buildTheme(Brightness brightness, Color cardColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? _lightSurface
          : _darkSurface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.surface),
      ),
    );
  }
}
