import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/models/goal.dart';
import 'package:lummy/screens/child/widgets/goals/goals_formatters.dart';

/// Card de uma meta na lista de metas concluídas.
class GoalsGoalCard extends StatelessWidget {
  final Goal goal;
  final bool isSmallScreen;

  const GoalsGoalCard({
    super.key,
    required this.goal,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on goal status and progress
    final Color primaryColor = goal.status == GoalStatus.completed
        ? LummyColors.emerald500 // Green for completed
        : LummyColors.violet500; // Purple for ongoing

    final Color secondaryColor = goal.status == GoalStatus.completed
        ? LummyColors.emerald600
        : LummyColors.violet600;

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goal.status == GoalStatus.completed
              ? primaryColor.withValues(alpha: dark ? 0.2 : 0.35)
              : primaryColor.withValues(alpha: dark ? 0.15 : 0.3),
          width: dark ? 1.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: dark ? 0.1 : 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.03 : 0.08),
            blurRadius: dark ? 8 : 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with enhanced styling
          Row(
            children: [
              // Enhanced emoji container with solid color
              Container(
                width: isSmallScreen ? 52 : 60,
                height: isSmallScreen ? 52 : 60,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    goal.emoji,
                    style: TextStyle(fontSize: isSmallScreen ? 26 : 30),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: LummyFonts.body(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: goal.status == GoalStatus.completed
                                ? LummyColors.emerald500.withValues(alpha: 0.1)
                                : LummyColors.violet500.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: goal.status == GoalStatus.completed
                                  ? LummyColors.emerald500.withValues(alpha: 0.3)
                                  : LummyColors.violet500.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                goal.status == GoalStatus.completed
                                    ? Icons.check_circle
                                    : Icons.access_time,
                                size: 12,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                goal.status == GoalStatus.completed
                                    ? 'Concluída'
                                    : 'Em Andamento',
                                style: LummyFonts.body(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (goal.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          color: LummyColors.slate500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Bar - visible track + centered percentage
          SizedBox(
            height: 16,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Track
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: LummyColors.slate200,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: LummyColors.gray300,
                      width: 1,
                    ),
                  ),
                ),
                // Fill
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: goal.progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [primaryColor, secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Centered label over the bar
                IgnorePointer(
                  ignoring: true,
                  child: Text(
                    '${(goal.progress * 100).toInt()}%',
                    style: LummyFonts.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: goal.progress > 0.5 ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Enhanced Progress Text with better layout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progresso',
                        style: LummyFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: LummyColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(goal.progress * 100).toInt()}% concluído',
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: primaryColor.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Valor',
                        style: LummyFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: LummyColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'R\$ ${goal.currentAmount.toStringAsFixed(2)}',
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          color: LummyColors.slate800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        '/ R\$ ${goal.targetAmount.toStringAsFixed(2)}',
                        style: LummyFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: LummyColors.slate500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Completion status
          if (goal.status == GoalStatus.completed &&
              goal.completedDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: LummyColors.emerald500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LummyColors.emerald500.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.celebration,
                    color: LummyColors.emerald500,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '🎉 Concluída em ${goalsFormatDate(goal.completedDate!)}',
                      style: LummyFonts.body(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: LummyColors.emerald500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
