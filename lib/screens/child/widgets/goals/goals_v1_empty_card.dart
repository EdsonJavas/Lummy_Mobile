import 'package:flutter/material.dart';

import 'package:lummy/models/goal.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'goals_v1_card.dart';

/// Cartão espacial dos estados que o mockup não desenhou (DECISOES 23):
/// - sem meta nenhuma: "Você ainda não tem uma meta";
/// - meta concluída ([ultimaConcluida] preenchida):
///   "Você conquistou {nome}! Escolha a próxima meta.".
///
/// Nos dois casos, o botão verde "Criar minha meta".
class GoalsV1EmptyCard extends StatelessWidget {
  const GoalsV1EmptyCard({
    super.key,
    required this.ultimaConcluida,
    required this.onCriarMeta,
  });

  /// Meta concluída mais recente; nula = a criança nunca teve meta concluída.
  final Goal? ultimaConcluida;

  final VoidCallback onCriarMeta;

  @override
  Widget build(BuildContext context) {
    final concluida = ultimaConcluida;
    final texto = concluida == null
        ? 'Você ainda não tem uma meta'
        : 'Você conquistou ${concluida.name}! Escolha a próxima meta.';

    return SpaceCard.meta(
      semanticLabel: concluida == null ? 'Sem meta' : 'Meta conquistada',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoalsV1IconTile(
            glyph: concluida == null
                ? LummyGlyphs.target
                : GoalIcon.doEmoji(concluida.emoji),
          ),
          const SizedBox(height: 16),
          Text(texto, style: LummyText.tituloMeta()),
          const SizedBox(height: 16),
          LummyWideButton(
            rotulo: 'Criar minha meta',
            verde: true,
            onTap: onCriarMeta,
          ),
        ],
      ),
    );
  }
}
