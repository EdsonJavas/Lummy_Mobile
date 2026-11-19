import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Campo de senha estilizado do login (com botão de mostrar/ocultar).
class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPasswordVisible;
  final bool isFocused;
  final ValueChanged<bool> onFocusChange;
  final VoidCallback onToggleVisibility;
  final bool isVerySmallScreen;
  /// Tema lido pela LoginScreen com o próprio context, ou seja, acima do
  /// wrapper Theme(AppTheme.lightTheme) da tela (mantém o comportamento original).
  final ThemeData theme;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.isPasswordVisible,
    required this.isFocused,
    required this.onFocusChange,
    required this.onToggleVisibility,
    required this.isVerySmallScreen,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        obscureText: !isPasswordVisible,
        style: LummyFonts.body(
          fontSize: isVerySmallScreen ? 14 : 16,
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Sua Senha',
          hintStyle: LummyFonts.body(
            color: theme.inputDecorationTheme.hintStyle?.color,
            fontSize: isVerySmallScreen ? 14 : 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isFocused
                ? theme.colorScheme.primary
                : theme.iconTheme.color,
            size: isVerySmallScreen ? 20 : 22,
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isVerySmallScreen ? 16 : 20,
            vertical: isVerySmallScreen ? 14 : 18,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isFocused
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
              size: isVerySmallScreen ? 20 : 22,
            ),
            onPressed: onToggleVisibility,
          ),
          errorStyle: LummyFonts.body(
            fontSize: isVerySmallScreen ? 10 : 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira sua senha';
          }
          if (value.length < 6) {
            return 'A senha deve ter pelo menos 6 caracteres';
          }
          return null;
        },
      ),
    );
  }
}
