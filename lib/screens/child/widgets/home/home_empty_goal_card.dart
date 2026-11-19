import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Cartão exibido quando a criança ainda não tem meta; tocar cria uma nova.
class HomeEmptyGoalCard extends StatelessWidget {
  const HomeEmptyGoalCard({
    super.key,
    required this.isSmallScreen,
    required this.onTap,
  });

  final bool isSmallScreen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Builder(
        builder: (context) {
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
                          colors: [
                            LummyColors.violet500.withValues(alpha: 0.15),
                            LummyColors.violet500.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: Text(
                        '🎯',
                        style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sem metas ainda',
                            style: LummyFonts.body(
                              fontSize: isSmallScreen ? 17 : 19,
                              fontWeight: FontWeight.w600,
                              color: theme.brightness == Brightness.dark
                                  ? LummyColors.slate300
                                  : theme.textTheme.titleLarge?.color?.withValues(alpha: 0.6),
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
                              color: LummyColors.violet500.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Crie sua primeira meta',
                              style: LummyFonts.body(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: LummyColors.violet500,
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
                        color: LummyColors.violet500.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '0%',
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: LummyColors.violet500.withValues(alpha: 0.7),
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
                          'R\$ 0,00',
                          style: LummyFonts.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.dark
                                ? LummyColors.slate400
                                : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          'R\$ 0,00',
                          style: LummyFonts.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.dark
                                ? LummyColors.slate400
                                : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
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
                          widthFactor: 0.0,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [LummyColors.violet500, LummyColors.violet600],
                              ),
                              borderRadius: BorderRadius.circular(5),
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
                                Icon(
                                  Icons.savings_outlined,
                                  size: 16,
                                  color: theme.brightness == Brightness.dark
                                      ? LummyColors.slate400
                                      : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
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
                                          : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              'R\$ 0,00',
                              style: LummyFonts.body(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: theme.brightness == Brightness.dark
                                    ? LummyColors.slate300
                                    : theme.textTheme.titleLarge?.color?.withValues(alpha: 0.5),
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
                                  Icons.trending_up_rounded,
                                  size: 16,
                                  color: theme.brightness == Brightness.dark
                                      ? LummyColors.slate400
                                      : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                ),
                                const Gap(6),
                                Expanded(
                                  child: Text(
                                    'Falta',
                                    style: LummyFonts.body(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.brightness == Brightness.dark
                                          ? LummyColors.slate400
                                          : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              'R\$ 0,00',
                              style: LummyFonts.body(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: theme.brightness == Brightness.dark
                                    ? LummyColors.slate300
                                    : theme.textTheme.titleLarge?.color?.withValues(alpha: 0.5),
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
        },
      ),
    );
  }
}
