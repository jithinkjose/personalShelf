import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Neo-pop color palette — high contrast, electric colours on deep black
class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const surfaceElevated = Color(0xFF1E1E1E);
  static const border = Color(0xFF2A2A2A);

  static const electricYellow = Color(0xFFF5E642);
  static const electricBlue = Color(0xFF3D5AFE);
  static const hotPink = Color(0xFFFF006E);
  static const neonGreen = Color(0xFF00FF85);
  static const electricOrange = Color(0xFFFF6B00);
  static const electricPurple = Color(0xFF9C27FF);
  static const electricCyan = Color(0xFF00E5FF);
  static const softWhite = Color(0xFFF0F0F0);
  static const mutedGrey = Color(0xFF6B6B6B);
  static const white = Colors.white;
  static const black = Color(0xFF0A0A0A);

  /// Profile/locker accent colours
  static const profileColors = [
    electricYellow,
    electricBlue,
    hotPink,
    neonGreen,
    electricOrange,
    electricPurple,
    electricCyan,
    Color(0xFFFF4081),
    Color(0xFF00BCD4),
    Color(0xFFFFAB40),
  ];
}

class AppTheme {
  static const _shadowOffset = Offset(4, 4);
  static const _shadowBlur = 0.0;

  /// Neo-pop box shadow: hard offset shadow instead of a blur
  static BoxShadow neoShadow(Color color) => BoxShadow(
        color: color,
        offset: _shadowOffset,
        blurRadius: _shadowBlur,
      );

  static BoxShadow neoShadowLarge(Color color) => BoxShadow(
        color: color,
        offset: const Offset(6, 6),
        blurRadius: _shadowBlur,
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.electricYellow,
        onPrimary: AppColors.black,
        secondary: AppColors.electricBlue,
        onSecondary: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.white,
        error: AppColors.hotPink,
        onError: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: _buildTextTheme(),
      inputDecorationTheme: _buildInputTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricYellow,
          foregroundColor: AppColors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.white, width: 2),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: const CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.border, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.white, size: 24),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -1,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.softWhite,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedGrey,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedGrey,
        letterSpacing: 0.5,
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.electricYellow, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.hotPink, width: 2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.hotPink, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.mutedGrey),
      hintStyle: const TextStyle(color: AppColors.mutedGrey),
      errorStyle: const TextStyle(color: AppColors.hotPink),
    );
  }
}
