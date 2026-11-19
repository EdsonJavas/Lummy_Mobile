import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Cabeçalho de seção (ex.: "Concluídas") com contador.
class GoalsSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isSmallScreen;

  const GoalsSectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = title == 'Concluídas';
    final Color headerColor = isCompleted
        ? LummyColors.emerald500
        : LummyColors.violet500;
    final IconData headerIcon = isCompleted ? Icons.check_circle : Icons.flag;

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: dark
              ? [headerColor.withValues(alpha: 0.05), headerColor.withValues(alpha: 0.02)]
              : [headerColor.withValues(alpha: 0.12), headerColor.withValues(alpha: 0.06)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: headerColor.withValues(alpha: dark ? 0.1 : 0.25),
          width: dark ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: dark ? 0.1 : 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              headerIcon,
              color: headerColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: LummyFonts.body(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  headerColor.withValues(alpha: 0.2),
                  headerColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: headerColor.withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: headerColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tag, size: 14, color: headerColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    count.toString(),
                    style: LummyFonts.body(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: headerColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
