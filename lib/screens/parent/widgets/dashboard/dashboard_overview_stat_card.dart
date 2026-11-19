import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class DashboardOverviewStatCard extends StatelessWidget {
  final DashboardOverviewStatData data;
  final bool isDark;

  const DashboardOverviewStatCard({
    super.key,
    required this.data,
    required this.isDark,
  });

  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final c = data.color;

    return Semantics(
      container: true,
      label: '${data.title}: ${data.value}${data.subtitle != null ? ', ${data.subtitle}' : ''}',
      child: Container(
        constraints: const BoxConstraints(minHeight: 128),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              c.withValues(alpha: isDark ? 0.2 : 0.14),
              c.withValues(alpha: isDark ? 0.09 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: c.withValues(alpha: isDark ? 0.34 : 0.26),
          ),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: isDark ? 0.14 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: isDark ? 0.22 : 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: c, size: 18),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.title,
                      style: LummyFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? LummyColors.slate400
                            : LummyColors.slate500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                data.value,
                style: LummyFonts.body(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: c,
                ),
              ),
            ),
            if (data.subtitle != null) ...[
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  data.subtitle!,
                  style: LummyFonts.body(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? LummyColors.slate400
                        : LummyColors.slate500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DashboardOverviewStatData {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const DashboardOverviewStatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}
