import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fonte única de verdade para cores, fontes e medidas do Lummy.
///
/// Para mudar uma cor do app inteiro, altere o valor aqui. As telas não
/// devem declarar cores em hexadecimal: usem `LummyColors.<nome>`.
abstract final class LummyColors {
  // ── Paleta ──
  // ── Slate (cinza-azulado: textos, bordas, fundos claros) ──
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  // ── Gray / Neutral / Stone ──
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray700 = Color(0xFF374151);
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral800 = Color(0xFF262626);
  static const stone900 = Color(0xFF1C1917);

  // ── Steel (cinzas antigos do app) ──
  static const steel400 = Color(0xFFA0AEC0);
  static const steel500 = Color(0xFF718096);
  static const steel700 = Color(0xFF2D3748);

  // ── Red / Rose ──
  static const red50 = Color(0xFFFEF2F2);
  static const red300 = Color(0xFFFCA5A5);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red800 = Color(0xFF991B1B);
  static const red900 = Color(0xFF7F1D1D);
  static const rose400 = Color(0xFFFB7185);

  // ── Orange / Amber / Yellow ──
  static const orange50 = Color(0xFFFFF7ED);
  static const orange600 = Color(0xFFEA580C);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
  static const amber800 = Color(0xFF92400E);
  static const amber900 = Color(0xFF78350F);
  static const yellow950 = Color(0xFF422006);

  // ── Emerald / Teal / Cyan ──
  static const emerald300 = Color(0xFF6EE7B7);
  static const emerald400 = Color(0xFF34D399);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald700 = Color(0xFF047857);
  static const emerald800 = Color(0xFF065F46);
  static const emerald900 = Color(0xFF064E3B);
  static const teal500 = Color(0xFF14B8A6);
  static const teal600 = Color(0xFF0D9488);
  static const cyan500 = Color(0xFF06B6D4);

  // ── Blue / Indigo ──
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue800 = Color(0xFF1E40AF);
  static const blue900 = Color(0xFF1E3A8A);
  static const blue950 = Color(0xFF172554);
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo300 = Color(0xFFA5B4FC);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo900 = Color(0xFF312E81);
  static const indigo950 = Color(0xFF1E1B4B);

  // ── Violet / Purple / Pink ──
  static const violet50 = Color(0xFFF5F3FF);
  static const violet100 = Color(0xFFEDE9FE);
  static const violet300 = Color(0xFFC4B5FD);
  static const violet400 = Color(0xFFA78BFA);
  static const violet500 = Color(0xFF8B5CF6);
  static const violet600 = Color(0xFF7C3AED);
  static const violet700 = Color(0xFF6D28D9);
  static const violet800 = Color(0xFF5B21B6);
  static const violet900 = Color(0xFF4C1D95);
  static const violet950 = Color(0xFF2E1065);
  static const purple900 = Color(0xFF581C87);
  static const purple950 = Color(0xFF3B0764);
  static const pink500 = Color(0xFFEC4899);

  // ── Marca Lummy ──
  static const brandBlue = Color(0xFF4A90E2);
  static const brandBlueDark = Color(0xFF357ABD);
  static const brandNavy = Color(0xFF003092);
  static const navyMuted = Color(0xFF1E3A5F);
  static const brandOrange = Color(0xFFFF8C42);
  static const brandOrangeMid = Color(0xFFFF7A28);
  static const brandOrangeDeep = Color(0xFFFF5722);

  // ── Destaques avulsos ──
  static const gold = Color(0xFFFFD700);
  static const orangeWeb = Color(0xFFFFA500);
  static const skyWeb = Color(0xFF87CEEB);
  static const materialGreen = Color(0xFF4CAF50);
  static const materialOrange = Color(0xFFFF9800);
  static const materialGrey = Color(0xFF9E9E9E);

  // ── Claros ──
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF8F9FA);
  static const cream = Color(0xFFFFFBF5);

  // ── Superfícies escuras (modo escuro) ──
  static const darkBase = Color(0xFF0F0F0F);
  static const darkMaterial = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkSurfaceHigh = Color(0xFF2D2D2D);
  static const darkNavy = Color(0xFF1A1A2E);
  static const darkNavySurface = Color(0xFF1E1E2E);
  static const darkNavyHigh = Color(0xFF2D2D44);

  // ── Nomes de papel (compatibilidade; apontam para a paleta) ──
  static const blue = blue500;
  static const blueDark = blue800;
  static const purple = violet500;
  static const purpleDark = violet700;
  static const orange = amber500;
  static const orangeDark = amber600;
  static const green = emerald500;
  static const greenDark = emerald600;
  static const teal = teal500;
  static const tealDark = teal600;
  static const red = red500;
  static const pink = pink500;

  static const success = green;
  static const error = red;
  static const warning = orange;
  static const info = blue;

  static const lightBg = slate100;
  static const lightCard = white;
  static const lightBorder = slate200;
  static const lightBorderStrong = slate300;
  static const lightTextPrimary = slate900;
  static const lightTextSecondary = slate500;
  static const lightTextTertiary = slate400;

  static const darkBg = darkBase;
  static const darkCard = darkNavy;
  static const darkBorder = darkSurfaceHigh;
  static const darkTextPrimary = white;
  static const darkTextSecondary = slate400;
  static const darkTextTertiary = slate500;
}

/// Fontes do app. Trocar a fonte aqui troca em todas as telas.
abstract final class LummyFonts {
  /// Fonte principal: textos, títulos e botões.
  static const body = GoogleFonts.poppins;

  /// Fonte do logotipo "Lummy".
  static const logo = GoogleFonts.paytoneOne;

  /// Fonte arredondada para destaques (splash).
  static const rounded = GoogleFonts.fredoka;
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
