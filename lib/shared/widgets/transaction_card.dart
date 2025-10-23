import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';
import 'custom_card.dart';

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
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    // Cor baseada no tipo e status
    Color amountColor;
    IconData icon;
    Color iconBackgroundColor;

    if (transaction.isIncome) {
      amountColor = const Color(AppConstants.successGreen);
      icon = Icons.arrow_downward;
      iconBackgroundColor = const Color(
        AppConstants.successGreen,
      ).withOpacity(0.1);
    } else {
      amountColor = const Color(AppConstants.errorRed);
      icon = Icons.arrow_upward;
      iconBackgroundColor = const Color(AppConstants.errorRed).withOpacity(0.1);
    }

    return CustomCard(
      onTap: onTap,
      style: CardStyle.filled,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          // Ícone da categoria
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                    color: const Color(AppConstants.textPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction.category,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(AppConstants.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(AppConstants.textLight),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppFormatters.formatRelativeDate(transaction.date),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(AppConstants.textSecondary),
                      ),
                    ),
                  ],
                ),
                // Status badge se pendente
                if (transaction.isPending) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        AppConstants.warningOrange,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Aguardando aprovação',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(AppConstants.warningOrange),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          // Valor
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isIncome ? '+' : '-'} ${AppFormatters.formatCurrency(transaction.amount)}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              // Botões de ação para transações pendentes
              if (transaction.isPending &&
                  (onApprove != null || onReject != null)) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (onApprove != null)
                      InkWell(
                        onTap: onApprove,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(
                              AppConstants.successGreen,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(AppConstants.successGreen),
                          ),
                        ),
                      ),
                    if (onApprove != null && onReject != null)
                      const SizedBox(width: 8),
                    if (onReject != null)
                      InkWell(
                        onTap: onReject,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(
                              AppConstants.errorRed,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(AppConstants.errorRed),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
