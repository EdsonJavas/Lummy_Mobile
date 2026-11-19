import 'package:flutter/material.dart';

import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/child_control_panel/control_panel_inline_empty.dart';

/// Aba "Metas" do painel de controle do filho.
class ControlPanelGoalsTab extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> goals;
  final bool isDark;

  const ControlPanelGoalsTab({
    super.key,
    required this.isLoading,
    required this.goals,
    required this.isDark,
  });

  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: BrandedLoader());

    final activeGoals = goals
        .where((g) => g['status'] != 'completed' && g['status'] != 'cancelled')
        .toList();
    final completedGoals = goals
        .where((g) => g['status'] == 'completed')
        .toList();

    if (goals.isEmpty) {
      return ControlPanelInlineEmpty(icon: Icons.savings_outlined, text: 'Nenhuma meta criada ainda', isDark: isDark);
    }

    final hasOnlyCompleted = activeGoals.isEmpty && completedGoals.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        if (activeGoals.isNotEmpty) ...[
          _goalSectionHeader('Em Andamento', '${activeGoals.length}', _orange, Icons.trending_up_rounded, isDark),
          const SizedBox(height: 12),
          ...activeGoals.map((g) => _goalCard(g, isDark)),
          const SizedBox(height: 24),
        ],
        if (hasOnlyCompleted) ...[
          _goalsCelebrationBanner(isDark, completedGoals.length),
          const SizedBox(height: 20),
        ],
        if (completedGoals.isNotEmpty) ...[
          _goalSectionHeader(
            hasOnlyCompleted ? 'Todas Concluídas' : 'Concluídas',
            '${completedGoals.length}',
            _green,
            Icons.check_circle_rounded,
            isDark,
          ),
          const SizedBox(height: 12),
          ...completedGoals.map((g) => _goalCard(g, isDark, isCompleted: true)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _goalsCelebrationBanner(bool isDark, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LummyColors.emerald900, _green.withValues(alpha: 0.25)]
              : [_green, LummyColors.emerald600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('🏆', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parabéns!',
                  style: LummyFonts.body(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                Text(
                  '$count ${count == 1 ? 'meta concluída' : 'metas concluídas'} com sucesso',
                  style: LummyFonts.body(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalSectionHeader(String title, String count, Color color, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: LummyFonts.body(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : LummyColors.slate800,
        )),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.08)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(count, style: LummyFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  Widget _goalCard(Map<String, dynamic> goal, bool isDark, {bool isCompleted = false}) {
    final name = goal['name'] ?? 'Meta';
    final emoji = goal['emoji'] ?? '🎯';
    final target = (goal['target_amount'] as num?)?.toDouble() ?? 0.0;
    final current = (goal['current_amount'] as num?)?.toDouble() ?? 0.0;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).toInt();
    final color = isCompleted ? _green : _purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
                colors: isDark
                    ? [LummyColors.slate800, _green.withValues(alpha: 0.1)]
                    : [Colors.white, _green.withValues(alpha: 0.04)],
              )
            : null,
        color: isCompleted ? null : (isDark ? LummyColors.slate800 : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: LummyFonts.body(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : LummyColors.slate800,
                    ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      'Meta: ${AppFormatters.formatCurrency(target)}',
                      style: LummyFonts.body(fontSize: 12,
                          color: isDark ? LummyColors.slate400 : LummyColors.slate500),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_green, LummyColors.emerald600]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Concluída', style: LummyFonts.body(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                    ],
                  ),
                )
              else
                Text('$pct%', style: LummyFonts.body(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(height: 10, decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5))),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 10, decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
                  )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppFormatters.formatCurrency(current),
                      style: LummyFonts.body(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                    ),
                  ],
                ),
                Text(
                  'Falta ${AppFormatters.formatCurrency(target - current)}',
                  style: LummyFonts.body(fontSize: 12,
                      color: isDark ? LummyColors.slate400 : LummyColors.slate500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
