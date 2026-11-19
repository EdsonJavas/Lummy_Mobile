import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Linha de cards com missões de hoje, conquistas e transações.
class ControlPanelStatsGrid extends StatelessWidget {
  final int completedMissions;
  final int totalMissions;
  final int totalAchievements;
  final List<Map<String, dynamic>> recentTransactions;
  final bool isDark;

  const ControlPanelStatsGrid({
    super.key,
    required this.completedMissions,
    required this.totalMissions,
    required this.totalAchievements,
    required this.recentTransactions,
    required this.isDark,
  });

  static const _blue = LummyColors.blue500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Missões Hoje',
              '$completedMissions/$totalMissions',
              Icons.flag_rounded,
              _blue,
              isDark,
              progress: totalMissions > 0
                  ? completedMissions / totalMissions
                  : 0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Conquistas',
              '$totalAchievements',
              Icons.emoji_events_rounded,
              _orange,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Transações',
              '${recentTransactions.length}',
              Icons.receipt_long_rounded,
              _green,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.1 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: LummyFonts.body(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: LummyFonts.body(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? LummyColors.slate400 : LummyColors.slate500,
            ),
            textAlign: TextAlign.center,
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
