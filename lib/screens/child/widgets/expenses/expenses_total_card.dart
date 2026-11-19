import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/formatters.dart';

/// Card com o saldo do cofrinho e o total gasto no período.
class ExpensesTotalCard extends StatelessWidget {
  final bool isSmallScreen;
  final double currentBalance;
  final double totalSpent;
  final String selectedPeriod;
  final String selectedCategory;

  const ExpensesTotalCard({
    super.key,
    required this.isSmallScreen,
    required this.currentBalance,
    required this.totalSpent,
    required this.selectedPeriod,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalGasto = totalSpent;
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.9) ??
        (isDark ? LummyColors.slate400 : LummyColors.slate500);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 18 : 22,
        vertical: isSmallScreen ? 18 : 22,
      ),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? theme.dividerColor
              : LummyColors.slate300,
          width: isDark ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: isDark ? 12 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo no cofrinho',
            style: LummyFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const Gap(6),
          Text(
            AppFormatters.formatCurrency(currentBalance),
            style: LummyFonts.body(
              fontSize: isSmallScreen ? 26 : 28,
              fontWeight: FontWeight.w800,
              color: LummyColors.emerald500,
              letterSpacing: -0.6,
            ),
          ),
          const Gap(4),
          Text(
            'Dinheiro disponível agora (atualizado quando você recebe ou gasta).',
            style: LummyFonts.body(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.35,
              color: muted,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: theme.dividerColor),
          ),
          Text(
            'Gasto no período',
            style: LummyFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const Gap(6),
          Text(
            '− ${AppFormatters.formatCurrency(totalGasto)}',
            style: LummyFonts.body(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: LummyColors.red500,
              letterSpacing: -0.4,
            ),
          ),
          const Gap(4),
          Text(
            'Soma só das despesas com os filtros atuais ($selectedPeriod${selectedCategory != 'Todas' ? ', categoria selecionada' : ''}).',
            style: LummyFonts.body(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.35,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}
