import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';

import 'child_shell_scope.dart';
import 'v1_text.dart';

/// Avatar da criança: círculo na cor do tema com a inicial em Fredoka branca.
///
/// Tamanhos do mockup: 44 (Home), 56 (menu lateral) e 40 (Gastos, Metas,
/// Aprender; desvio D6). A inicial vem do `ChildProfileController`, a não ser
/// que [inicial] seja passada.
///
/// Toque: por padrão abre o menu lateral (`ChildShellScope.openDrawer`).
/// Passe [onTap] para outro comportamento, ou `tappable: false` para só exibir
/// (o avatar de 56 dentro do menu lateral).
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    this.size = 44,
    this.inicial,
    this.onTap,
    this.tappable = true,
  });

  final double size;
  final String? inicial;
  final VoidCallback? onTap;
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    final tema = ChildThemeColorController.of(context).tema;
    final letra = inicial ?? ChildProfileController.of(context).inicial;

    final circulo = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tema, shape: BoxShape.circle),
      child: Text(letra, style: LummyText.letraAvatar(size)),
    );

    if (!tappable) return ExcludeSemantics(child: circulo);

    return Semantics(
      button: true,
      label: 'Abrir menu',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () => ChildShellScope.read(context)?.openDrawer(),
        child: circulo,
      ),
    );
  }
}
