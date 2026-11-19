import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';

import 'lummy_icon.dart';
import 'v1_text.dart';

/// Medidas do menu de baixo (C-1 do RELATORIO; `Main.dc.html`, `<nav>`).
abstract final class ChildBottomNavMetrics {
  /// Altura da cápsula.
  static const capsuleHeight = 72.0;

  /// Distância da cápsula até a borda de baixo (mais o inset do sistema).
  static const capsuleBottom = 18.0;

  /// Margem lateral da cápsula.
  static const capsuleSide = 16.0;

  /// Altura do degradê branco atrás da cápsula.
  static const fadeHeight = 104.0;

  /// Espaço que toda aba deve deixar no fim da rolagem para o último item
  /// ficar acima da cápsula: 104 + inset de baixo do sistema.
  static double scrollBottomPadding(BuildContext context) =>
      fadeHeight + MediaQuery.viewPaddingOf(context).bottom;
}

class _NavTab {
  const _NavTab(this.label, this.glyph);
  final String label;
  final LummyGlyph glyph;
}

const _tabs = <_NavTab>[
  _NavTab('Início', LummyGlyphs.house),
  _NavTab('Gastos', LummyGlyphs.receipt),
  _NavTab('Metas', LummyGlyphs.flag),
  _NavTab('Aprender', LummyGlyphs.bookOpen),
];

/// Cápsula flutuante do menu de baixo, na cor do tema.
///
/// Só a cápsula (72 de altura). Quem posiciona (`left/right 16`,
/// `bottom 18 + inset`) é `MainNavigation`.
class ChildBottomNavCapsule extends StatelessWidget {
  const ChildBottomNavCapsule({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tema = ChildThemeColorController.of(context).tema;
    // Altura fixa de 72: a fonte do sistema cresce até 1,6x aqui dentro (ícone
    // 22 + 3 + rótulo 12 × 1,5 × 1,6 = 53,8 < 60), para não estourar a 200%.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.6,
      child: _capsula(tema),
    );
  }

  Widget _capsula(Color tema) {
    return Semantics(
      container: true,
      label: 'Navegação principal',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: ChildBottomNavMetrics.capsuleHeight,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: tema,
          borderRadius: BorderRadius.circular(36),
          boxShadow: LummyShadows.capsule,
        ),
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: _NavButton(
                  tab: _tabs[i],
                  selected: i == currentIndex,
                  tema: tema,
                  onTap: () => onTap(i),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.tab,
    required this.selected,
    required this.tema,
    required this.onTap,
  });

  final _NavTab tab;
  final bool selected;
  final Color tema;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? tema : LummyColors.white;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          splashColor: LummyColors.white22,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected ? LummyColors.white : LummyColors.white.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LummyIcon(
                  tab.glyph,
                  size: 22,
                  color: fg,
                  strokeWidth: selected ? 2.2 : 2,
                ),
                const SizedBox(height: 3),
                Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: LummyText.poppins(
                    size: 12,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: fg,
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

/// Degradê branco atrás da cápsula: esconde o conteúdo que rola por baixo.
/// `linear-gradient(rgba(255,255,255,0), #FFFFFF 60%)`, altura 104 + inset.
/// Não recebe toques.
class ChildBottomFade extends StatelessWidget {
  const ChildBottomFade({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: ChildBottomNavMetrics.fadeHeight +
            MediaQuery.viewPaddingOf(context).bottom,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LummyColors.white.withValues(alpha: 0), LummyColors.white],
            stops: const [0, 0.6],
          ),
        ),
      ),
    );
  }
}
