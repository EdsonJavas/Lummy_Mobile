import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'lummy_glyphs.dart';

export 'lummy_glyphs.dart';

/// Ícone Lucide desenhado com o traço e o preenchimento EXATOS do mockup.
///
/// Por que não `Icon(LucideIcons.x)`: a fonte do pacote tem traço fixo e não
/// preenche (o mockup usa `zap`, `flame`, `star` e `play` preenchidos, e traços
/// de 2 a 3). Aqui o SVG é montado com os mesmos atributos do HTML aprovado.
///
/// Leitura direta do mockup:
/// ```html
/// <svg width="22" ... style="fill: none; stroke: #FFFFFF; stroke-width: 2.2">
/// ```
/// vira
/// ```dart
/// LummyIcon(LummyGlyphs.house, size: 22, color: LummyColors.white, strokeWidth: 2.2)
/// ```
/// e `style="fill: #F5B000; stroke: #F5B000; stroke-width: 2"` vira
/// `LummyIcon(LummyGlyphs.zap, size: 14, color: LummyColors.brandGold, fill: LummyColors.brandGold)`.
///
/// [strokeWidth] está na escala 24 do Lucide, igual ao `stroke-width` do HTML.
class LummyIcon extends StatelessWidget {
  const LummyIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    required this.color,
    this.strokeWidth = 2,
    this.fill,
    this.semanticLabel,
  });

  /// Qual ícone (`LummyGlyphs.<nome>`).
  final LummyGlyph glyph;

  /// Lado do quadrado, em dp (o `width`/`height` do `<svg>`).
  final double size;

  /// Cor do traço (`stroke`).
  final Color color;

  /// Espessura do traço (`stroke-width`) na escala 24.
  final double strokeWidth;

  /// Cor de preenchimento (`fill`). Nulo = `fill: none`.
  final Color? fill;

  /// Texto para leitor de tela. Nulo = decorativo (como `aria-hidden`).
  final String? semanticLabel;

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static String _alpha(Color c) =>
      ((c.toARGB32() >> 24) / 255).toStringAsFixed(3);

  String _svg() {
    final f = fill;
    final fillAttr =
        f == null ? 'fill="none"' : 'fill="${_hex(f)}" fill-opacity="${_alpha(f)}"';
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
        'width="24" height="24" $fillAttr '
        'stroke="${_hex(color)}" stroke-opacity="${_alpha(color)}" '
        'stroke-width="$strokeWidth" stroke-linecap="round" '
        'stroke-linejoin="round">${glyph.svgBody}</svg>';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(
        _svg(),
        width: size,
        height: size,
        excludeFromSemantics: semanticLabel == null,
        semanticsLabel: semanticLabel,
      ),
    );
  }
}
