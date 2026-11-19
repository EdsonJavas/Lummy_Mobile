import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/formatters.dart';

/// Card com a lista de transações (despesas) visíveis.
class ExpensesTransactionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> visibleTransactions;

  const ExpensesTransactionsCard({
    super.key,
    required this.visibleTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Theme.of(context).dividerColor : LummyColors.slate300,
          width: isDark ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: isDark ? 12 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: visibleTransactions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? LummyColors.red500.withValues(alpha: 0.1)
                          : LummyColors.red500.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 24,
                      color: isDark ? LummyColors.red400 : LummyColors.red500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma transação recente',
                    style: LummyFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LummyColors.slate400 : LummyColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Suas movimentações aparecerão aqui',
                    style: LummyFonts.body(
                      fontSize: 11,
                      color: isDark ? LummyColors.slate500 : LummyColors.slate400,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(
                  visibleTransactions.length,
                  (i) => _buildTransactionItem(
                    context,
                    visibleTransactions[i]['description'] as String,
                    visibleTransactions[i]['categoryName'] as String,
                    AppFormatters.formatCurrency(
                      (visibleTransactions[i]['amount'] as num).toDouble(),
                    ),
                    visibleTransactions[i]['color'] as Color,
                    i,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String title,
    String category,
    String amount,
    Color categoryColor,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: categoryColor,
              size: 20,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LummyFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                Text(
                  category,
                  style: LummyFonts.body(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              '− $amount',
              style: LummyFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: LummyColors.red500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              softWrap: false,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (100 + index * 60).ms, duration: 280.ms)
        .slideX(begin: 0.03, end: 0, curve: Curves.easeOut);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Alimentação':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_bus;
      case 'Jogos e Brinquedos':
        return Icons.sports_esports;
      case 'Metas':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }
}
