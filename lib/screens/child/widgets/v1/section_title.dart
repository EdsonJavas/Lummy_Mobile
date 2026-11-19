import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';

import 'lummy_icon.dart';
import 'v1_text.dart';

/// Título de seção (C-10): h2 Poppins 600 18 tinta; [contagem] opcional à
/// direita (Poppins 600 13 `#5B6478`, alinhada pela linha de base, `gap: 8px`);
/// [apoio] opcional embaixo (Poppins 400 13 `#5B6478`, `margin-top: 4px`).
///
/// Ex.: `SectionTitle(titulo: 'Missões de hoje', contagem: '2 de 5')`.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.titulo, this.contagem, this.apoio});

  final String titulo;
  final String? contagem;
  final String? apoio;

  @override
  Widget build(BuildContext context) {
    final tituloW = Semantics(
      header: true,
      child: Text(titulo, style: LummyText.h2()),
    );
    final linha = contagem == null
        ? tituloW
        : Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: tituloW),
              const SizedBox(width: 8),
              Text(contagem!, style: LummyText.contagem()),
            ],
          );
    if (apoio == null) return linha;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        linha,
        const SizedBox(height: 4),
        Text(apoio!, style: LummyText.apoio()),
      ],
    );
  }
}

/// Link de ação na cor do TEMA (DECISOES 3): "Ver todas as missões",
/// "Ver todos os gastos", "Ver todas", "Ver meu perfil".
///
/// Poppins 600 14 + `chevron-right` 18 traço 2.2, altura mínima 44.
/// [gap]: 4 em "Ver todas as missões"/"Ver todos os gastos"; 2 em
/// "Ver todas" (conquistas) e "Ver meu perfil".
/// [cor]: nulo = cor do tema. Branco no link "Criar uma meta" dentro do
/// cofrinho escuro (D23, sem mockup).
class ThemeLink extends StatelessWidget {
  const ThemeLink({
    super.key,
    required this.rotulo,
    required this.onTap,
    this.gap = 4,
    this.cor,
  });

  final String rotulo;
  final VoidCallback? onTap;
  final double gap;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final tema = cor ?? ChildThemeColorController.of(context).tema;
    return Semantics(
      button: true,
      label: rotulo,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(rotulo, style: LummyText.link(tema)),
              SizedBox(width: gap),
              LummyIcon(LummyGlyphs.chevronRight, size: 18, color: tema, strokeWidth: 2.2),
            ],
          ),
        ),
      ),
    );
  }
}
