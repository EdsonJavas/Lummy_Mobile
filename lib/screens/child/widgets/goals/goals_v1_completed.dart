import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/models/goal.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'goals_v1_calc.dart';

/// Seção "Metas conquistadas" (`Metas-rolagem.dc.html`). Só é usada quando há
/// pelo menos uma meta concluída.
class GoalsV1Completed extends StatelessWidget {
  const GoalsV1Completed({super.key, required this.metas});

  /// Da mais recente para a mais antiga.
  final List<Goal> metas;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(titulo: 'Metas conquistadas', contagem: '${metas.length}'),
        const SizedBox(height: 8),
        for (final meta in metas) _CompletedItem(meta: meta),
      ],
    );
  }
}

class _CompletedItem extends StatelessWidget {
  const _CompletedItem({required this.meta});

  final Goal meta;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        // min-height: 64px de conteúdo + 1 da borda de baixo (content-box).
        constraints: const BoxConstraints(minHeight: 65),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: LummyColors.line100)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: LummyColors.brandGold,
                shape: BoxShape.circle,
              ),
              child: LummyIcon(
                GoalIcon.doEmoji(meta.emoji),
                size: 20,
                color: LummyColors.ink900,
                strokeWidth: 2.1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                // Nome em 2 linhas não encosta nas bordas do item.
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LummyText.corpo(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      GoalsV1Calc.legendaConquistada(meta),
                      style: LummyText.apoio(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            const LummyIcon(
              LummyGlyphs.check,
              size: 20,
              color: LummyColors.brandGreen,
              strokeWidth: 2.4,
              semanticLabel: 'Conquistada',
            ),
          ],
        ),
      ),
    );
  }
}
