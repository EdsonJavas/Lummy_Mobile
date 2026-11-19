import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class DashboardQuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final int badgeCount;

  const DashboardQuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.badgeCount = 0,
  });
}

/// Card de ação rápida do dashboard do responsável.
class DashboardQuickActionCard extends StatelessWidget {
  final DashboardQuickActionData data;
  final bool isDark;

  const DashboardQuickActionCard({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final darkTop = Color.alphaBlend(
      data.color.withAlpha(34),
      LummyColors.slate800,
    );
    final darkBorder = Color.alphaBlend(
      data.color.withAlpha(56),
      LummyColors.slate700,
    );

    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 168),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [darkTop, LummyColors.slate800]
                : [Colors.white, data.color.withValues(alpha: 0.03)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? darkBorder
                : data.color.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? data.color.withAlpha(34)
                  : data.color.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        data.color.withValues(alpha: isDark ? 0.28 : 0.18),
                        data.color.withValues(alpha: isDark ? 0.12 : 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: data.color.withValues(alpha: isDark ? 0.34 : 0.18),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(data.icon, color: data.color, size: 24),
                ),
                if (data.badgeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      data.badgeCount.toString(),
                      style: LummyFonts.body(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            Text(
              data.title,
              style: LummyFonts.body(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? LummyColors.slate50 : LummyColors.slate800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data.subtitle,
              style: LummyFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? LummyColors.slate300
                    : LummyColors.slate500,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
