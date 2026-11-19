import 'package:flutter/material.dart';

import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Item da lista de transações do painel de controle do filho.
class ControlPanelTransactionTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  final bool isDark;

  const ControlPanelTransactionTile({
    super.key,
    required this.tx,
    required this.isDark,
  });

  static const _green = LummyColors.emerald500;
  static const _red = LummyColors.red500;

  @override
  Widget build(BuildContext context) {
    final isIncome = tx['type'] == 'income';
    final amount = (tx['amount'] as num).toDouble();
    final color = isIncome ? _green : _red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.06 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.08)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: color, size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx['description'] ?? 'Transação',
                    style: LummyFonts.body(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : LummyColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? LummyColors.slate900 : LummyColors.slate100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tx['category'] ?? 'Outros',
                      style: LummyFonts.body(
                        fontSize: 10, fontWeight: FontWeight.w500,
                        color: isDark ? LummyColors.slate400 : LummyColors.slate500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.06)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${isIncome ? '+' : '-'}${AppFormatters.formatCurrency(amount)}',
                style: LummyFonts.body(fontSize: 14, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
