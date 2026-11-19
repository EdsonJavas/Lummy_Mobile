import 'package:flutter/material.dart';

import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Ações rápidas da Home (`Main.dc.html`, `<nav aria-label="Ações rápidas">`):
/// 3 colunas iguais com `gap: 12px`. Laranja = mexer no dinheiro; verde =
/// guardar e progredir.
class HomeV1QuickActions extends StatelessWidget {
  const HomeV1QuickActions({
    super.key,
    required this.onPedirDinheiro,
    required this.onAnotarGasto,
    required this.onNovaMeta,
  });

  final VoidCallback onPedirDinheiro;
  final VoidCallback onAnotarGasto;
  final VoidCallback onNovaMeta;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Ações rápidas',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LummyActionSquare(
              glyph: LummyGlyphs.coins,
              rotulo: 'Pedir dinheiro',
              onTap: onPedirDinheiro,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LummyActionSquare(
              glyph: LummyGlyphs.shoppingBag,
              rotulo: 'Anotar gasto',
              onTap: onAnotarGasto,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LummyActionSquare(
              glyph: LummyGlyphs.target,
              rotulo: 'Nova meta',
              verde: true,
              onTap: onNovaMeta,
            ),
          ),
        ],
      ),
    );
  }
}
