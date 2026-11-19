import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Título "Faça Login" - "og" em laranja e azul como Lummy.
class LoginTitle extends StatelessWidget {
  final bool isVerySmallScreen;
  /// Tema lido pela LoginScreen com o próprio context, ou seja, acima do
  /// wrapper Theme(AppTheme.lightTheme) da tela (mantém o comportamento original).
  final ThemeData theme;

  const LoginTitle({
    super.key,
    required this.isVerySmallScreen,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: LummyFonts.body(
          fontSize: isVerySmallScreen ? 24 : 28,
          fontWeight: FontWeight.w600,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : LummyColors.slate800,
        ),
        children: [
          const TextSpan(text: 'Faça L'),
          TextSpan(
            text: 'o',
            style: LummyFonts.body(
              fontSize: isVerySmallScreen ? 24 : 28,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          TextSpan(
            text: 'g',
            style: LummyFonts.body(
              fontSize: isVerySmallScreen ? 24 : 28,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? LummyColors.blue400
                  : LummyColors.brandNavy,
            ),
          ),
          const TextSpan(text: 'in'),
        ],
      ),
    );
  }
}
