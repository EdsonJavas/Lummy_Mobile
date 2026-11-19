import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/models/goal.dart';
import 'package:lummy/screens/child/widgets/goals/goals_formatters.dart';

/// Card de destaque da meta em andamento (com ações).
class GoalsFeaturedGoalCard extends StatelessWidget {
  final Goal goal;
  final bool isSmallScreen;
  final VoidCallback onAddProgress;
  final VoidCallback onMarkCompleted;
  final VoidCallback onDelete;

  const GoalsFeaturedGoalCard({
    super.key,
    required this.goal,
    required this.isSmallScreen,
    required this.onAddProgress,
    required this.onMarkCompleted,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = goal.status == GoalStatus.completed
        ? LummyColors.emerald500
        : LummyColors.violet500;
    final progress = goal.progress.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.4),
            width: isDark ? 1.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.12),
              blurRadius: isDark ? 12 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: isSmallScreen ? 72 : 88,
                  height: isSmallScreen ? 72 : 88,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: isSmallScreen ? 72 : 88,
                        height: isSmallScreen ? 72 : 88,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: primaryColor.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          goal.emoji,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 28 : 34,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          goal.status == GoalStatus.completed
                              ? 'Concluída'
                              : 'Em andamento',
                          style: LummyFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.name,
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).toInt()}% • ${goalsFormatCurrency(goal.currentAmount)} / ${goalsFormatCurrency(goal.targetAmount)}',
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 12 : 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: primaryColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            if (goal.status != GoalStatus.completed) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildCardActionButton(
                      context,
                      Icons.add_circle_rounded,
                      'Adicionar economia',
                      primaryColor,
                      onTap: onAddProgress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCardActionButton(
                      context,
                      Icons.check_circle_outline_rounded,
                      'Marcar concluída',
                      LummyColors.emerald500,
                      onTap: onMarkCompleted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCardActionButton(
                context,
                Icons.delete_outline_rounded,
                'Remover meta',
                LummyColors.red500,
                onTap: onDelete,
                fullWidth: true,
              ),
            ],
            if (goal.status == GoalStatus.completed &&
                goal.completedDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: LummyColors.emerald500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: LummyColors.emerald500.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.celebration_rounded,
                      color: LummyColors.emerald500,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Concluída em ${goalsFormatDate(goal.completedDate!)}',
                      style: LummyFonts.body(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: LummyColors.emerald500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
    bool fullWidth = false,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            mainAxisAlignment:
                fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: LummyFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
