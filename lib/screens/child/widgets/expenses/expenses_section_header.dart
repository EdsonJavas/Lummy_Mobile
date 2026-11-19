import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Cabeçalho de seção da tela de gastos (ícone + título).
class ExpensesSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;

  const ExpensesSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? accentColor.withValues(alpha: 0.08)
            : accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? accentColor.withValues(alpha: 0.2)
              : accentColor.withValues(alpha: 0.35),
          width: isDark ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: LummyFonts.body(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
