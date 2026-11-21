import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'expenses_v1_calc.dart';

/// Resumo do período (`Gastos-mes.dc.html`, `<section aria-label="Resumo do mês">`):
/// rótulo Poppins 400 14 `#5B6478`, total Fredoka 600 44 e, só em "Mês", a
/// comparação com o mês anterior.
class ExpensesV1Summary extends StatelessWidget {
  const ExpensesV1Summary({super.key, required this.resumo, required this.agora});

  final ExpensesSummary resumo;
  final DateTime agora;

  String get _rotulo => switch (resumo.periodo) {
        ExpensesPeriod.mes => 'Você gastou em ${V1Format.mes(agora)}',
        // Semana e 3 meses não foram desenhados (proposta do briefing).
        ExpensesPeriod.semana => 'Você gastou nos últimos 7 dias',
        ExpensesPeriod.tresMeses => 'Você gastou nos últimos 3 meses',
      };

  @override
  Widget build(BuildContext context) {
    final comparacao = resumo.comparacao;
    final total = V1Format.brl(resumo.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_rotulo, style: LummyText.poppins(context, size: 14, color: context.cores.tintaApoio)),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (atual, anteriores) => Stack(
            alignment: Alignment.centerLeft,
            children: [...anteriores, ?atual],
          ),
          child: FittedBox(
            key: ValueKey(total),
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(total, maxLines: 1, style: LummyText.valorResumo(context)),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: comparacao == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _Comparacao(comparacao: comparacao),
                ),
        ),
      ],
    );
  }
}

class _Comparacao extends StatelessWidget {
  const _Comparacao({required this.comparacao});

  final ExpensesComparison comparacao;

  @override
  Widget build(BuildContext context) {
    final menos = comparacao.gastouMenos;
    final valor = V1Format.brl(comparacao.diferenca.abs());
    final mes = V1Format.mes(comparacao.mesAnterior);
    // "a mais" não foi desenhado: seta para cima em azul-escuro neutro.
    final texto = menos ? '$valor a menos que em $mes' : '$valor a mais que em $mes';

    return Row(
      children: [
        LummyIcon(
          menos ? LummyGlyphs.trendingDown : LummyGlyphs.trendingUp,
          size: 18,
          color: menos ? LummyColors.brandGreen : context.cores.grafico,
          strokeWidth: 2.4,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(texto, style: LummyText.poppins(context, size: 13)),
        ),
      ],
    );
  }
}
