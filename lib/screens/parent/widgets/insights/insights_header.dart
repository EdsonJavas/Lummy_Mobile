import 'package:flutter/material.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_header_stat_item.dart';

/// Header da tela de insights: título, voltar e resumo receitas/despesas.
class InsightsHeader extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;
  final VoidCallback onBack;

  const InsightsHeader({
    super.key,
    required this.state,
    required this.isDark,
    required this.onBack,
  });

  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;
  static const _red = LummyColors.red500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [LummyColors.violet950, LummyColors.indigo900, LummyColors.violet900]
              : const [LummyColors.violet500, LummyColors.violet600, LummyColors.violet700],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: isDark ? 0.2 : 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button e título
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights & Desempenho',
                      style: LummyFonts.body(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Análise financeira da família',
                      style: LummyFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Card de resumo principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InsightsHeaderStatItem(
                        label: 'Receitas',
                        value: AppFormatters.formatCurrency(
                          state.monthIncomeTotal,
                        ),
                        icon: Icons.trending_up_rounded,
                        color: _green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: InsightsHeaderStatItem(
                        label: 'Despesas',
                        value: AppFormatters.formatCurrency(
                          state.monthExpenseTotal,
                        ),
                        icon: Icons.trending_down_rounded,
                        color: _red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        state.monthIncomeTotal >= state.monthExpenseTotal
                            ? Icons.thumb_up_rounded
                            : Icons.warning_rounded,
                        color: state.monthIncomeTotal >= state.monthExpenseTotal
                            ? _green
                            : _orange,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        state.monthIncomeTotal >= state.monthExpenseTotal
                            ? 'Balanço positivo este mês! 🎉'
                            : 'Atenção: despesas superaram receitas',
                        style: LummyFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
