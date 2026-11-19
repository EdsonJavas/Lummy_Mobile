import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';

import 'lummy_astronaut.dart';

/// Uma estrelinha do cartão espacial (`<span aria-hidden style="position:
/// absolute; left; top; width; height; border-radius; background; opacity">`).
class SpaceStar {
  const SpaceStar(this.left, this.top, this.size, this.radius, this.color,
      [this.opacity = 1]);

  final double left;
  final double top;
  final double size;
  final double radius;
  final Color color;
  final double opacity;
}

/// Estrelas do mockup, com as posições exatas.
abstract final class SpaceStars {
  /// Cofrinho da Home (`Main.dc.html`). A 9ª (left 352) cai fora dos 350 de
  /// largura e é cortada, como no mockup.
  static const cofrinho = <SpaceStar>[
    SpaceStar(172, 26, 3, 2, LummyColors.white, 0.8),
    SpaceStar(214, 70, 3, 2, LummyColors.starGold),
    SpaceStar(150, 98, 2, 1, LummyColors.white, 0.7),
    SpaceStar(250, 16, 2, 1, LummyColors.white, 0.9),
    SpaceStar(330, 140, 3, 2, LummyColors.white, 0.6),
    SpaceStar(118, 44, 2, 1, LummyColors.white, 0.6),
    SpaceStar(290, 176, 2, 1, LummyColors.white, 0.7),
    SpaceStar(200, 128, 3, 2, LummyColors.white, 0.5),
    SpaceStar(352, 34, 2, 1, LummyColors.starGold),
  ];

  /// Cartão "Sua meta agora" (`Metas-atual.dc.html`).
  static const meta = <SpaceStar>[
    SpaceStar(230, 22, 3, 2, LummyColors.white, 0.8),
    SpaceStar(300, 64, 2, 1, LummyColors.starGold),
    SpaceStar(330, 18, 2, 1, LummyColors.white, 0.7),
    SpaceStar(262, 96, 3, 2, LummyColors.white, 0.5),
    SpaceStar(200, 120, 2, 1, LummyColors.white, 0.7),
    SpaceStar(340, 110, 3, 2, LummyColors.white, 0.6),
  ];
}

/// Fundo "espaço" na cor do tema: `spaceBase` + brilho radial `spaceGlow`.
///
/// Reproduz `radial-gradient(circle at X% Y%, spaceGlow 0%, transparent S%),
/// spaceBase`: o círculo vai até o canto mais distante do centro (padrão do
/// CSS) e o brilho some em [glowStop] desse raio. A cor final do degradê é o
/// próprio brilho com alfa 0, para não escurecer no meio (o navegador mistura
/// com alfa pré-multiplicado).
///
/// Use direto para formas que não são o cartão (ex.: o círculo de 56 da Dica
/// do Lummy: `glowCenter: Offset(0.7, 0.25)`, `glowStop: 0.7`, `circle: true`).
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({
    super.key,
    required this.child,
    this.glowCenter = const Offset(0.82, 0.22),
    this.glowStop = 0.58,
    this.borderRadius = 24,
    this.circle = false,
    this.stars = const [],
    this.overlay = const [],
  });

  /// Conteúdo (fica entre o fundo e as estrelas, como no HTML).
  final Widget child;

  /// Centro do brilho em frações da caixa (0,82 e 0,22 = "82% 22%").
  final Offset glowCenter;

  /// Onde o brilho fica transparente (0,58 = "transparent 58%").
  final double glowStop;

  /// Raio dos cantos (ignorado se [circle]).
  final double borderRadius;

  /// Recorte em círculo.
  final bool circle;

  /// Estrelinhas (posição absoluta a partir do canto de cima à esquerda).
  final List<SpaceStar> stars;

  /// Outros elementos absolutos pintados por cima de tudo (ex.: astronauta).
  /// Devem ser `Positioned`.
  final List<Widget> overlay;

  @override
  Widget build(BuildContext context) {
    final cores = ChildThemeColorController.of(context);
    final conteudo = Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SpaceGlowPainter(
              base: cores.spaceBase,
              glow: cores.spaceGlow,
              center: glowCenter,
              stop: glowStop,
            ),
          ),
        ),
        child,
        for (final s in stars)
          Positioned(
            left: s.left,
            top: s.top,
            child: IgnorePointer(
              child: Opacity(
                opacity: s.opacity,
                child: Container(
                  width: s.size,
                  height: s.size,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(s.radius),
                  ),
                ),
              ),
            ),
          ),
        ...overlay,
      ],
    );
    if (circle) return ClipOval(child: conteudo);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: conteudo,
    );
  }
}

class _SpaceGlowPainter extends CustomPainter {
  _SpaceGlowPainter({
    required this.base,
    required this.glow,
    required this.center,
    required this.stop,
  });

  final Color base;
  final Color glow;
  final Offset center;
  final double stop;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);
    final c = Offset(center.dx * size.width, center.dy * size.height);
    final cantoMaisLonge = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ].map((p) => (p - c).distance).reduce(math.max);
    final raio = cantoMaisLonge * stop;
    if (raio <= 0) return;
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        c,
        raio,
        [glow, glow.withValues(alpha: 0)],
        const [0, 1],
        TileMode.clamp,
      );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_SpaceGlowPainter old) =>
      old.base != base ||
      old.glow != glow ||
      old.center != center ||
      old.stop != stop;
}

/// Cartão espacial: o cofrinho da Home e o cartão "Sua meta agora" de Metas.
///
/// Raio 24, padding `20px 22px`, texto branco (os estilos são de quem usa).
/// - [SpaceCard.cofrinho]: altura FIXA 236, brilho a 82%/22% até 58%,
///   9 estrelas e o astronauta (102×130, `right 12, top 8`, 8°).
/// - [SpaceCard.meta]: altura pelo conteúdo, brilho a 85%/15% até 55%,
///   6 estrelas, sem astronauta.
class SpaceCard extends StatelessWidget {
  const SpaceCard({
    super.key,
    required this.child,
    this.height,
    this.linhasDeTexto = const [],
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
    this.glowCenter = const Offset(0.82, 0.22),
    this.glowStop = 0.58,
    this.stars = SpaceStars.cofrinho,
    this.overlay = const [],
    this.semanticLabel,
  });

  /// Cofrinho da Home (`Main.dc.html`, `<section aria-label="Meu cofrinho">`).
  /// O [child] é a coluna de dentro (rótulo, valor e, embaixo, o bloco da meta
  /// com `Spacer` antes: o HTML usa `margin-top: auto`).
  const SpaceCard.cofrinho({super.key, required this.child, this.semanticLabel = 'Meu cofrinho'})
      : height = 236,
        // (tamanho da fonte, altura da linha) de "Meu cofrinho", do valor,
        // de "Rumo à meta" e da legenda da trilha.
        linhasDeTexto = const [(13, 20), (42, 46.2), (15, 23), (13, 20)],
        padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        glowCenter = const Offset(0.82, 0.22),
        glowStop = 0.58,
        stars = SpaceStars.cofrinho,
        overlay = const [
          Positioned(
            right: 12,
            top: 8,
            child: IgnorePointer(
              child: LummyAstronaut(width: 102, height: 130, rotationDegrees: 8),
            ),
          ),
        ];

  /// Cartão "Sua meta agora" (`Metas-atual.dc.html`). O [child] é a coluna
  /// com `gap: 16px`.
  const SpaceCard.meta({super.key, required this.child, this.semanticLabel = 'Sua meta agora'})
      : height = null,
        linhasDeTexto = const [],
        padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        glowCenter = const Offset(0.85, 0.15),
        glowStop = 0.55,
        stars = SpaceStars.meta,
        overlay = const [];

  final Widget child;
  final double? height;

  /// Com [height] fixa: textos de dentro como (tamanho, altura da linha). Com
  /// a fonte do sistema aumentada, o cartão cresce o que esses textos crescem,
  /// em vez de estourar.
  final List<(double, double)> linhasDeTexto;
  final EdgeInsets padding;
  final Offset glowCenter;
  final double glowStop;
  final List<SpaceStar> stars;
  final List<Widget> overlay;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget card = SpaceBackground(
      glowCenter: glowCenter,
      glowStop: glowStop,
      borderRadius: 24,
      stars: stars,
      overlay: overlay,
      child: Padding(padding: padding, child: child),
    );
    final h = height;
    if (h != null) {
      final escala = MediaQuery.textScalerOf(context);
      var extra = 0.0;
      for (final (tamanho, linha) in linhasDeTexto) {
        extra += linha * (escala.scale(tamanho) / tamanho - 1);
      }
      card = SizedBox(
        height: h + math.max(0, extra),
        width: double.infinity,
        child: card,
      );
    } else {
      card = SizedBox(width: double.infinity, child: card);
    }
    return Semantics(container: true, label: semanticLabel, child: card);
  }
}
