import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_mini_empty.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_summary_card.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_summary_header.dart';

/// Card "Metas" da aba Resumo.
class ControlPanelRecentGoalsCard extends StatelessWidget {
  final List<Map<String, dynamic>> goals;
  final bool isDark;
  final VoidCallback onSeeAll;

  const ControlPanelRecentGoalsCard({
    super.key,
    required this.goals,
    required this.isDark,
    required this.onSeeAll,
  });

  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;

  @override
  Widget build(BuildContext context) {
    final active = goals.where((g) => g['status'] != 'completed' && g['status'] != 'cancelled').take(2).toList();
    final completed = goals.where((g) => g['status'] == 'completed').take(2).toList();

    return ControlPanelSummaryCard(
      isDark: isDark,
      accent: _purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ControlPanelSummaryHeader(title: 'Metas', icon: Icons.savings_rounded, color: _purple, isDark: isDark,
              onSeeAll: onSeeAll),
          const SizedBox(height: 16),
          if (goals.isEmpty)
            ControlPanelMiniEmpty(emoji: '🎯', text: 'Nenhuma meta criada', isDark: isDark)
          else ...[
            ...active.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _miniGoalRow(g, false, isDark),
            )),
            ...completed.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _miniGoalRow(g, true, isDark),
            )),
          ],
        ],
      ),
    );
  }

  Widget _miniGoalRow(Map<String, dynamic> goal, bool done, bool isDark) {
    final emoji = goal['emoji'] ?? '🎯';
    final name = goal['name'] ?? 'Meta';
    final target = (goal['target_amount'] as num?)?.toDouble() ?? 0.0;
    final current = (goal['current_amount'] as num?)?.toDouble() ?? 0.0;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final color = done ? _green : _purple;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: done
            ? LinearGradient(colors: [_green.withValues(alpha: 0.08), _green.withValues(alpha: 0.03)])
            : null,
        color: done ? null : (isDark ? LummyColors.slate900 : LummyColors.slate50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? _green.withValues(alpha: 0.2) : (isDark ? LummyColors.slate800 : LummyColors.slate100),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: LummyFonts.body(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : LummyColors.slate800)),
                const SizedBox(height: 4),
                if (!done)
                  Stack(
                    children: [
                      Container(height: 5, decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(3))),
                      FractionallySizedBox(widthFactor: progress, child: Container(height: 5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_purple, LummyColors.violet600]),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      )),
                    ],
                  )
                else
                  Text('Concluída!', style: LummyFonts.body(fontSize: 11, fontWeight: FontWeight.w600, color: _green)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (done)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [_green, LummyColors.emerald600]), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
            )
          else
            Text('${(progress * 100).toInt()}%', style: LummyFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: _purple)),
        ],
      ),
    );
  }
}
