import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';

import 'lummy_icon.dart';
import 'v1_text.dart';

/// "+N XP" do mockup (C-5 do RELATORIO).
///
/// - A ganhar (missão pendente, parada atual/futura): raio `zap` 14 dourado
///   preenchido + "+N XP" Poppins 600 13 tinta, `gap: 3px`.
/// - Já ganho/feito: sem raio, "+N XP" em `#5B6478`, peso [pesoFeito]
///   (500 na missão feita, `Home-rolagem.dc.html`; 400 na parada feita,
///   `Metas-atual.dc.html`).
class XpChip extends StatelessWidget {
  const XpChip({
    super.key,
    required this.pontos,
    this.feito = false,
    this.pesoFeito = FontWeight.w500,
  });

  final int pontos;
  final bool feito;
  final FontWeight pesoFeito;

  @override
  Widget build(BuildContext context) {
    final texto = '+$pontos XP';
    if (feito) {
      return Text(
        texto,
        maxLines: 1,
        softWrap: false,
        style: LummyText.poppins(context, size: 13, weight: pesoFeito, color: context.cores.tintaApoio),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LummyIcon(
          LummyGlyphs.zap,
          size: 14,
          color: LummyColors.brandGold,
          fill: LummyColors.brandGold,
          strokeWidth: 2,
        ),
        const SizedBox(width: 3),
        Text(
          texto,
          maxLines: 1,
          softWrap: false,
          style: LummyText.poppins(context, size: 13, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Pílula dourada "Nível N" do menu lateral (`Drawer-crianca.dc.html`):
/// altura 24, `padding: 0 10px`, raio 12, `#F5B000`, Poppins 700 12 tinta.
class LevelPill extends StatelessWidget {
  const LevelPill({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LummyColors.brandGold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Nível $level',
        style: LummyText.poppins(context, size: 12, weight: FontWeight.w700),
      ),
    );
  }
}
