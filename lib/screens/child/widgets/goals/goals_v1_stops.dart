import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'goals_v1_calc.dart';

/// Seção "Paradas da viagem" (`Metas-atual.dc.html` + `Metas-rolagem.dc.html`).
///
/// 4 paradas em 25%, 50%, 75% e 100% do alvo. O XP é recompensa PROMETIDA
/// (ainda não é pago: pendência D7), por isso a parada feita mostra "+30 XP"
/// sem a palavra "ganhos".
class GoalsV1Stops extends StatelessWidget {
  const GoalsV1Stops({super.key, required this.paradas});

  final List<GoalStop> paradas;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          titulo: 'Paradas da viagem',
          apoio: 'Cada parada que você alcança vale XP.',
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < paradas.length; i++)
          _StopItem(parada: paradas[i], ultimo: i == paradas.length - 1),
      ],
    );
  }
}

class _StopItem extends StatelessWidget {
  const _StopItem({required this.parada, required this.ultimo});

  final GoalStop parada;
  final bool ultimo;

  String get _estadoFalado => switch (parada.estado) {
        GoalStopState.feita => 'parada alcançada',
        GoalStopState.atual => 'próxima parada',
        GoalStopState.futura => 'parada futura',
      };

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: _estadoFalado,
        child: Stack(
          children: [
            // Conector até a próxima parada: largura 2 em `left: 13`, de
            // `top: 28` até o fim do item. Verde se esta parada já foi feita.
            if (!ultimo)
              Positioned(
                left: 13,
                top: 28,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: parada.feita ? LummyColors.brandGreen : LummyColors.line100,
                ),
              ),
            Padding(
              padding: EdgeInsets.only(bottom: ultimo ? 0 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StopMarker(estado: parada.estado),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parada.titulo,
                          style: LummyText.poppins(size: 15, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(parada.subtitulo, style: LummyText.apoio()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  XpChip(
                    pontos: parada.xp,
                    feito: parada.feita,
                    pesoFeito: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Marcador 28×28 da parada.
class _StopMarker extends StatelessWidget {
  const _StopMarker({required this.estado});

  final GoalStopState estado;

  @override
  Widget build(BuildContext context) {
    switch (estado) {
      case GoalStopState.feita:
        return Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: LummyColors.brandGreen,
            shape: BoxShape.circle,
          ),
          child: const LummyIcon(
            LummyGlyphs.check,
            size: 15,
            color: LummyColors.white,
            strokeWidth: 3,
          ),
        );
      case GoalStopState.atual:
        return Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LummyColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: LummyColors.brandGreen, width: 3),
          ),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: LummyColors.brandGreen,
              shape: BoxShape.circle,
            ),
          ),
        );
      case GoalStopState.futura:
        return Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LummyColors.surface100,
            shape: BoxShape.circle,
            border: Border.all(color: LummyColors.ink200, width: 2),
          ),
          child: const LummyIcon(
            LummyGlyphs.flag,
            size: 13,
            color: LummyColors.ink500,
            strokeWidth: 2.6,
          ),
        );
    }
  }
}
