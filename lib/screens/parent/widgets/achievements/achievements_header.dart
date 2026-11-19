import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Gold gradient header with back button and title.
class AchievementsHeader extends StatelessWidget {
  final bool isDark;
  final double topPadding;
  final String childName;
  final VoidCallback onBack;

  const AchievementsHeader({
    super.key,
    required this.isDark,
    required this.topPadding,
    required this.childName,
    required this.onBack,
  });

  static const _orange = LummyColors.amber500;
  static const _gold = LummyColors.amber600;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LummyColors.stone900, _gold.withValues(alpha: 0.4)]
              : [_gold, _orange, LummyColors.orange600],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conquistas',
                      style: LummyFonts.body(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Medalhas de $childName',
                      style: LummyFonts.body(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('🏆', style: TextStyle(fontSize: 28)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
