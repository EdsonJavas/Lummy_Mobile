import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Shown when the parent has no children registered yet.
class DistributionEmptyState extends StatelessWidget {
  final bool isDark;

  const DistributionEmptyState({super.key, required this.isDark});

  static const _orange = LummyColors.amber500;
  static const _amber = LummyColors.amber600;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _orange.withValues(alpha: 0.15),
                    _amber.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 64,
                color: _orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sem filhos cadastrados',
              style: LummyFonts.body(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white
                    : LummyColors.slate800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre pelo menos um filho para poder enviar dinheiro.',
              textAlign: TextAlign.center,
              style: LummyFonts.body(
                fontSize: 14,
                color: isDark
                    ? LummyColors.slate400
                    : LummyColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
