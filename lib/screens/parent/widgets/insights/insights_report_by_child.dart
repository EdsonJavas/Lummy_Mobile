import 'package:flutter/material.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Relatório de gastos por filho (últimos 30 dias).
class InsightsReportByChild extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;

  const InsightsReportByChild({
    super.key,
    required this.state,
    required this.isDark,
  });

  static const _red = LummyColors.red500;
  static const _cyan = LummyColors.cyan500;

  @override
  Widget build(BuildContext context) {
    if (state.children.isEmpty || state.totalSpendingByChild.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSpent = state.totalSpendingByChild.values.fold<double>(0, (a, b) => a + b);

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
                    color: _cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: _cyan, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Relatório por filho',
                  style: LummyFonts.body(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : LummyColors.slate800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Gastos dos últimos 30 dias',
              style: LummyFonts.body(
                fontSize: 13,
                color: isDark ? LummyColors.slate400 : LummyColors.slate500,
              ),
            ),
            const SizedBox(height: 16),
            ...state.children.map((child) {
              final spent = state.totalSpendingByChild[child.id] ?? 0;
              final pct = totalSpent > 0 ? (spent / totalSpent * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        child.name,
                        style: LummyFonts.body(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : LummyColors.slate800,
                        ),
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrency(spent),
                      style: LummyFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: LummyFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _cyan,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
