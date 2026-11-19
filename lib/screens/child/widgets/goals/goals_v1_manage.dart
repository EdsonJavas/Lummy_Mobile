import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'goals_v1_simulator.dart';

/// Seção "Gerenciar meta" (`Metas-rolagem.dc.html`). Só com meta em andamento.
///
/// "Editar meta" do mockup não aparece porque o app não tem essa função
/// (DECISOES 7); "Desistir da meta" ocupa a largura toda.
class GoalsV1Manage extends StatelessWidget {
  const GoalsV1Manage({
    super.key,
    required this.nomeDaMeta,
    required this.onDesistir,
  });

  final String nomeDaMeta;

  /// Nulo = botão desabilitado (ex.: enquanto a meta está sendo removida).
  final VoidCallback? onDesistir;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GoalsV1InfoLine(
          texto:
              'Uma meta por vez. Quando conquistar a meta $nomeDaMeta, você escolhe a próxima.',
        ),
        const SizedBox(height: 12),
        LummyPressable(
          onTap: onDesistir,
          semanticLabel: 'Desistir da meta',
          pressedScale: 0.98,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LummyColors.surface100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LummyIcon(
                  LummyGlyphs.trash,
                  size: 17,
                  color: LummyColors.danger700,
                  strokeWidth: 2.2,
                ),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: Text(
                    'Desistir da meta',
                    style: LummyText.poppins(
                      size: 14,
                      weight: FontWeight.w600,
                      color: LummyColors.danger700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
