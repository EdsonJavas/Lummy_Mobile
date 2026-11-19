import 'package:flutter/material.dart';

import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_inline_empty.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_mission_row.dart';

/// Aba "Missões" do painel de controle do filho.
class ControlPanelMissionsTab extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> activeMissions;
  final bool isDark;

  const ControlPanelMissionsTab({
    super.key,
    required this.isLoading,
    required this.activeMissions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: BrandedLoader());

    if (activeMissions.isEmpty) {
      return ControlPanelInlineEmpty(icon: Icons.assignment_outlined, text: 'Nenhuma missão hoje', isDark: isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: activeMissions.length,
      itemBuilder: (context, index) {
        final mission = activeMissions[index];
        final d = mission['missions'] as Map<String, dynamic>?;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ControlPanelMissionRow(title: d?['title'] ?? 'Missão', emoji: d?['emoji'] ?? '🎯',
              pts: d?['points'] ?? 0, done: mission['is_completed'] == true, isDark: isDark),
        );
      },
    );
  }
}
