import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Linha de missão (emoji, título, pontos e status).
class ControlPanelMissionRow extends StatelessWidget {
  final String title;
  final String emoji;
  final int pts;
  final bool done;
  final bool isDark;

  const ControlPanelMissionRow({
    super.key,
    required this.title,
    required this.emoji,
    required this.pts,
    required this.done,
    required this.isDark,
  });

  static const _blue = LummyColors.blue500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    final color = done ? _green : _blue;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: done
            ? LinearGradient(colors: [_green.withValues(alpha: 0.08), _green.withValues(alpha: 0.03)])
            : null,
        color: done ? null : (isDark ? LummyColors.slate900 : LummyColors.slate50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? _green.withValues(alpha: 0.25) : (isDark ? LummyColors.slate800 : LummyColors.slate100),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LummyFonts.body(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: done
                        ? _green
                        : (isDark ? Colors.white : LummyColors.slate800),
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '+$pts pontos',
                  style: LummyFonts.body(fontSize: 11, fontWeight: FontWeight.w500, color: done ? _green : _orange),
                ),
              ],
            ),
          ),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: done ? const LinearGradient(colors: [_green, LummyColors.emerald600]) : null,
              color: done ? null : (isDark ? LummyColors.slate800 : LummyColors.slate200),
              shape: BoxShape.circle,
            ),
            child: Icon(
              done ? Icons.check_rounded : Icons.circle_outlined,
              color: done ? Colors.white : LummyColors.slate400,
              size: done ? 16 : 20,
            ),
          ),
        ],
      ),
    );
  }
}
