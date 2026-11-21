import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/lessons_screen.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Cartão de aula rápida (`Home-rolagem.dc.html`, o `<button>` depois da
/// dica): quadrado 48 na cor do tema com `play`, "Aula de N min", o título e
/// uma seta.
///
/// DECISOES 7: usa a aula real que a `LessonsScreen` já tem
/// ([HomeBLessonCard.aulaRapida]); sem ela, quem usa esconde o cartão.
class HomeBLessonCard extends StatelessWidget {
  const HomeBLessonCard({super.key, required this.aula, required this.onTap});

  /// Id, no catálogo de aulas, da "Diferença entre querer e precisar".
  static const _idAulaRapida = '3';

  /// A aula mostrada na Home, ou nula se o catálogo não a tiver mais.
  static LessonItem? aulaRapida() {
    for (final aula in lessonsCatalog) {
      if (aula.id == _idAulaRapida) return aula;
    }
    return null;
  }

  final LessonItem aula;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = ChildThemeColorController.of(context).tema;
    final rotulo = 'Aula de ${aula.duration}';
    return LummyPressable(
      onTap: onTap,
      semanticLabel: '$rotulo: ${aula.title}',
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tema,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: LummyShadows.ink,
                ),
                child: const LummyIcon(
                  LummyGlyphs.play,
                  size: 18,
                  color: LummyColors.white,
                  fill: LummyColors.white,
                  strokeWidth: 2.2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rotulo,
                      style: LummyText.poppins(context, size: 12, color: context.cores.tintaApoio),
                    ),
                    Text(
                      aula.title,
                      style: LummyText.poppins(context, size: 15, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              LummyIcon(
                LummyGlyphs.chevronRight,
                size: 20,
                color: context.cores.iconeApagado,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
