import 'package:flutter/material.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/dashboard/dashboard_insight_preview_chip.dart';

/// Card de prévia de insights com atalho para a tela completa.
class DashboardInsightsPreview extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;
  final VoidCallback onOpenInsights;

  const DashboardInsightsPreview({
    super.key,
    required this.state,
    required this.isDark,
    required this.onOpenInsights,
  });

  static const _primaryBlue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [_purple.withValues(alpha: 0.15), _primaryBlue.withValues(alpha: 0.1)]
              : [_purple.withValues(alpha: 0.08), _primaryBlue.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? _purple.withValues(alpha: 0.3) : _purple.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _purple.withValues(alpha: 0.2),
                      _primaryBlue.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _purple.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: LummyColors.violet500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights e Desempenho',
                      style: LummyFonts.body(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : LummyColors.slate800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gráficos detalhados de receitas e gastos',
                      style: LummyFonts.body(
                        fontSize: 13,
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DashboardInsightPreviewChip(
                  label: 'Receitas vs. Despesas',
                  value:
                      '${state.monthIncomeTotal > 0 ? ((state.monthExpenseTotal / state.monthIncomeTotal) * 100).clamp(0, 999).toStringAsFixed(0) : '0'}%',
                  icon: Icons.pie_chart_rounded,
                  color: _green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardInsightPreviewChip(
                  label: 'Metas ativas',
                  value: '${state.goalSummaries.length}',
                  icon: Icons.flag_rounded,
                  color: _purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_purple, LummyColors.violet600],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: onOpenInsights,
                icon: const Icon(Icons.trending_up_rounded, size: 20),
                label: Text(
                  'Ver Insights Completos',
                  style: LummyFonts.body(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
