import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/data/child/child_achievements_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// "Conquistas" (`Home-rolagem.dc.html`, `<section aria-label="Conquistas">`):
/// título, link "Ver todas" e até 4 conquistas numa grade de 4 colunas.
///
/// O banco só guarda emoji (sem ícone nem cor por conquista), então cada
/// item é um círculo dourado com o emoji. A conquista bloqueada do mockup
/// não aparece: não há catálogo (DECISOES 7).
class HomeBAchievements extends StatelessWidget {
  const HomeBAchievements({
    super.key,
    required this.conquistas,
    required this.onVerTodas,
  });

  static const _colunas = 4;

  /// Só as conquistadas, mais recentes primeiro (mostra as 4 primeiras).
  final List<ChildAchievement> conquistas;
  final VoidCallback onVerTodas;

  @override
  Widget build(BuildContext context) {
    final visiveis = conquistas.take(_colunas).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(child: SectionTitle(titulo: 'Conquistas')),
            const SizedBox(width: 8),
            ThemeLink(rotulo: 'Ver todas', gap: 2, onTap: onVerTodas),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _colunas; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: i < visiveis.length
                    ? _Item(conquista: visiveis[i])
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.conquista});

  final ChildAchievement conquista;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Conquista: ${conquista.titulo}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: LummyColors.brandGold,
            ),
            child: Text(
              conquista.emoji,
              style: LummyText.poppins(context, size: 26, height: 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            conquista.titulo,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: LummyText.poppins(context, size: 12, height: 1.3),
          ),
        ],
      ),
    );
  }
}
