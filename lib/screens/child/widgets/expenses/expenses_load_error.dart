import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Estado de erro ao carregar os gastos, com botão para tentar de novo.
///
/// Visual do redesenho V1 (claro ou escuro, `context.cores`): quadrado neutro com o
/// ícone da aba, mensagem em tinta e pílula na cor do tema (tentar de novo não
/// mexe em dinheiro, então não é laranja).
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
    final tema = ChildThemeColorController.of(context).tema;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          32,
          24,
          32,
          ChildBottomNavMetrics.scrollBottomPadding(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeutralIconTile(
              glyph: LummyGlyphs.receipt,
              size: 56,
              radius: 18,
              iconSize: 26,
              iconColor: context.cores.iconeApagado,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: LummyText.poppins(context, size: 15, weight: FontWeight.w500, height: 1.45),
            ),
            const SizedBox(height: 24),
            LummyPillButton(rotulo: 'Tentar de novo', cor: tema, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}
