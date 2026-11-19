import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

import 'lummy_icon.dart';
import 'v1_text.dart';

/// Retorno tátil sutil comum aos botões V1: encolhe para 96% ao pressionar.
/// (O mockup não desenha o estado pressionado; este é o padrão da força-tarefa.)
class LummyPressable extends StatefulWidget {
  const LummyPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.pressedScale = 0.96,
  });

  final Widget child;

  /// Nulo = desabilitado (fica com 50% de opacidade).
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double pressedScale;

  @override
  State<LummyPressable> createState() => _LummyPressableState();
}

class _LummyPressableState extends State<LummyPressable> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v && mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1 : 0.5,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            scale: _pressed ? widget.pressedScale : 1,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Atalho quadrado da Home: quadrado 56×56 raio 18 + rótulo embaixo.
///
/// `Main.dc.html`, `<nav aria-label="Ações rápidas">`:
/// - laranja `#EA580C` com sombra laranja ("Pedir dinheiro", "Anotar gasto");
/// - verde `#12A150` com sombra verde ("Nova meta");
/// - ícone 25 branco traço 2.2; rótulo Poppins 500 13 tinta; `gap: 8px`.
class LummyActionSquare extends StatelessWidget {
  const LummyActionSquare({
    super.key,
    required this.glyph,
    required this.rotulo,
    required this.onTap,
    this.verde = false,
  });

  final LummyGlyph glyph;
  final String rotulo;
  final VoidCallback? onTap;

  /// true = verde (guardar/progredir); false = laranja (mexer no dinheiro).
  final bool verde;

  @override
  Widget build(BuildContext context) {
    return LummyPressable(
      onTap: onTap,
      semanticLabel: rotulo,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: verde ? LummyColors.brandGreen : LummyColors.orange600,
              borderRadius: BorderRadius.circular(18),
              boxShadow: verde ? LummyShadows.green : LummyShadows.orange,
            ),
            child: LummyIcon(glyph, size: 25, color: LummyColors.white, strokeWidth: 2.2),
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: Text(
              rotulo,
              textAlign: TextAlign.center,
              style: LummyText.poppins(size: 13, weight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pílula laranja de 44: "Anotar gasto" do topo de Gastos (`Gastos-mes.dc.html`).
///
/// Altura 44, raio 22, `#EA580C`, sombra laranja; com ícone:
/// `padding: 0 16px 0 12px`, `gap: 6px`, ícone 18 branco traço 2.2; texto
/// Poppins 700 15 branco. Sem ícone (ex.: "Retirar", D20): padding 0 16.
class LummyPillButton extends StatelessWidget {
  const LummyPillButton({
    super.key,
    required this.rotulo,
    required this.onTap,
    this.glyph,
    this.cor = LummyColors.orange600,
  });

  final String rotulo;
  final VoidCallback? onTap;
  final LummyGlyph? glyph;

  /// Laranja por padrão (botão de dinheiro). Texto e ícone sempre brancos.
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final g = glyph;
    return LummyPressable(
      onTap: onTap,
      semanticLabel: rotulo,
      child: Container(
        height: 44,
        padding: EdgeInsets.only(left: g == null ? 16 : 12, right: 16),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: cor == LummyColors.orange600 ? LummyShadows.orange : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (g != null) ...[
              LummyIcon(g, size: 18, color: LummyColors.white, strokeWidth: 2.2),
              const SizedBox(width: 6),
            ],
            ExcludeSemantics(
              child: Text(
                rotulo,
                maxLines: 1,
                softWrap: false,
                style: LummyText.poppins(
                  size: 15,
                  weight: FontWeight.w700,
                  color: LummyColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão largo de 56: "Salvar gasto" (laranja, `Anotar-gasto.dc.html`) e
/// "Criar minha meta" (verde, D23).
///
/// Altura 56, largura total, raio 28; laranja com sombra
/// `0 10px 22px rgba(234,88,12,0.28)`; texto Poppins 700 18 branco.
/// [carregando] mostra um indicador branco no lugar do texto e bloqueia o toque.
class LummyWideButton extends StatelessWidget {
  const LummyWideButton({
    super.key,
    required this.rotulo,
    required this.onTap,
    this.verde = false,
    this.carregando = false,
  });

  final String rotulo;

  /// Nulo = desabilitado (50% de opacidade; estado não desenhado no mockup).
  final VoidCallback? onTap;
  final bool verde;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return LummyPressable(
      // Carregando: ignora o toque sem ficar apagado.
      onTap: carregando ? (onTap == null ? null : () {}) : onTap,
      semanticLabel: rotulo,
      pressedScale: carregando ? 1 : 0.98,
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: verde ? LummyColors.brandGreen : LummyColors.orange600,
          borderRadius: BorderRadius.circular(28),
          boxShadow: verde ? LummyShadows.green : LummyShadows.orangeStrong,
        ),
        child: carregando
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: LummyColors.white,
                ),
              )
            : ExcludeSemantics(
                child: Text(
                  rotulo,
                  style: LummyText.poppins(
                    size: 18,
                    weight: FontWeight.w700,
                    color: LummyColors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
