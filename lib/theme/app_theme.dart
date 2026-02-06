import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme aplikacji TaLu Kids
class AppTheme {
  AppTheme._();

  /// Bazowy styl tekstu z fontem Nunito (obsługuje Latin Extended)
  static TextStyle get _baseTextStyle => GoogleFonts.nunito();

  // KOLORY
  static const Color primaryColor = Color(0xFFFF6B9D);
  static const Color accentColor = Color(0xFF4ECDC4);
  static const Color backgroundColor = Color(0xFFFFF9F5);
  static const Color yellowColor = Color(0xFFFFD93D);
  static const Color purpleColor = Color(0xFFA78BFA);
  static const Color greenColor = Color(0xFF6EE7B7);
  static const Color orangeColor = Color(0xFFFCA5A5);
  static const Color textColor = Color(0xFF2D3748);
  static const Color textLightColor = Color(0xFF4A5568);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor, size: 32),
        titleTextStyle: _baseTextStyle.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      useMaterial3: true,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: _baseTextStyle.copyWith(fontSize: 48, fontWeight: FontWeight.bold, color: textColor, height: 1.2),
      displayMedium: _baseTextStyle.copyWith(fontSize: 40, fontWeight: FontWeight.bold, color: textColor, height: 1.2),
      headlineLarge: _baseTextStyle.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: textColor, height: 1.3),
      headlineMedium: _baseTextStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w600, color: textColor, height: 1.3),
      titleLarge: _baseTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: textColor, height: 1.4),
      titleMedium: _baseTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: textColor, height: 1.4),
      labelLarge: _baseTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
      bodyLarge: _baseTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: textLightColor, height: 1.6),
      bodyMedium: _baseTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.normal, color: textLightColor, height: 1.6),
    );
  }

  static LinearGradient get primaryGradient {
    return LinearGradient(
      colors: [primaryColor, purpleColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get accentGradient {
    return LinearGradient(
      colors: [accentColor, greenColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get yellowGradient {
    return LinearGradient(
      colors: [yellowColor, orangeColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> get buttonShadowPressed {
    return [
      BoxShadow(
        color: primaryColor.withValues(alpha: 0.3),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ];
  }

  static const double buttonBorderRadius = 30.0;
  static const double cardBorderRadius = 32.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 40, vertical: 20);
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);
  static const double spacingSmall = 12.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 40.0;
  static const double iconSizeSmall = 32.0;
  static const double iconSizeMedium = 48.0;
  static const double iconSizeLarge = 64.0;
}
