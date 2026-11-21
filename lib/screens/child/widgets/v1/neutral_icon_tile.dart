import 'package:flutter/material.dart';

import 'package:lummy/core/theme/lummy_cores.dart';

import 'lummy_icon.dart';

/// Quadrado de ícone neutro (C-8 do RELATORIO).
///
/// - 40×40 raio 14 com ícone 20: itens do menu lateral, "Onde foi seu dinheiro".
/// - 44×44 raio 14 com ícone 20: "Últimos gastos".
/// - 48×48 raio 16 com ícone 22: categorias do painel (não escolhida).
/// Fundo `#F2F4F7`, ícone tinta traço 2 (padrões; todos ajustáveis).
class NeutralIconTile extends StatelessWidget {
  const NeutralIconTile({
    super.key,
    required this.glyph,
    this.size = 40,
    this.radius = 14,
    this.iconSize = 20,
    this.background,
    this.iconColor,
    this.strokeWidth = 2,
  });

  final LummyGlyph glyph;
  final double size;
  final double radius;
  final double iconSize;
  /// Padrão: `context.cores.superficieNeutra`.
  final Color? background;

  /// Padrão: `context.cores.tinta`.
  final Color? iconColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? context.cores.superficieNeutra,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: LummyIcon(glyph, size: iconSize, color: iconColor ?? context.cores.tinta, strokeWidth: strokeWidth),
    );
  }
}
