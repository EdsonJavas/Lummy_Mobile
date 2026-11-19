import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Linha "Não tem uma conta? Registre-se".
class LoginRegisterPrompt extends StatelessWidget {
  final bool isVerySmallScreen;
  /// Tema lido pela LoginScreen com o próprio context, ou seja, acima do
  /// wrapper Theme(AppTheme.lightTheme) da tela (mantém o comportamento original).
  final ThemeData theme;
  final VoidCallback onRegisterTap;

  const LoginRegisterPrompt({
    super.key,
    required this.isVerySmallScreen,
    required this.theme,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem uma conta?',
          style: LummyFonts.body(
            fontSize: isVerySmallScreen ? 12 : 14,
            color: theme.brightness == Brightness.dark
                ? LummyColors.slate300
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
        TextButton(
          onPressed: onRegisterTap,
          child: Text(
            'Registre-se',
            style: LummyFonts.body(
              fontSize: isVerySmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
