import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Linha de uma conquista dentro de `HomeAchievementsSection`.
class HomeAchievementItem extends StatelessWidget {
  const HomeAchievementItem({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isSmallScreen,
  });

  final String emoji;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 48 : 56,
          height: isSmallScreen ? 48 : 56,
          decoration: BoxDecoration(
            color: isCompleted
                ? LummyColors.emerald500.withValues(alpha: 0.1)
                : Theme.of(context).brightness == Brightness.dark
                ? LummyColors.slate800
                : LummyColors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? LummyColors.emerald500.withValues(alpha: 0.3)
                  : Theme.of(context).brightness == Brightness.dark
                      ? LummyColors.slate600
                      : LummyColors.slate200,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: LummyFonts.body(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? Theme.of(context).textTheme.titleMedium?.color
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: LummyFonts.body(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (isCompleted)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: LummyColors.emerald500,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
      ],
    );
  }
}
