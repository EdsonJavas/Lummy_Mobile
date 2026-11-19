import 'package:flutter/material.dart';

import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// "Envio Rápido" card with the pre-defined amount chips.
class DistributionQuickSendSection extends StatelessWidget {
  final bool isDark;
  final ValueChanged<double> onQuickSend;

  const DistributionQuickSendSection({
    super.key,
    required this.isDark,
    required this.onQuickSend,
  });

  static const _orange = LummyColors.amber500;
  static const _amber = LummyColors.amber600;
  static const _blue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [LummyColors.slate700, LummyColors.slate800]
              : const [Colors.white, LummyColors.cream],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? LummyColors.slate600 : _orange.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.24)
                : _orange.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                  gradient: const LinearGradient(colors: [_orange, _amber]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'Envio Rápido',
                    style: LummyFonts.body(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : LummyColors.slate800,
                    ),
                  ),
                  Text(
                    'Selecione um valor pré-definido',
                    style: LummyFonts.body(
                      fontSize: 13.5,
                      color: isDark
                          ? LummyColors.slate400
                          : LummyColors.slate500,
                    ),
                  ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Quick amount buttons - Design moderno
          Row(
            children: [
              Expanded(
                child: _buildQuickAmountChip(
                  10.0,
                  _orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAmountChip(
                  20.0,
                  _amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAmountChip(
                  50.0,
                  _blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAmountChip(
                  100.0,
                  _purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountChip(
    double amount,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onQuickSend(amount),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: isDark ? 0.2 : 0.12),
                color.withValues(alpha: isDark ? 0.1 : 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppFormatters.formatCurrency(amount),
                style: LummyFonts.body(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enviar',
                style: LummyFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? LummyColors.slate400
                      : LummyColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
