import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "E-mail do responsável" field.
class RegisterEmailField extends StatelessWidget {
  /// Theme read by the screen with its own context, i.e. from ABOVE the
  /// screen's `Theme(data: AppTheme.lightTheme)` override (kept as in the
  /// original code, which called `Theme.of(context)` with the State context).
  final ThemeData theme;
  final bool isVerySmallScreen;
  final TextEditingController controller;
  final bool focused;
  final ValueChanged<bool> onFocusChange;

  const RegisterEmailField({
    super.key,
    required this.theme,
    required this.isVerySmallScreen,
    required this.controller,
    required this.focused,
    required this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: LummyFonts.body(
          fontSize: isVerySmallScreen ? 15 : 17,
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'E-mail do responsável',
          hintStyle: LummyFonts.body(
            color: theme.inputDecorationTheme.hintStyle?.color,
            fontSize: isVerySmallScreen ? 15 : 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
          errorStyle: LummyFonts.body(
            fontSize: isVerySmallScreen ? 11 : 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira o e-mail do responsável';
          }
          if (!RegExp(
            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
          ).hasMatch(value)) {
            return 'Por favor, insira um e-mail válido';
          }
          return null;
        },
      ),
    );
  }
}
