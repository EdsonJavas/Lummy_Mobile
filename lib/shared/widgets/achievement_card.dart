import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/achievement_entity.dart';
import 'custom_card.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class AchievementCard extends StatelessWidget {
  final AchievementEntity achievement;
  final VoidCallback? onTap;
  final bool compact;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    if (compact) {
      return _buildCompactCard(isSmallScreen);
    }

    return _buildFullCard(isSmallScreen);
  }

  Widget _buildCompactCard(bool isSmallScreen) {
    return CustomCard(
      onTap: onTap,
      style: CardStyle.filled,
      color: achievement.isCompleted
          ? LummyColors.emerald500.withValues(alpha: 0.05)
          : null,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: achievement.isCompleted
                  ? LummyColors.emerald500.withValues(alpha: 0.1)
                  : LummyColors.offWhite,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: achievement.isCompleted
                    ? LummyColors.emerald500.withValues(alpha: 0.3)
                    : LummyColors.slate200,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: LummyFonts.body(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: achievement.isCompleted
                        ? LummyColors.slate800
                        : LummyColors.slate500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: LummyFonts.body(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w400,
                    color: LummyColors.slate500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (achievement.isCompleted)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: LummyColors.emerald500,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildFullCard(bool isSmallScreen) {
    return CustomCard(
      onTap: onTap,
      style: CardStyle.filled,
      color: achievement.isCompleted
          ? LummyColors.emerald500.withValues(alpha: 0.05)
          : null,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          // Emoji grande
          Container(
            width: isSmallScreen ? 60 : 80,
            height: isSmallScreen ? 60 : 80,
            decoration: BoxDecoration(
              color: achievement.isCompleted
                  ? LummyColors.emerald500.withValues(alpha: 0.1)
                  : LummyColors.offWhite,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              border: Border.all(
                color: achievement.isCompleted
                    ? LummyColors.emerald500.withValues(alpha: 0.3)
                    : LummyColors.slate200,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: TextStyle(fontSize: isSmallScreen ? 32 : 40),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          // Título
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: LummyFonts.body(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: achievement.isCompleted
                  ? LummyColors.slate800
                  : LummyColors.slate500,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          // Descrição
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: LummyFonts.body(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w400,
              color: LummyColors.slate500,
            ),
          ),
          // Pontos
          if (achievement.points > 0) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: LummyColors.brandOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: LummyColors.brandOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${achievement.points} pontos',
                    style: LummyFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LummyColors.brandOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Check se completado
          if (achievement.isCompleted) ...[
            const SizedBox(height: AppConstants.spacingMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: LummyColors.emerald500,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Conquistado!',
                    style: LummyFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
