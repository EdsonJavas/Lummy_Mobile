import 'package:flutter/material.dart';

import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// "Plano atual" card that opens the subscription screen.
class ParentProfileCurrentPlanCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const ParentProfileCurrentPlanCard({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  static const _orange = LummyColors.amber500;
  static const _pink = LummyColors.pink500;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [_orange.withValues(alpha: 0.2), _pink.withValues(alpha: 0.12)]
                  : [_orange.withValues(alpha: 0.12), _pink.withValues(alpha: 0.06)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _orange.withValues(alpha: isDark ? 0.35 : 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: _orange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plano atual',
                      style: LummyFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? LummyColors.slate400
                            : LummyColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lummy For You',
                      style: LummyFonts.body(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : LummyColors.slate800,
                      ),
                    ),
                    Text(
                      'Até ${AppConstants.lummyForYouMaxChildren} filhos · proporcional',
                      style: LummyFonts.body(
                        fontSize: 12,
                        color: isDark
                            ? LummyColors.slate400
                            : LummyColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark
                    ? LummyColors.slate400
                    : LummyColors.slate500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
