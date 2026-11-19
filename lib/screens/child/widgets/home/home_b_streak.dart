import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/data/child/child_missions_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// "Sequência de dias" (`Home-rolagem.dc.html`, `<section
/// aria-label="Sequência de dias">`): chama + "{N} dias seguidos", a semana
/// de domingo a sábado e a legenda de incentivo.
///
/// Quem usa só mostra com `streak.diasSeguidos > 0` (DECISOES 7).
class HomeBStreak extends StatelessWidget {
  const HomeBStreak({super.key, required this.streak});

  final ChildStreak streak;

  @override
  Widget build(BuildContext context) {
    final n = streak.diasSeguidos;
    final titulo = n == 1 ? '1 dia seguido' : '$n dias seguidos';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const LummyIcon(
              LummyGlyphs.flame,
              size: 20,
              color: LummyColors.orange600,
              fill: LummyColors.orange600,
              strokeWidth: 2,
            ),
            const SizedBox(width: 6),
            Expanded(child: SectionTitle(titulo: titulo)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < streak.semana.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(child: _Dia(dia: streak.semana[i])),
            ],
          ],
        ),
        // Com hoje feito o mockup não desenhou texto: a legenda some.
        if (!streak.hojeFeito) ...[
          const SizedBox(height: 10),
          Text(
            'Faça 1 missão hoje e chegue a ${n + 1} dias.',
            style: LummyText.apoio(),
          ),
        ],
      ],
    );
  }
}

/// Uma coluna da semana: círculo 32 e o rótulo do dia.
class _Dia extends StatelessWidget {
  const _Dia({required this.dia});

  final StreakDay dia;

  String get _descricao => switch (dia.estado) {
        StreakDayState.feito => 'missão feita',
        StreakDayState.hojePendente => 'ainda sem missão',
        StreakDayState.perdido => 'sem missão',
        StreakDayState.futuro => 'ainda não chegou',
      };

  @override
  Widget build(BuildContext context) {
    final rotulo = dia.ehHoje ? 'Hoje' : V1Format.diaCurto(dia.dia);
    return Semantics(
      label: '$rotulo: $_descricao',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circulo(),
          const SizedBox(height: 6),
          Text(
            rotulo,
            maxLines: 1,
            softWrap: false,
            style: dia.ehHoje
                ? LummyText.poppins(size: 12, weight: FontWeight.w600)
                : LummyText.poppins(size: 12, color: LummyColors.ink600),
          ),
        ],
      ),
    );
  }

  Widget _circulo() {
    switch (dia.estado) {
      case StreakDayState.feito:
        return Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: LummyColors.orange600,
          ),
          child: const LummyIcon(
            LummyGlyphs.check,
            size: 14,
            color: LummyColors.white,
            strokeWidth: 3,
          ),
        );
      case StreakDayState.hojePendente:
        return const SizedBox(
          width: 32,
          height: 32,
          child: CustomPaint(
            painter: _CirculoTracejadoPainter(cor: LummyColors.orange600),
          ),
        );
      case StreakDayState.perdido:
      case StreakDayState.futuro:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: LummyColors.line100,
          ),
        );
    }
  }
}

/// `border: 2px dashed`: traços de ~4 px com vãos de ~2 px (16 na volta),
/// ajustados para fechar a volta sem traço cortado.
class _CirculoTracejadoPainter extends CustomPainter {
  const _CirculoTracejadoPainter({required this.cor});

  static const _espessura = 2.0;
  static const _traco = 4.0;
  static const _espaco = 2.0;

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final raio = (math.min(size.width, size.height) - _espessura) / 2;
    if (raio <= 0) return;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: raio);
    final perimetro = 2 * math.pi * raio;
    final quantidade = math.max(1, (perimetro / (_traco + _espaco)).round());
    final passo = 2 * math.pi / quantidade;
    final arco = passo * _traco / (_traco + _espaco);
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _espessura;
    for (var i = 0; i < quantidade; i++) {
      canvas.drawArc(rect, -math.pi / 2 + i * passo, arco, false, paint);
    }
  }

  @override
  bool shouldRepaint(_CirculoTracejadoPainter old) => old.cor != cor;
}
