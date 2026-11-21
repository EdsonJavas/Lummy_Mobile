import 'package:flutter/material.dart';

import 'package:lummy/core/theme/lummy_cores.dart';

/// Barra fina de progresso (C-9): trilho `#EEF0F4` e preenchimento [cor].
///
/// - Nível (Home): altura 8, raio 4, dourado `#F5B000`.
/// - Categoria ("Onde foi seu dinheiro"): altura 8, raio 4, `#2B3654`.
/// O preenchimento anima de leve (400 ms) quando o valor muda.
class ThinProgressBar extends StatelessWidget {
  const ThinProgressBar({
    super.key,
    required this.valor,
    required this.cor,
    this.altura = 8,
    this.raio = 4,
    this.fundo,
  });

  /// Fração preenchida (0..1; fora disso é limitada).
  final double valor;
  final Color cor;
  final double altura;
  final double raio;
  /// Trilho. Padrão: `context.cores.linha`.
  final Color? fundo;

  @override
  Widget build(BuildContext context) {
    final v = valor.isNaN ? 0.0 : valor.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: Container(
        height: altura,
        color: fundo ?? context.cores.linha,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: v),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) => FractionallySizedBox(
            widthFactor: t,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(raio),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
