import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Dica discreta exibida quando não existe nenhuma meta.
class GoalsSubtleEmptyHint extends StatelessWidget {
  final bool isSmallScreen;

  const GoalsSubtleEmptyHint({
    super.key,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: dark
                ? LummyColors.violet500.withValues(alpha: 0.12)
                : LummyColors.violet500.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.flag_rounded,
            size: 28,
            color: dark ? LummyColors.violet600 : LummyColors.violet500,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Nenhuma meta criada ainda',
          style: LummyFonts.body(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: dark ? LummyColors.slate400 : LummyColors.slate500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Toque no botão abaixo para começar',
          style: LummyFonts.body(
            fontSize: 12,
            color: dark ? LummyColors.slate500 : LummyColors.slate400,
          ),
        ),
      ],
    );
  }
}
