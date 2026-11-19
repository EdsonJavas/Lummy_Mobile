import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Card of the "Todas as Conquistas" grid (locked or unlocked).
class AchievementsGridCard extends StatelessWidget {
  final String name;
  final String emoji;
  final int pointsRequired;
  final Color color;
  final bool isUnlocked;
  final bool isDark;

  const AchievementsGridCard({
    super.key,
    required this.name,
    required this.emoji,
    required this.pointsRequired,
    required this.color,
    required this.isUnlocked,
    required this.isDark,
  });

  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [LummyColors.slate800, color.withValues(alpha: 0.12)]
                    : [Colors.white, color.withValues(alpha: 0.06)],
              )
            : null,
        color: isUnlocked ? null : (isDark ? LummyColors.slate800 : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.4)
              : (isDark ? LummyColors.slate700 : LummyColors.slate200),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: isUnlocked
                      ? LinearGradient(
                          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)],
                        )
                      : null,
                  color: isUnlocked
                      ? null
                      : (isDark ? LummyColors.slate900 : LummyColors.slate100),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked
                        ? color.withValues(alpha: 0.3)
                        : (isDark ? LummyColors.slate700 : LummyColors.slate200),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              if (!isUnlocked)
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: (isDark ? LummyColors.slate900 : Colors.white)
                        .withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    color: isDark ? LummyColors.slate600 : LummyColors.slate300,
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: LummyFonts.body(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isUnlocked
                  ? (isDark ? Colors.white : LummyColors.slate800)
                  : (isDark ? LummyColors.slate500 : LummyColors.slate400),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(colors: [_green.withValues(alpha: 0.2), _green.withValues(alpha: 0.1)])
                  : null,
              color: isUnlocked ? null : _purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isUnlocked ? '✓ Desbloqueada' : '$pointsRequired pts',
              style: LummyFonts.body(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? _green : _purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
