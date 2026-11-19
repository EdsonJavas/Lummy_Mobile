import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Campo de e-mail estilizado do login.
class LoginEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isFocused;
  final ValueChanged<bool> onFocusChange;
  final bool isVerySmallScreen;
  /// Tema lido pela LoginScreen com o próprio context, ou seja, acima do
  /// wrapper Theme(AppTheme.lightTheme) da tela (mantém o comportamento original).
  final ThemeData theme;

  const LoginEmailField({
    super.key,
    required this.controller,
    required this.isFocused,
    required this.onFocusChange,
    required this.isVerySmallScreen,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: LummyFonts.body(
          fontSize: isVerySmallScreen
              ? 14
              : 16, // Responsivo
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Seu E-mail',
          hintStyle: LummyFonts.body(
            color: theme.inputDecorationTheme.hintStyle?.color,
            fontSize: isVerySmallScreen ? 14 : 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: isFocused
                ? theme.colorScheme.primary
                : theme.iconTheme.color,
            size: isVerySmallScreen
                ? 20
                : 22, // Responsivo
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isVerySmallScreen ? 16 : 20,
            vertical: isVerySmallScreen ? 14 : 18,
          ),
          errorStyle: LummyFonts.body(
            fontSize: isVerySmallScreen ? 10 : 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira seu e-mail';
          }
          if (!RegExp(
            r'^[\w-\.]+@[\w-]+\.[\w-]{2,4}$',
          ).hasMatch(value)) {
            return 'Por favor, insira um e-mail válido';
          }
          return null;
        },
      ),
    );
  }
}
