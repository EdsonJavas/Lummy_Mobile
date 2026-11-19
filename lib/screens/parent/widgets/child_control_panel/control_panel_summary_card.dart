import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Container padrão dos cards da aba Resumo.
class ControlPanelSummaryCard extends StatelessWidget {
  final bool isDark;
  final Color? accent;
  final Widget child;

  const ControlPanelSummaryCard({
    super.key,
    required this.isDark,
    this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent != null
              ? accent!.withValues(alpha: isDark ? 0.15 : 0.1)
              : (isDark ? LummyColors.slate700 : LummyColors.slate200),
        ),
        boxShadow: [
          BoxShadow(
            color: (accent ?? Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
