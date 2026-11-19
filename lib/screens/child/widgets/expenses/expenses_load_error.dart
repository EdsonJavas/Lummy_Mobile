import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Estado de erro ao carregar os gastos, com botão para tentar de novo.
class ExpensesLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ExpensesLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: isDark ? LummyColors.slate500 : LummyColors.slate400,
            ),
            const Gap(20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: LummyFonts.body(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Gap(28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Tentar de novo',
                style: LummyFonts.body(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
