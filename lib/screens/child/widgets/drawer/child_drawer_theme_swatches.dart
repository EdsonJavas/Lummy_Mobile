import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/lummy_icon.dart';
import 'package:lummy/screens/child/widgets/v1/v1_text.dart';

/// As 3 bolinhas de "Cor do app" (`Drawer-crianca.dc.html`, seção "Cor do app").
///
/// Grade de 3 colunas iguais com `gap: 8px`. Cada opção é um botão em coluna
/// (`gap: 8px`): bolinha 40×40 na própria cor e rótulo Poppins 12. A escolhida
/// ganha o anel (3 px de vão + 2 px da cor), o `check` 18 branco traço 3 e o
/// rótulo em 600.
///
/// Não depende do `ChildShellScope`: serve no menu lateral e no Perfil (que é
/// empurrado por cima da casca). No Perfil, que pode estar em tema escuro,
/// passe as cores dos rótulos e a cor do vão do anel.
class ChildThemeColorSwatches extends StatelessWidget {
  const ChildThemeColorSwatches({
    super.key,
    this.corRotuloEscolhido,
    this.corRotulo,
    this.corDoVao,
  });

  /// Cor do rótulo da opção escolhida (mockup: tinta).
  /// Padrão: `context.cores.tinta`.
  final Color? corRotuloEscolhido;

  /// Cor do rótulo das outras opções (mockup: texto de apoio).
  /// Padrão: `context.cores.tintaApoio`.
  final Color? corRotulo;

  /// Cor do vão de 3 px entre a bolinha e o anel. Nulo = branco do mockup
  /// (`LummyShadows.swatchRing`). No Perfil é a cor do cartão.
  final Color? corDoVao;

  @override
  Widget build(BuildContext context) {
    final cores = ChildThemeColorController.of(context);
    final opcoes = cores.opcoes;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Escolher a cor do app',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < opcoes.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _Swatch(
                opcao: opcoes[i],
                escolhida: opcoes[i] == cores.opcao,
                corRotuloEscolhido: corRotuloEscolhido ?? context.cores.tinta,
                corRotulo: corRotulo ?? context.cores.tintaApoio,
                corDoVao: corDoVao ?? context.cores.superficie,
                onTap: () => context
                    .read<ChildThemeColorController>()
                    .selecionar(opcoes[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.opcao,
    required this.escolhida,
    required this.corRotuloEscolhido,
    required this.corRotulo,
    required this.corDoVao,
    required this.onTap,
  });

  static const _duracao = Duration(milliseconds: 200);

  final ChildThemeColor opcao;
  final bool escolhida;
  final Color corRotuloEscolhido;
  final Color corRotulo;
  final Color? corDoVao;
  final VoidCallback onTap;

  List<BoxShadow> _anel() {
    final vao = corDoVao;
    if (vao == null) return LummyShadows.swatchRing(opcao.color);
    // Mesmo anel do mockup, com o vão na cor do fundo de quem usa.
    return [
      BoxShadow(color: opcao.color, spreadRadius: 5),
      BoxShadow(color: vao, spreadRadius: 3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: escolhida,
      label: opcao.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: _duracao,
              curve: Curves.easeOut,
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: opcao.color,
                shape: BoxShape.circle,
                boxShadow: escolhida ? _anel() : const [],
              ),
              child: AnimatedOpacity(
                duration: _duracao,
                opacity: escolhida ? 1 : 0,
                child: const LummyIcon(
                  LummyGlyphs.check,
                  size: 18,
                  color: LummyColors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: _duracao,
              style: LummyText.poppins(
                context,
                size: 12,
                weight: escolhida ? FontWeight.w600 : FontWeight.w500,
                color: escolhida ? corRotuloEscolhido : corRotulo,
              ),
              child: Text(
                opcao.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
