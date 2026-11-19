import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Banner de parabéns exibido quando só existem metas concluídas.
class GoalsCelebrationBanner extends StatelessWidget {
  final bool isSmallScreen;

  const GoalsCelebrationBanner({
    super.key,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [LummyColors.emerald900, LummyColors.emerald500.withValues(alpha: 0.25)]
              : [LummyColors.emerald500, LummyColors.emerald600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: LummyColors.emerald500.withValues(alpha: dark ? 0.15 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('🏆', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parabéns!',
                  style: LummyFonts.body(
                    fontSize: isSmallScreen ? 17 : 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Crie uma nova meta para continuar evoluindo!',
                  style: LummyFonts.body(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
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
