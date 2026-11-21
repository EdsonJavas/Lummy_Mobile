import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/models/goal.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Tile circular de 56 do cartão espacial (ícone da meta).
///
/// Mockup: 56×56, fundo branco 12%, borda 1,5 branca 28%, ícone 28 branco
/// traço 2.
class GoalsV1IconTile extends StatelessWidget {
  const GoalsV1IconTile({super.key, required this.glyph});

  final LummyGlyph glyph;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LummyColors.white12,
        shape: BoxShape.circle,
        border: Border.all(color: LummyColors.white28, width: 1.5),
      ),
      child: LummyIcon(glyph, size: 28, color: LummyColors.white, strokeWidth: 2),
    );
  }
}

/// Cartão "Sua meta agora" (`Metas-atual.dc.html`), com a meta em andamento.
///
/// O valor mostrado é o saldo do cofrinho limitado ao alvo (`meta.currentAmount`
/// já vem sincronizado do repositório).
class GoalsV1Card extends StatelessWidget {
  const GoalsV1Card({
    super.key,
    required this.meta,
    required this.progresso,
    required this.falta,
  });

  final Goal meta;

  /// 0..1 (saldo / alvo).
  final double progresso;

  /// Quanto falta, em reais.
  final double falta;

  @override
  Widget build(BuildContext context) {
    return SpaceCard.meta(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GoalsV1IconTile(glyph: GoalIcon.doEmoji(meta.emoji)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sua meta agora',
                      style: LummyText.poppins(
                        context,
                        size: 13,
                        weight: FontWeight.w500,
                        color: LummyColors.white75,
                      ),
                    ),
                    Text(
                      meta.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LummyText.tituloMeta(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Valor guardado + alvo, alinhados pela linha de base. Em telas
          // estreitas ou valores longos, encolhe em vez de estourar.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  V1Format.brl(meta.currentAmount),
                  maxLines: 1,
                  style: LummyText.valorMeta(),
                ),
                const SizedBox(width: 8),
                Text(
                  'de ${V1Format.brl(meta.targetAmount)}',
                  maxLines: 1,
                  style: LummyText.poppins(context, size: 15, color: LummyColors.white75),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GoalTrail(
            progress: progresso,
            semanticLabel: 'Progresso da meta ${meta.name}',
          ),
          const SizedBox(height: 16),
          GoalTrailLegend(
            esquerda: '${V1Format.porcento(progresso)} do caminho',
            direita: 'Faltam ${V1Format.brl(falta)}',
          ),
        ],
      ),
    );
  }
}
