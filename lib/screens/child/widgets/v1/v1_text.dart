import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';

/// Estilos de texto do redesenho infantil V1 (tabela do RELATORIO, seção 2.1).
///
/// Regras:
/// - [poppins] e [fredoka] reproduzem o CSS: `height` só quando o mockup
///   declara `line-height`; sem ele, o Poppins usa [alturaNormalPoppins]
///   (o `normal` do Chrome). `letterSpacing` sempre 0, para não herdar o
///   0,25 do Material 3.
/// - O espaço extra da linha é dividido igualmente em cima e embaixo
///   (`TextLeadingDistribution.even`), como o navegador faz.
/// - Cor padrão = tinta do tema atual (`context.cores.tinta`: `#0B1533` no
///   claro). Por isso os estilos recebem o `context`; os que são sempre
///   brancos (sobre o tema ou o cartão espacial) não precisam dele.
abstract final class LummyText {
  /// Poppins (`LummyFonts.body`) com os valores do mockup.
  static TextStyle poppins(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return _poppins(
      size: size,
      weight: weight,
      color: color ?? LummyCores.of(context).tinta,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle _poppins({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    TextDecoration? decoration,
  }) {
    return LummyFonts.body(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? alturaNormalPoppins(size),
      letterSpacing: 0,
      decoration: decoration,
      decorationColor: color,
    ).copyWith(leadingDistribution: TextLeadingDistribution.even);
  }

  /// `line-height: normal` do Poppins como o Chrome do mockup calcula:
  /// ascendente 1,05, descendente 0,35 e lineGap 0,10 do tamanho, cada um
  /// arredondado para o pixel inteiro (12→18, 13→20, 14→21, 15→23, 18→27,
  /// 24→35). Sem isto o texto herda o height 1.43 do Material 3.
  static double alturaNormalPoppins(double size) =>
      ((size * 1.05).roundToDouble() +
          (size * 0.35).roundToDouble() +
          (size * 0.10).roundToDouble()) /
      size;

  /// Fredoka (`LummyFonts.rounded`), sempre peso 600 no mockup.
  static TextStyle fredoka(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return _fredoka(
      size: size,
      weight: weight,
      color: color ?? LummyCores.of(context).tinta,
      height: height,
    );
  }

  static TextStyle _fredoka({
    required double size,
    FontWeight weight = FontWeight.w600,
    required Color color,
    double? height,
  }) {
    return LummyFonts.rounded(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: 0,
    ).copyWith(leadingDistribution: TextLeadingDistribution.even);
  }

  // ── Fredoka ──

  /// "Oi, Ana!" (Home): Fredoka 600 22, lh 1.15.
  static TextStyle saudacao(BuildContext context) =>
      fredoka(context, size: 22, height: 1.15);

  /// Título de tela "Gastos", "Metas": Fredoka 600 26, lh 1.2.
  static TextStyle h1(BuildContext context) =>
      fredoka(context, size: 26, height: 1.2);

  /// Valor do cofrinho (Home): Fredoka 600 42, lh 1.1, branco.
  static TextStyle valorCofrinho() =>
      _fredoka(size: 42, height: 1.1, color: LummyColors.white);

  /// Valor da meta (Metas): Fredoka 600 40, lh 1.1, branco.
  static TextStyle valorMeta() =>
      _fredoka(size: 40, height: 1.1, color: LummyColors.white);

  /// Total do período (Gastos): Fredoka 600 44, lh 1.1.
  static TextStyle valorResumo(BuildContext context) =>
      fredoka(context, size: 44, height: 1.1);

  /// Valor digitado no painel: Fredoka 600 46, lh 1.1.
  static TextStyle valorPainel(BuildContext context) =>
      fredoka(context, size: 46, height: 1.1);

  /// Nome da meta no cartão de Metas: Fredoka 600 24, lh 1.2, branco.
  static TextStyle tituloMeta() =>
      _fredoka(size: 24, height: 1.2, color: LummyColors.white);

  /// Nome no menu lateral: Fredoka 600 22, lh 1.2.
  static TextStyle nomeMenu(BuildContext context) =>
      fredoka(context, size: 22, height: 1.2);

  /// Letra do avatar (branca). 44 → 20; 56 → 24; 40 → 18 (proposta D6).
  static TextStyle letraAvatar(double avatarSize) {
    final double fs;
    if (avatarSize >= 56) {
      fs = 24;
    } else if (avatarSize >= 44) {
      fs = 20;
    } else if (avatarSize >= 40) {
      fs = 18;
    } else {
      fs = (avatarSize * 0.45).roundToDouble();
    }
    return _fredoka(size: fs, color: LummyColors.white);
  }

  // ── Poppins ──

  /// Título de seção (h2) e título do painel: Poppins 600 18.
  static TextStyle h2(BuildContext context) =>
      poppins(context, size: 18, weight: FontWeight.w600);

  /// Texto de apoio abaixo do h2: Poppins 400 13 `#5B6478`.
  static TextStyle apoio(BuildContext context) =>
      poppins(context, size: 13, color: LummyCores.of(context).tintaApoio);

  /// Contagem ao lado do h2 ("2 de 5"): Poppins 600 13 `#5B6478`.
  static TextStyle contagem(BuildContext context) => poppins(
        context,
        size: 13,
        weight: FontWeight.w600,
        color: LummyCores.of(context).tintaApoio,
      );

  /// Corpo de item de lista: Poppins 500 15.
  static TextStyle corpo(
    BuildContext context, {
    FontWeight weight = FontWeight.w500,
  }) =>
      poppins(context, size: 15, weight: weight);

  /// Rótulo de pergunta do painel ("Com o quê?"): Poppins 600 14.
  static TextStyle pergunta(BuildContext context) =>
      poppins(context, size: 14, weight: FontWeight.w600);

  /// Link na cor do tema: Poppins 600 14 (passe a cor do tema). No escuro a
  /// cor clareia para manter o contraste ([LummyCores.realce]).
  static TextStyle link(BuildContext context, Color tema) => poppins(
        context,
        size: 14,
        weight: FontWeight.w600,
        color: LummyCores.of(context).realce(tema),
      );
}
