import 'package:flutter/material.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_chart_legend_item.dart';

/// Gráfico de barras com o fluxo mensal (receitas x despesas).
class InsightsMonthlyChart extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;

  const InsightsMonthlyChart({
    super.key,
    required this.state,
    required this.isDark,
  });

  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;
  static const _red = LummyColors.red500;

  @override
  Widget build(BuildContext context) {
    final maxValue = state.monthlyTrend.fold<double>(
      0,
      (max, point) =>
          [max, point.income, point.expense].reduce((a, b) => a > b ? a : b),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? LummyColors.slate700 : LummyColors.slate200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: _purple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fluxo Mensal',
                        style: LummyFonts.body(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : LummyColors.slate800,
                        ),
                      ),
                      Text(
                        'Comparativo dos últimos meses',
                        style: LummyFonts.body(
                          fontSize: 12,
                          color: isDark
                              ? LummyColors.slate400
                              : LummyColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Legenda
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InsightsChartLegendItem(label: 'Receitas', color: _green),
                SizedBox(width: 16),
                InsightsChartLegendItem(label: 'Despesas', color: _red),
              ],
            ),
            const SizedBox(height: 20),
            // Gráfico de barras customizado
            if (state.monthlyTrend.isEmpty)
              SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'Sem dados disponíveis',
                    style: LummyFonts.body(
                      color: isDark
                          ? LummyColors.slate400
                          : LummyColors.slate500,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: state.monthlyTrend.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    final incomeHeight = maxValue > 0
                        ? (point.income / maxValue) * 140
                        : 0.0;
                    final expenseHeight = maxValue > 0
                        ? (point.expense / maxValue) * 140
                        : 0.0;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 4,
                          right: index == state.monthlyTrend.length - 1 ? 0 : 4,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Barra de receita
                                Flexible(
                                  child: Container(
                                    width: 14,
                                    height: incomeHeight.clamp(4, 140),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [_green, LummyColors.emerald400],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                // Barra de despesa
                                Flexible(
                                  child: Container(
                                    width: 14,
                                    height: expenseHeight.clamp(4, 140),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [_red, LummyColors.red400],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              point.monthLabel,
                              style: LummyFonts.body(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? LummyColors.slate400
                                    : LummyColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
