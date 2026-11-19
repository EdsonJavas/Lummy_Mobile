import 'package:flutter/material.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_insight_card.dart';

/// Seção "Insights" com os cards de análise e dica do mês.
class InsightsNotes extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;

  const InsightsNotes({
    super.key,
    required this.state,
    required this.isDark,
  });

  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    final balance = state.monthIncomeTotal - state.monthExpenseTotal;
    final isPositive = balance >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights',
            style: LummyFonts.body(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
          const SizedBox(height: 16),
          InsightsInsightCard(
            icon: isPositive ? Icons.thumb_up_rounded : Icons.warning_rounded,
            title: isPositive ? 'Finanças Saudáveis' : 'Atenção Necessária',
            description: isPositive
                ? 'Parabéns! As receitas superaram as despesas em ${AppFormatters.formatCurrency(balance)} este mês.'
                : 'As despesas superaram as receitas em ${AppFormatters.formatCurrency(-balance)}. Revise os gastos.',
            color: isPositive ? _green : _orange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          InsightsInsightCard(
            icon: Icons.lightbulb_rounded,
            title: 'Dica do Mês',
            description:
                'Incentive seus filhos a poupar definindo metas de economia com recompensas especiais.',
            color: _purple,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
