import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Resumo da Família" card with three mini stats.
class ParentProfileStatsGrid extends StatelessWidget {
  final bool isDark;
  final int childrenCount;
  final double totalChildrenBalance;

  const ParentProfileStatsGrid({
    super.key,
    required this.isDark,
    required this.childrenCount,
    required this.totalChildrenBalance,
  });

  static const _blue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.darkMaterial : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_purple, _blue]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Resumo da Família',
                style: LummyFonts.body(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : LummyColors.slate800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.child_care_rounded,
                  value: childrenCount.toString(),
                  label: childrenCount == 1 ? 'Filho' : 'Filhos',
                  color: _orange,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.account_balance_wallet_rounded,
                  value:
                      'R\$${totalChildrenBalance.toStringAsFixed(2).replaceAll('.', ',')}',
                  label: 'Saldo Total',
                  color: _green,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.verified_user_rounded,
                  value: '100%',
                  label: 'Segurança',
                  color: _purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: LummyFonts.body(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : LummyColors.slate800,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: LummyFonts.body(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? LummyColors.slate400 : LummyColors.slate500,
          ),
        ),
      ],
    );
  }
}
