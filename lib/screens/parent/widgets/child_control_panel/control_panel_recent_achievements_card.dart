import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_mini_empty.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_summary_card.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_summary_header.dart';

/// Card "Conquistas Recentes" da aba Resumo.
class ControlPanelRecentAchievementsCard extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final bool isDark;
  final VoidCallback onSeeAll;

  const ControlPanelRecentAchievementsCard({
    super.key,
    required this.achievements,
    required this.isDark,
    required this.onSeeAll,
  });

  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    return ControlPanelSummaryCard(
      isDark: isDark,
      accent: _orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ControlPanelSummaryHeader(title: 'Conquistas Recentes', icon: Icons.emoji_events_rounded, color: _orange, isDark: isDark,
              onSeeAll: onSeeAll),
          const SizedBox(height: 16),
          if (achievements.isEmpty)
            ControlPanelMiniEmpty(emoji: '🏆', text: 'Nenhuma conquista ainda', isDark: isDark)
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: achievements.take(6).map((a) {
                final d = a['achievements'] as Map<String, dynamic>?;
                return _achieveBadge(d?['emoji'] ?? '🏆', d?['name'] ?? 'Conquista', isDark);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _achieveBadge(String emoji, String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_orange.withValues(alpha: 0.15), _orange.withValues(alpha: 0.06)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            name,
            style: LummyFonts.body(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
        ],
      ),
    );
  }
}
