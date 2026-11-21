import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';

import 'lummy_icon.dart';
import 'v1_text.dart';

/// Trilha da meta dentro do cartão espacial: trilho, preenchimento verde,
/// paradas (25/50/75%), foguete na posição atual e bandeira no fim.
///
/// Mockup (`Main.dc.html` e `Metas-atual.dc.html`, `role="progressbar"`):
/// - trilho 10 de altura, `margin-right: 12px`, raio 5, branco 22%;
/// - preenchimento `#2BD46F` na largura do progresso;
/// - parada alcançada: 16×16 dourada com estrela branca 10 (preenchida);
///   não alcançada: 16×16 `spaceBase` com borda 1,5 branca 55%
///   (regra dinâmica: PROPOSTA DO RELATOR, R2 6.3);
///   posição `left: calc(p% - 8px); top: -3px`;
/// - foguete 30×30 laranja, borda 3 `spaceBase`, ícone `rocket` 14 branco
///   traço 2.4, `left: calc(progresso% - 15px); top: -10px`;
/// - bandeira 24×24 branca, `flag` 12 tinta traço 2.6, `right: -12px; top: -7px`.
///
/// Ocupa só os 10 de altura no layout (os marcadores vazam, como no HTML).
/// O progresso é limitado a 0..1 para o foguete não sair do trilho.
class GoalTrail extends StatelessWidget {
  const GoalTrail({
    super.key,
    required this.progress,
    this.paradas = const [0.25, 0.5, 0.75],
    this.semanticLabel,
  });

  /// Fração da meta já guardada (saldo / alvo).
  final double progress;

  /// Frações das paradas desenhadas no trilho (a de 100% é a bandeira).
  final List<double> paradas;

  /// Ex.: "Progresso da meta bicicleta nova".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spaceBase = ChildThemeColorController.of(context).spaceBase;
    final p = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);

    return Semantics(
      label: semanticLabel,
      value: '${(p * 100).round()}%',
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: SizedBox(
          height: 10,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Trilho
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: LummyColors.white22,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  // Preenchimento
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: p),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => Container(
                        width: w * v,
                        decoration: BoxDecoration(
                          color: LummyColors.brandGreenBright,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  // Paradas
                  for (final parada in paradas)
                    Positioned(
                      left: w * parada - 8,
                      top: -3,
                      child: _Parada(alcancada: p >= parada, spaceBase: spaceBase),
                    ),
                  // Foguete
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: p),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, child) => Positioned(
                      left: w * v - 15,
                      top: -10,
                      child: child!,
                    ),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: LummyColors.orange600,
                        shape: BoxShape.circle,
                        border: Border.all(color: spaceBase, width: 3),
                      ),
                      child: const LummyIcon(
                        LummyGlyphs.rocket,
                        size: 14,
                        color: LummyColors.white,
                        strokeWidth: 2.4,
                      ),
                    ),
                  ),
                  // Bandeira
                  Positioned(
                    right: -12,
                    top: -7,
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: LummyColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const LummyIcon(
                        LummyGlyphs.flag,
                        size: 12,
                        color: LummyColors.ink900,
                        strokeWidth: 2.6,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Parada extends StatelessWidget {
  const _Parada({required this.alcancada, required this.spaceBase});

  final bool alcancada;
  final Color spaceBase;

  @override
  Widget build(BuildContext context) {
    if (alcancada) {
      return Container(
        width: 16,
        height: 16,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: LummyColors.brandGold,
          shape: BoxShape.circle,
        ),
        child: const LummyIcon(
          LummyGlyphs.star,
          size: 10,
          color: LummyColors.white,
          fill: LummyColors.white,
          strokeWidth: 2,
        ),
      );
    }
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: spaceBase,
        shape: BoxShape.circle,
        border: Border.all(color: LummyColors.white55, width: 1.5),
      ),
    );
  }
}

/// Legendas embaixo da trilha: à esquerda Poppins 500 13 branco 75%
/// ("62% de R$ 140,00" / "62% do caminho"); à direita Poppins 700 13 branco
/// ("Faltam R$ 53,50"). Linha `space-between` com `gap: 8px`.
class GoalTrailLegend extends StatelessWidget {
  const GoalTrailLegend({super.key, required this.esquerda, required this.direita});

  final String esquerda;
  final String direita;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            esquerda,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LummyText.poppins(
              context,
              size: 13,
              weight: FontWeight.w500,
              color: LummyColors.white75,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          direita,
          maxLines: 1,
          style: LummyText.poppins(
            context,
            size: 13,
            weight: FontWeight.w700,
            color: LummyColors.white,
          ),
        ),
      ],
    );
  }
}
