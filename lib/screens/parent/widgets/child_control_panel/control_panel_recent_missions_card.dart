import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_mini_empty.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_mission_row.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_summary_card.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_summary_header.dart';

/// Card "Missões de Hoje" da aba Resumo.
class ControlPanelRecentMissionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> activeMissions;
  final bool isDark;
  final VoidCallback onSeeAll;

  const ControlPanelRecentMissionsCard({
    super.key,
    required this.activeMissions,
    required this.isDark,
    required this.onSeeAll,
  });

  static const _blue = LummyColors.blue500;

  @override
  Widget build(BuildContext context) {
    return ControlPanelSummaryCard(
      isDark: isDark,
      accent: _blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ControlPanelSummaryHeader(title: 'Missões de Hoje', icon: Icons.flag_rounded, color: _blue, isDark: isDark,
              onSeeAll: onSeeAll),
          const SizedBox(height: 16),
          if (activeMissions.isEmpty)
            ControlPanelMiniEmpty(emoji: '🎯', text: 'Nenhuma missão hoje', isDark: isDark)
          else
            ...(activeMissions.take(3).map((mission) {
              final d = mission['missions'] as Map<String, dynamic>?;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ControlPanelMissionRow(title: d?['title'] ?? 'Missão', emoji: d?['emoji'] ?? '🎯',
                    pts: d?['points'] ?? 0, done: mission['is_completed'] == true, isDark: isDark),
              );
            })),
        ],
      ),
    );
  }
}
