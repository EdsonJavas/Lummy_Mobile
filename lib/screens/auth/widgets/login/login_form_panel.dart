import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/auth/widgets/login/login_form_top_clipper.dart';

/// Painel branco com curva no topo que envolve o formulário de login.
class LoginFormPanel extends StatelessWidget {
  final bool isVerySmallScreen;
  final double screenHeight;
  final double keyboardHeight;
  /// Tema lido pela LoginScreen com o próprio context, ou seja, acima do
  /// wrapper Theme(AppTheme.lightTheme) da tela (mantém o comportamento original).
  final ThemeData theme;
  final Widget child;

  const LoginFormPanel({
    super.key,
    required this.isVerySmallScreen,
    required this.screenHeight,
    required this.keyboardHeight,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: LoginFormTopClipper(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: isVerySmallScreen
              ? screenHeight * 0.55
              : screenHeight * 0.5,
          maxHeight: isVerySmallScreen
              ? screenHeight * 0.75
              : screenHeight * 0.7,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: theme.brightness == Brightness.dark
              ? Border.all(color: LummyColors.slate600)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: isVerySmallScreen
                ? 20.0
                : 24.0, // Menos padding em telas pequenas
            right: isVerySmallScreen ? 20.0 : 24.0,
            top: isVerySmallScreen ? 20.0 : 24.0,
            bottom:
                (isVerySmallScreen ? 20.0 : 24.0) + keyboardHeight,
          ),
          child: child,
        ),
      ),
    );
  }
}
