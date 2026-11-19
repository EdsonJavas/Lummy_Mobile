import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Medalha individual exibida em `ProfileAchievementsSection`.
class ProfileBadge extends StatelessWidget {
  const ProfileBadge({
    super.key,
    required this.emoji,
    required this.label,
    required this.isUnlocked,
  });

  final String emoji;
  final String label;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isUnlocked
                ? LummyColors.brandOrange.withValues(alpha: 0.1)
                : Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : LummyColors.slate100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked
                  ? LummyColors.brandOrange.withValues(alpha: 0.3)
                  : Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(
                fontSize: 24,
                // opacity: isUnlocked ? 1.0 : 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: LummyFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isUnlocked
                ? Theme.of(context).textTheme.titleMedium?.color
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
