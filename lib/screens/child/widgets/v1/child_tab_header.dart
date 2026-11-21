import 'package:flutter/material.dart';

import 'child_avatar.dart';
import 'v1_text.dart';

/// Cabeçalho das abas Gastos, Metas (e o padrão para Aprender):
/// avatar 40 na cor do tema + título h1 (Fredoka 600 26), e um [trailing]
/// opcional à direita (ex.: o botão "Anotar gasto" de Gastos).
///
/// Mockup: `<header style="display:flex; align-items:center;
/// justify-content:space-between; gap:12px">` (`Gastos-mes.dc.html`).
/// O avatar à esquerda do título é desvio consciente do mockup (DECISOES 6).
/// O espaço em volta (padding `16px 20px 0`) é da tela, não deste widget.
class ChildTabHeader extends StatelessWidget {
  const ChildTabHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ChildAvatar(size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: LummyText.h1(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}
