import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Estado vazio compacto usado dentro dos cards da aba Resumo.
class ControlPanelMiniEmpty extends StatelessWidget {
  final String emoji;
  final String text;
  final bool isDark;

  const ControlPanelMiniEmpty({
    super.key,
    required this.emoji,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(text, style: LummyFonts.body(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? LummyColors.slate400 : LummyColors.slate500,
          )),
        ],
      ),
    );
  }
}
