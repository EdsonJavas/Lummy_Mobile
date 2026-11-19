import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Nova Conquista" floating action button.
class AchievementsFab extends StatelessWidget {
  final VoidCallback onTap;

  const AchievementsFab({super.key, required this.onTap});

  static const _gold = LummyColors.amber600;
  static const _goldLight = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_gold, _goldLight]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'Nova Conquista',
                style: LummyFonts.body(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
