import 'package:flutter/material.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/insights/insights_quick_stat_card.dart';

/// Linha com saldo do mês e taxa de economia.
class InsightsQuickStats extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;

  const InsightsQuickStats({
    super.key,
    required this.state,
    required this.isDark,
  });

  static const _blue = LummyColors.blue500;
  static const _green = LummyColors.emerald500;
  static const _red = LummyColors.red500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    final balance = state.monthIncomeTotal - state.monthExpenseTotal;
    final savingsRate = state.monthIncomeTotal > 0
        ? ((balance / state.monthIncomeTotal) * 100).clamp(-999, 999)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: InsightsQuickStatCard(
              label: 'Saldo do mês',
              value: AppFormatters.formatCurrency(balance),
              icon: Icons.account_balance_wallet_rounded,
              color: balance >= 0 ? _green : _red,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InsightsQuickStatCard(
              label: 'Taxa de economia',
              value: '${savingsRate.toStringAsFixed(1)}%',
              icon: Icons.savings_rounded,
              color: savingsRate >= 0 ? _blue : _orange,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}
