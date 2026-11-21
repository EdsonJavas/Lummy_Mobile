import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Cores da área da criança que seguem o modo claro/escuro.
      extensions: const <ThemeExtension<dynamic>>[LummyCores.claro],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: LummyColors.slate100,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: LummyColors.brandBlue,
        secondary: LummyColors.brandOrange,
        error: LummyColors.red500,
        surface: LummyColors.white,
        surfaceContainerHighest: LummyColors.slate200, // Hierarquia em modo claro
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: LummyColors.slate800,
        outline: LummyColors.slate200,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: LummyFonts.body(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: LummyColors.slate800,
        ),
        displayMedium: LummyFonts.body(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: LummyColors.slate800,
        ),
        displaySmall: LummyFonts.body(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: LummyColors.slate800,
        ),
        headlineMedium: LummyFonts.body(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: LummyColors.slate800,
        ),
        titleLarge: LummyFonts.body(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: LummyColors.slate800,
        ),
        titleMedium: LummyFonts.body(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: LummyColors.slate800,
        ),
        bodyLarge: LummyFonts.body(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: LummyColors.slate800,
        ),
        bodyMedium: LummyFonts.body(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: LummyColors.slate600, // Contraste melhor que textSecondary
        ),
        bodySmall: LummyFonts.body(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: LummyColors.slate500,
        ),
      ),

      // Divider (modo claro)
      dividerTheme: const DividerThemeData(
        color: LummyColors.slate200,
        thickness: 1,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LummyColors.offWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(
            color: LummyColors.brandBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(
            color: LummyColors.red500,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLarge,
          vertical: AppConstants.spacingMedium,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LummyColors.brandOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          elevation: 0,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LummyColors.brandBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LummyColors.brandBlue,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          side: const BorderSide(color: LummyColors.slate200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LummyColors.brandBlue,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: LummyColors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          side: const BorderSide(color: LummyColors.slate200, width: 1),
        ),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: LummyColors.brandBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: LummyFonts.body(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Bottom navigation bar (light)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LummyColors.white,
        selectedItemColor: LummyColors.brandBlue,
        unselectedItemColor: LummyColors.slate500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Icon theme (light)
      iconTheme: const IconThemeData(
        color: LummyColors.slate800,
        size: 24,
      ),

      // Snackbar (light)
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LummyColors.slate800,
        contentTextStyle: LummyFonts.body(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      // Cores da área da criança que seguem o modo claro/escuro.
      extensions: const <ThemeExtension<dynamic>>[LummyCores.escuroPadrao],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LummyColors.darkMaterial,
      // Color scheme - cores inspiradas no site Lummy
      colorScheme: const ColorScheme.dark(
        primary: LummyColors.blue500, // Azul vibrante
        secondary: LummyColors.brandOrange, // Laranja vibrante
        tertiary: LummyColors.emerald500, // Verde vibrante
        error: LummyColors.red500,
        surface: LummyColors.darkSurface, // Surface cards - cinza neutro
        surfaceContainerHighest: LummyColors.neutral800, // Surface mais alto
        onPrimary: Colors.white, // Texto branco em primary
        onSecondary: Colors.white, // Texto branco em secondary
        onError: Colors.white,
        onSurface: Colors.white, // Branco puro para textos
        outline: LummyColors.steel700, // Bordas mais sutis
      ),

      // Text theme - textos brancos puros como no site
      textTheme: TextTheme(
        displayLarge: LummyFonts.body(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        displayMedium: LummyFonts.body(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displaySmall: LummyFonts.body(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: LummyFonts.body(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: LummyFonts.body(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: LummyFonts.body(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: LummyFonts.body(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodyMedium: LummyFonts.body(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: LummyColors.slate200, // Cinza claro para textos secundários
        ),
        bodySmall: LummyFonts.body(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: LummyColors.slate300, // Cinza mais claro
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: LummyColors.steel700,
        thickness: 1,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LummyColors.darkSurface,
        hintStyle: LummyFonts.body(
          color: LummyColors.steel500,
          fontSize: 14,
        ),
        labelStyle: LummyFonts.body(
          color: LummyColors.steel400,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LummyColors.steel700, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LummyColors.steel700, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LummyColors.blue500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LummyColors.red500, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LummyColors.red500, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLarge,
          vertical: AppConstants.spacingMedium,
        ),
      ),

      // Elevated button theme - laranja vibrante como no site
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LummyColors.brandOrange, // Laranja vibrante
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          elevation: 0,
          textStyle: LummyFonts.body(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: LummyColors.darkSurface, // Cinza neutro
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          side: const BorderSide(color: LummyColors.steel700, width: 1),
        ),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: LummyColors.darkSurface, // Cinza neutro
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: LummyFonts.body(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LummyColors.darkSurface, // Cinza neutro
        selectedItemColor: LummyColors.blue500, // Azul vibrante
        unselectedItemColor: LummyColors.steel500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: Colors.white, size: 24),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LummyColors.blue500, // Azul vibrante
        circularTrackColor: LummyColors.steel700,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LummyColors.darkSurface, // Cinza neutro
        contentTextStyle: LummyFonts.body(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: LummyColors.steel700, width: 1),
        ),
      ),
    );
  }
}
