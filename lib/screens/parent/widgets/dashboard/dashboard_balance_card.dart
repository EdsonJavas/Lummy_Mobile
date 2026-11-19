import 'package:flutter/material.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_compact_info_card.dart';

/// Cards de topo do dashboard: saldo disponível e aprovações pendentes.
class DashboardBalanceCard extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;

  const DashboardBalanceCard({
    super.key,
    required this.state,
    required this.isDark,
  });

  static const _primaryBlue = LummyColors.blue500;
  static const _orange = LummyColors.amber500;
  static const _green = LummyColors.emerald500;

  @override
  Widget build(BuildContext context) {
    final displayBalance = AppFormatters.formatCurrency(state.walletBalance);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Expanded(
          child: DashboardCompactInfoCard(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Saldo Disponível',
            value: displayBalance,
            color: _primaryBlue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        // Card de aprovações pendentes
        Expanded(
          child: DashboardCompactInfoCard(
            icon: Icons.pending_actions_rounded,
            label: 'Aprovações',
            value: '${state.pendingApprovalsCount}',
            subtitle: state.pendingApprovalsCount > 0 ? 'pendentes' : 'nenhuma',
            color: state.pendingApprovalsCount > 0 ? _orange : _green,
            isDark: isDark,
            showBadge: state.pendingApprovalsCount > 0,
          ),
        ),
        ],
      ),
    );
  }
}
