import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Cabeçalho dos cards da aba Resumo (ícone, título e "Ver todas").
class ControlPanelSummaryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onSeeAll;

  const ControlPanelSummaryHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: LummyFonts.body(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
        ),
        if (onSeeAll != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Ver todas',
                  style: LummyFonts.body(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
