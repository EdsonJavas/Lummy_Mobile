import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Barra de nível da Home (`Main.dc.html`, bloco logo abaixo do `<header>`):
/// "Nível 4" à esquerda, "320 de 1000 XP" à direita (alinhados pela linha de
/// base, `gap: 8px`) e a barra dourada de 8 embaixo (`gap: 7px`).
///
/// O nível sobe a cada [ChildProfileController.xpPorNivel] pontos (regra do
/// banco), por isso o total é 1000 e não o "500" de exemplo do mockup.
class HomeV1Level extends StatelessWidget {
  const HomeV1Level({
    super.key,
    required this.level,
    required this.xpNoNivel,
    required this.progresso,
  });

  final int level;

  /// XP dentro do nível atual (0..999).
  final int xpNoNivel;

  /// Fração da barra (0..1).
  final double progresso;

  @override
  Widget build(BuildContext context) {
    const total = ChildProfileController.xpPorNivel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                'Nível $level',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LummyText.poppins(size: 13, weight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$xpNoNivel de $total XP',
              maxLines: 1,
              style: LummyText.poppins(size: 12, color: LummyColors.ink600),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Semantics(
          label: 'Experiência no nível $level',
          value: '$xpNoNivel de $total',
          child: ThinProgressBar(
            valor: progresso,
            cor: LummyColors.brandGold,
          ),
        ),
      ],
    );
  }
}
