import 'package:flutter/material.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Resumo das metas de cada filho no dashboard do responsável.
class DashboardGoalsSummary extends StatelessWidget {
  final ParentDashboardState state;
  final bool isDark;

  const DashboardGoalsSummary({
    super.key,
    required this.state,
    required this.isDark,
  });

  static const _primaryBlue = LummyColors.blue500;
  static const _green = LummyColors.emerald500;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDark ? Colors.white : LummyColors.slate900;
    final subtitleColor =
        isDark ? LummyColors.slate400 : LummyColors.slate500;
    final cardBg = isDark ? LummyColors.darkNavy : Colors.white;
    final borderColor =
        isDark ? LummyColors.darkSurfaceHigh : LummyColors.slate200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metas dos filhos',
          style: LummyFonts.body(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        ...state.goalSummaries.map((summary) {
          final progress = summary.averageProgress.clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.flag_rounded,
                    color: _primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.childName,
                        style: LummyFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: borderColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  _green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: LummyFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${summary.completedGoals}/${summary.totalGoals} metas concluídas',
                        style: LummyFonts.body(
                          fontSize: 11,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
