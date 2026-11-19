import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'goals_v1_calc.dart';

/// Linha de dica com o ícone `info` (usada no simulador e em "Gerenciar meta").
///
/// Mockup: `info` 16 `#5B6478` traço 2 com `margin-top: 1px`, `gap: 6px`,
/// texto Poppins 400 13, lh 1.45, `#5B6478`.
class GoalsV1InfoLine extends StatelessWidget {
  const GoalsV1InfoLine({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: LummyIcon(
            LummyGlyphs.info,
            size: 16,
            color: LummyColors.ink600,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: LummyText.poppins(
              size: 13,
              color: LummyColors.ink600,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

/// Simulador "Quando você chega lá?" (`Metas-atual.dc.html`).
///
/// A criança escolhe quanto guardar por semana (R$ 5, R$ 10 ou R$ 20) e vê em
/// quantas semanas chega na meta. O valor escolhido é guardado por quem usa
/// ([valorPorSemana]), para não se perder quando a tela recarrega.
class GoalsV1Simulator extends StatelessWidget {
  const GoalsV1Simulator({
    super.key,
    required this.falta,
    required this.valorPorSemana,
    required this.onValorChanged,
  });

  /// Quanto falta para a meta, em reais (precisa ser maior que zero).
  final double falta;

  final int valorPorSemana;
  final ValueChanged<int> onValorChanged;

  @override
  Widget build(BuildContext context) {
    final resultado = GoalsV1Calc.textoSimulador(
      falta: falta,
      valorPorSemana: valorPorSemana,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          titulo: 'Quando você chega lá?',
          apoio: 'Escolha quanto quer guardar por semana.',
        ),
        const SizedBox(height: 10),
        LummySegmented<int>(
          semanticLabel: 'Quanto guardar por semana',
          opcoes: [
            for (final v in GoalsV1Calc.valoresPorSemana)
              LummySegment(v, V1Format.brlInteiro(v)),
          ],
          selecionado: valorPorSemana,
          onChanged: onValorChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LummyColors.brandGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const LummyIcon(
                LummyGlyphs.calendar,
                size: 18,
                color: LummyColors.white,
                strokeWidth: 2.2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  layoutBuilder: (atual, anteriores) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...anteriores, ?atual],
                  ),
                  child: Text(
                    resultado,
                    key: ValueKey(resultado),
                    style: LummyText.poppins(
                      size: 15,
                      weight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const GoalsV1InfoLine(
          texto:
              'A meta usa o dinheiro do cofrinho. Quando você gasta, ela volta um pouco.',
        ),
      ],
    );
  }
}
