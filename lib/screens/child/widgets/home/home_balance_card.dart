import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/formatters.dart';

/// Cartão "Meu Cofrinho" com o saldo atual e as entradas dos últimos 7 dias.
class HomeBalanceCard extends StatelessWidget {
  const HomeBalanceCard({
    super.key,
    required this.isSmallScreen,
    required this.balanceLoadFailed,
    required this.currentBalance,
    required this.weekIncomeTotal,
    required this.onRetry,
  });

  final bool isSmallScreen;
  final bool balanceLoadFailed;
  final double currentBalance;
  final double weekIncomeTotal;

  /// Chamado ao tocar no cartão quando o saldo falhou ao carregar.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: balanceLoadFailed ? onRetry : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
          padding: EdgeInsets.all(isSmallScreen ? 22 : 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [LummyColors.blue800, LummyColors.blue900],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: LummyColors.blue800.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meu Cofrinho',
                    style: LummyFonts.body(
                      fontSize: isSmallScreen ? 17 : 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🐷',
                      style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                balanceLoadFailed
                    ? '—'
                    : 'R\$ ${currentBalance.toStringAsFixed(2)}',
                style: LummyFonts.body(
                  fontSize: isSmallScreen ? 38 : 44,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (balanceLoadFailed) ...[
                const SizedBox(height: 8),
                Text(
                  'Não foi possível carregar o saldo. Toque aqui para tentar de novo.',
                  style: LummyFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 10),
                if (weekIncomeTotal > 0)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: LummyColors.emerald500.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up, color: LummyColors.emerald500, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '+${AppFormatters.formatCurrency(weekIncomeTotal)}',
                              style: LummyFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: LummyColors.emerald500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'entradas nos últimos 7 dias',
                          style: LummyFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Nenhuma entrada registrada nos últimos 7 dias',
                    style: LummyFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
