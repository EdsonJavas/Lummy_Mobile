import 'lummy_glyphs.dart';

/// Ícone Lucide da meta a partir do emoji gravado em `goals.emoji`
/// (DECISOES 21). Emojis de `AppConstants.goalIcons`; desconhecido = `target`.
abstract final class GoalIcon {
  static const Map<String, LummyGlyph> _porEmoji = {
    '🚲': LummyGlyphs.bike,
    '🎮': LummyGlyphs.gamepad2,
    '📱': LummyGlyphs.smartphone,
    '💻': LummyGlyphs.laptop,
    '🎸': LummyGlyphs.guitar,
    '⚽': LummyGlyphs.volleyball,
    '🎨': LummyGlyphs.palette,
    '📚': LummyGlyphs.bookOpen,
    '🧸': LummyGlyphs.puzzle,
    '👟': LummyGlyphs.footprints,
    '🎒': LummyGlyphs.backpack,
    '🎧': LummyGlyphs.headphones,
  };

  /// Ícone para [emoji]. Ignora espaços e o seletor de variação (U+FE0F).
  static LummyGlyph doEmoji(String? emoji) {
    final limpo = (emoji ?? '').replaceAll('️', '').trim();
    return _porEmoji[limpo] ?? LummyGlyphs.target;
  }
}
