import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Nova Missão" floating action button.
class MissionsManagerFab extends StatelessWidget {
  final VoidCallback onTap;

  const MissionsManagerFab({super.key, required this.onTap});

  static const _purple = LummyColors.violet500;
  static const _purpleDark = LummyColors.violet700;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_purple, _purpleDark]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Nova Missão',
                  style: LummyFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
