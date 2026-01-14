import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    // Cores adaptadas ao tema
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.2)
        : const Color(0xFFCBD5E1);

    // Cor baseada no tipo e status
    Color amountColor;
    Color iconBackgroundColor;

    if (transaction.isIncome) {
      amountColor = const Color(0xFF10B981);
      iconBackgroundColor = const Color(
        0xFF10B981,
      ).withOpacity(isDark ? 0.2 : 0.1);
    } else {
      amountColor = const Color(0xFFEF4444);
      iconBackgroundColor = const Color(
        0xFFEF4444,
      ).withOpacity(isDark ? 0.2 : 0.1);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Ícone da categoria
              Container(
                width: isSmallScreen ? 44 : 52,
                height: isSmallScreen ? 44 : 52,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    AppConstants.categoryEmojis[transaction.category] ?? '📦',
                    style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              // Informações da transação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            transaction.category,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12,
                              fontWeight: FontWeight.w400,
                              color: textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: dividerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppFormatters.formatRelativeDate(transaction.date),
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Status badge se pendente
                    if (transaction.isPending) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF59E0B,
                          ).withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Aguardando aprovação',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              // Valor - usa FittedBox para nunca quebrar
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${transaction.isIncome ? '+' : '-'} ${AppFormatters.formatCurrency(transaction.amount)}',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          color: amountColor,
                        ),
                      ),
                    ),
                    // Botões de ação para transações pendentes
                    if (transaction.isPending &&
                        (onApprove != null || onReject != null)) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onApprove != null)
                            InkWell(
                              onTap: onApprove,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          if (onApprove != null && onReject != null)
                            const SizedBox(width: 8),
                          if (onReject != null)
                            InkWell(
                              onTap: onReject,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
