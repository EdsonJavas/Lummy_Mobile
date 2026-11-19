import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Unlocked / remaining / progress summary card with progress bar.
class AchievementsStatsSection extends StatelessWidget {
  final bool isDark;
  final int totalAchievements;
  final int unlockedCount;

  const AchievementsStatsSection({
    super.key,
    required this.isDark,
    required this.totalAchievements,
    required this.unlockedCount,
  });

  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;
  static const _gold = LummyColors.amber600;
  static const _goldLight = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    final progress =
        totalAchievements > 0 ? unlockedCount / totalAchievements : 0.0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [LummyColors.slate800, LummyColors.slate900]
                : [Colors.white, LummyColors.amber50],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _gold.withValues(alpha: isDark ? 0.15 : 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: isDark ? 0.08 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '$unlockedCount',
                  'Desbloqueadas',
                  Icons.emoji_events_rounded,
                  _gold,
                  isDark,
                ),
                Container(
                  width: 1, height: 50,
                  color: isDark ? LummyColors.slate700 : LummyColors.slate200,
                ),
                _buildStatItem(
                  '${totalAchievements - unlockedCount}',
                  'Restantes',
                  Icons.lock_rounded,
                  _purple,
                  isDark,
                ),
                Container(
                  width: 1, height: 50,
                  color: isDark ? LummyColors.slate700 : LummyColors.slate200,
                ),
                _buildStatItem(
                  '${(progress * 100).toInt()}%',
                  'Progresso',
                  Icons.pie_chart_rounded,
                  _green,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_gold, _goldLight]),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.4),
                          blurRadius: 8,
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
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: LummyFonts.body(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : LummyColors.slate800,
          ),
        ),
        Text(
          label,
          style: LummyFonts.body(
            fontSize: 11,
            color: isDark ? LummyColors.slate400 : LummyColors.slate500,
          ),
        ),
      ],
    );
  }
}
