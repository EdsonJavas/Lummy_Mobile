import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Estado vazio centralizado usado nas abas do painel.
class ControlPanelInlineEmpty extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const ControlPanelInlineEmpty({
    super.key,
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? LummyColors.violet500.withValues(alpha: 0.1)
                    : LummyColors.violet500.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 26, color: isDark ? LummyColors.violet600 : LummyColors.violet500),
            ),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: LummyFonts.body(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? LummyColors.slate400 : LummyColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
