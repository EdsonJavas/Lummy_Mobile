import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Sua Senha" field with visibility toggle.
class RegisterPasswordField extends StatelessWidget {
  /// Theme read by the screen with its own context, i.e. from ABOVE the
  /// screen's `Theme(data: AppTheme.lightTheme)` override (kept as in the
  /// original code, which called `Theme.of(context)` with the State context).
  final ThemeData theme;
  final bool isVerySmallScreen;
  final TextEditingController controller;
  final bool focused;
  final bool isVisible;
  final ValueChanged<bool> onFocusChange;
  final VoidCallback onToggleVisibility;

  const RegisterPasswordField({
    super.key,
    required this.theme,
    required this.isVerySmallScreen,
    required this.controller,
    required this.focused,
    required this.isVisible,
    required this.onFocusChange,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        style: LummyFonts.body(
          fontSize: isVerySmallScreen ? 15 : 17,
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Sua Senha',
          hintStyle: LummyFonts.body(
            color: theme.inputDecorationTheme.hintStyle?.color,
            fontSize: isVerySmallScreen ? 15 : 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: focused
                ? theme.colorScheme.primary
                : theme.iconTheme.color,
            size: isVerySmallScreen ? 22 : 24,
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isVerySmallScreen ? 18 : 22,
            vertical: isVerySmallScreen ? 16 : 20,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: focused
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
              size: isVerySmallScreen ? 22 : 24,
            ),
            onPressed: onToggleVisibility,
          ),
          errorStyle: LummyFonts.body(
            fontSize: isVerySmallScreen ? 11 : 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Insira a senha';
          }
          if (value.length < 6) {
            return 'Mín. 6 caracteres';
          }
          return null;
        },
      ),
    );
  }
}

/// "Confirme a Senha" field; validates against [passwordController].
class RegisterConfirmPasswordField extends StatelessWidget {
  /// Theme read by the screen with its own context, i.e. from ABOVE the
  /// screen's `Theme(data: AppTheme.lightTheme)` override (kept as in the
  /// original code, which called `Theme.of(context)` with the State context).
  final ThemeData theme;
  final bool isVerySmallScreen;
  final TextEditingController controller;
  final TextEditingController passwordController;
  final bool focused;
  final bool isVisible;
  final ValueChanged<bool> onFocusChange;
  final VoidCallback onToggleVisibility;

  const RegisterConfirmPasswordField({
    super.key,
    required this.theme,
    required this.isVerySmallScreen,
    required this.controller,
    required this.passwordController,
    required this.focused,
    required this.isVisible,
    required this.onFocusChange,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        style: LummyFonts.body(
          fontSize: isVerySmallScreen ? 15 : 17,
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Confirme a Senha',
          hintStyle: LummyFonts.body(
            color: theme.inputDecorationTheme.hintStyle?.color,
            fontSize: isVerySmallScreen ? 15 : 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: focused
                ? theme.colorScheme.primary
                : theme.iconTheme.color,
            size: isVerySmallScreen ? 22 : 24,
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isVerySmallScreen ? 18 : 22,
            vertical: isVerySmallScreen ? 16 : 20,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: focused
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
              size: isVerySmallScreen ? 22 : 24,
            ),
            onPressed: onToggleVisibility,
          ),
          errorStyle: LummyFonts.body(
            fontSize: isVerySmallScreen ? 11 : 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Confirme a senha';
          }
          if (value != passwordController.text) {
            return 'Senhas não coincidem';
          }
          return null;
        },
      ),
    );
  }
}
