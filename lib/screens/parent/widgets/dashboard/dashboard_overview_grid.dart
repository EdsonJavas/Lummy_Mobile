import 'package:flutter/material.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_overview_stat_card.dart';

/// Grade 2x2 de estatísticas do mês no dashboard do responsável.
class DashboardOverviewGrid extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;

  const DashboardOverviewGrid({
    super.key,
    required this.state,
    required this.isDark,
  });

  static const _primaryBlue = LummyColors.blue500;
  static const _orange = LummyColors.amber500;
  static const _green = LummyColors.emerald500;
  static const _red = LummyColors.red500;

  @override
  Widget build(BuildContext context) {
    final stats = [
      DashboardOverviewStatData(
        title: 'Receitas',
        value: AppFormatters.formatCurrency(state.monthIncomeTotal),
        subtitle: 'Este mês',
        icon: Icons.trending_up_rounded,
        color: _green,
      ),
      DashboardOverviewStatData(
        title: 'Despesas',
        value: AppFormatters.formatCurrency(state.monthExpenseTotal),
        subtitle: 'Este mês',
        icon: Icons.trending_down_rounded,
        color: _red,
      ),
      DashboardOverviewStatData(
        title: 'Filhos',
        value: '${state.children.length}/${AppConstants.lummyForYouMaxChildren}',
        subtitle: 'Lummy For You',
        icon: Icons.family_restroom_rounded,
        color: _primaryBlue,
      ),
      DashboardOverviewStatData(
        title: 'Média/Filho',
        value: state.children.isEmpty
            ? '—'
            : AppFormatters.formatCurrency(
                state.monthExpenseTotal / state.children.length,
              ),
        subtitle: 'Gasto mensal',
        icon: Icons.analytics_rounded,
        color: _orange,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.33,
      ),
      itemBuilder: (context, index) {
        return DashboardOverviewStatCard(data: stats[index], isDark: isDark);
      },
    );
  }
}
