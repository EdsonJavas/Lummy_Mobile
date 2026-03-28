import 'package:flutter/material.dart';

/// Single source of truth for all design tokens in the Lummy app.
/// Screens should reference these instead of defining inline hex colors.
abstract final class LummyColors {
  // Brand
  static const blue = Color(0xFF3B82F6);
  static const blueDark = Color(0xFF1E40AF);
  static const purple = Color(0xFF8B5CF6);
  static const purpleDark = Color(0xFF6D28D9);
  static const orange = Color(0xFFF59E0B);
  static const orangeDark = Color(0xFFD97706);
  static const green = Color(0xFF10B981);
  static const greenDark = Color(0xFF059669);
  static const teal = Color(0xFF14B8A6);
  static const tealDark = Color(0xFF0D9488);
  static const red = Color(0xFFEF4444);
  static const pink = Color(0xFFEC4899);

  // Semantic
  static const success = green;
  static const error = red;
  static const warning = orange;
  static const info = blue;

  // Light mode surfaces
  static const lightBg = Color(0xFFF1F5F9);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightBorderStrong = Color(0xFFCBD5E1);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextTertiary = Color(0xFF94A3B8);

  // Dark mode surfaces
  static const darkBg = Color(0xFF0F0F0F);
  static const darkCard = Color(0xFF1A1A2E);
  static const darkBorder = Color(0xFF2D2D2D);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextTertiary = Color(0xFF64748B);
}

abstract final class LummySpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class LummyRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const full = 100.0;
}
