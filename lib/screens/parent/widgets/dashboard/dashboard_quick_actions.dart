import 'package:flutter/material.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_quick_action_card.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_section_title.dart';

/// Seção "Ações Rápidas" do dashboard do responsável.
class DashboardQuickActions extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onOpenReports;

  const DashboardQuickActions({
    super.key,
    required this.state,
    required this.isDark,
    required this.onNavigateToTab,
    required this.onOpenReports,
  });

  static const _primaryBlue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;
  static const _orange = LummyColors.amber500;
  static const _green = LummyColors.emerald500;

  @override
  Widget build(BuildContext context) {
    final quickActions = [
      DashboardQuickActionData(
        title: 'Meus Filhos',
        subtitle: state.children.isEmpty
            ? 'Adicione seu primeiro filho'
            : '${state.children.length} cadastrados',
        icon: Icons.family_restroom_rounded,
        color: _purple,
        onTap: () => onNavigateToTab(1),
      ),
      DashboardQuickActionData(
        title: 'Enviar Dinheiro',
        subtitle: 'Distribua recursos',
        icon: Icons.send_rounded,
        color: _orange,
        onTap: () => onNavigateToTab(2),
      ),
      DashboardQuickActionData(
        title: 'Aprovações',
        subtitle: state.pendingApprovalsCount > 0
            ? '${state.pendingApprovalsCount} pendentes'
            : 'Nenhuma pendente',
        icon: Icons.verified_user_rounded,
        color: _green,
        onTap: () => onNavigateToTab(3),
        badgeCount: state.pendingApprovalsCount,
      ),
      DashboardQuickActionData(
        title: 'Relatórios',
        subtitle: 'Análise detalhada',
        icon: Icons.bar_chart_rounded,
        color: _primaryBlue,
        onTap: onOpenReports,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionTitle(
          title: 'Ações Rápidas',
          subtitle: 'Gerencie tudo em um só lugar',
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        // Primeira linha de ações
        Row(
          children: [
            Expanded(child: DashboardQuickActionCard(data: quickActions[0], isDark: isDark)),
            const SizedBox(width: 14),
            Expanded(child: DashboardQuickActionCard(data: quickActions[1], isDark: isDark)),
          ],
        ),
        const SizedBox(height: 14),
        // Segunda linha de ações
        Row(
          children: [
            Expanded(child: DashboardQuickActionCard(data: quickActions[2], isDark: isDark)),
            const SizedBox(width: 14),
            Expanded(child: DashboardQuickActionCard(data: quickActions[3], isDark: isDark)),
          ],
        ),
      ],
    );
  }
}
