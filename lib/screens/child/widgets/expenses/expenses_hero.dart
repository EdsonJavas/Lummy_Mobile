import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Hero da tela de gastos: gradiente + título + stats.
class ExpensesHero extends StatelessWidget {
  final bool isSmallScreen;
  final bool isDark;
  final double topPadding;
  final String selectedPeriod;
  final int transactionCount;

  const ExpensesHero({
    super.key,
    required this.isSmallScreen,
    required this.isDark,
    required this.topPadding,
    required this.selectedPeriod,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  LummyColors.amber700,
                  LummyColors.amber600,
                  LummyColors.amber500,
                ]
              : [
                  LummyColors.amber500,
                  LummyColors.amber600,
                  LummyColors.amber700,
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: LummyColors.amber600.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meus Gastos',
                      style: LummyFonts.body(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acompanhe onde você gastou',
                      style: LummyFonts.body(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeroStatChip(
                Icons.calendar_today_rounded,
                selectedPeriod,
                isSmallScreen,
              ),
              const SizedBox(width: 10),
              _buildHeroStatChip(
                Icons.receipt_rounded,
                '$transactionCount transações',
                isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatChip(
    IconData icon,
    String label,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isSmallScreen ? 16 : 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: LummyFonts.body(
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
