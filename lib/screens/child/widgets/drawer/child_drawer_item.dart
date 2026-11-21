import 'package:flutter/material.dart';

import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/lummy_icon.dart';
import 'package:lummy/screens/child/widgets/v1/neutral_icon_tile.dart';
import 'package:lummy/screens/child/widgets/v1/v1_text.dart';

/// Item da lista do menu lateral (`Drawer-crianca.dc.html`, cada `<li>`).
///
/// Altura mínima 56, `gap: 12px`: quadrado neutro 40×40 raio 14 com ícone 20
/// tinta traço 2, rótulo Poppins 500 15 tinta (ocupa o resto) e, à direita,
/// [valor] opcional em Poppins 400 13 `#5B6478` ("2 de 5").
///
/// [valor] nulo = sem valor (ainda carregando, sem dado ou item sem número).
/// Quando chega, entra com um fade curto.
class ChildDrawerItem extends StatelessWidget {
  const ChildDrawerItem({
    super.key,
    required this.glyph,
    required this.rotulo,
    required this.onTap,
    this.valor,
  });

  final LummyGlyph glyph;
  final String rotulo;
  final String? valor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final valor = this.valor;

    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                NeutralIconTile(glyph: glyph),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rotulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LummyText.corpo(context),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: valor == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey(valor),
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            valor,
                            maxLines: 1,
                            softWrap: false,
                            style: LummyText.poppins(
                              context,
                              size: 13,
                              color: context.cores.tintaApoio,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
