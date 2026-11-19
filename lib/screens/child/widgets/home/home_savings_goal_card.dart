import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Cartão da meta de economia ativa (ou da última concluída).
class HomeSavingsGoalCard extends StatelessWidget {
  const HomeSavingsGoalCard({
    super.key,
    required this.isSmallScreen,
    required this.savingsGoal,
    required this.goalCurrentAmount,
    required this.goalName,
    required this.goalEmoji,
    required this.currentBalance,
    required this.balanceLoadFailed,
  });

  final bool isSmallScreen;
  final double savingsGoal;
  final double goalCurrentAmount;
  final String goalName;
  final String goalEmoji;
  final double currentBalance;
  final bool balanceLoadFailed;

  @override
  Widget build(BuildContext context) {
    // Usar valor reservado da meta (goalCurrentAmount) e nunca exceder o alvo
    final cappedTarget = savingsGoal < 0 ? 0.0 : savingsGoal;
    final contributed = goalCurrentAmount.clamp(0.0, cappedTarget);
    final progress = cappedTarget > 0 ? contributed / cappedTarget : 0.0;
    final remaining = cappedTarget - contributed;
    final progressPercent = (progress * 100).clamp(0, 100).toInt();
    final isCompleted = progress >= 1.0;

    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
      padding: EdgeInsets.all(isSmallScreen ? AppConstants.spacingLarge : AppConstants.spacingXLarge),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? LummyColors.slate600
              : LummyColors.slate200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [
                            LummyColors.emerald500.withValues(alpha: 0.15),
                            LummyColors.emerald500.withValues(alpha: 0.05),
                          ]
                        : [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Text(
                  goalEmoji,
                  style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goalName,
                      style: LummyFonts.body(
                        fontSize: isSmallScreen ? 17 : 19,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? LummyColors.emerald500.withValues(alpha: 0.12)
                            : theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompleted ? 'Meta concluída' : 'Em progresso',
                        style: LummyFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isCompleted
                              ? LummyColors.emerald500
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? LummyColors.emerald500.withValues(alpha: 0.12)
                      : theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$progressPercent%',
                  style: LummyFonts.body(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? LummyColors.emerald500
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const Gap(24),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ ${contributed.toStringAsFixed(2)}',
                    style: LummyFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LummyColors.emerald500,
                    ),
                  ),
                  Text(
                    'R\$ ${savingsGoal.toStringAsFixed(2)}',
                    style: LummyFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? LummyColors.slate600
                          : LummyColors.slate200,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCompleted
                              ? [
                                  LummyColors.emerald500,
                                  LummyColors.emerald600,
                                ]
                              : [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted
                                    ? LummyColors.emerald500
                                    : theme.colorScheme.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? LummyColors.slate800
                        : LummyColors.offWhite,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? LummyColors.slate600
                          : LummyColors.slate200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.savings_outlined,
                            size: 16,
                            color: LummyColors.emerald500,
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              'Economizado',
                              style: LummyFonts.body(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.brightness == Brightness.dark
                                    ? LummyColors.slate400
                                    : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        balanceLoadFailed
                            ? '—'
                            : 'R\$ ${currentBalance.toStringAsFixed(2)}',
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? LummyColors.slate800
                        : LummyColors.offWhite,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? LummyColors.slate600
                          : LummyColors.slate200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            remaining > 0
                                ? Icons.trending_up_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 16,
                            color: remaining > 0
                                ? LummyColors.materialOrange
                                : LummyColors.emerald500,
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              remaining > 0 ? 'Falta' : 'Excedente',
                              style: LummyFonts.body(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.brightness == Brightness.dark
                                    ? LummyColors.slate400
                                    : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        'R\$ ${remaining.abs().toStringAsFixed(2)}',
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
