import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Chip de filtro animado da aba Transações.
class ControlPanelFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ControlPanelFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _blue = LummyColors.blue500;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [_blue, LummyColors.blue600])
                : null,
            color: selected
                ? null
                : (isDark ? LummyColors.slate800 : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _blue : (isDark ? LummyColors.slate700 : LummyColors.slate200),
            ),
            boxShadow: selected
                ? [BoxShadow(color: _blue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            style: LummyFonts.body(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : (isDark ? LummyColors.slate400 : LummyColors.slate500),
            ),
          ),
        ),
      ),
    );
  }
}
