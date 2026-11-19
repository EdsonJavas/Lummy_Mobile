import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Nome do responsável" field.
class RegisterNameField extends StatelessWidget {
  /// Theme read by the screen with its own context, i.e. from ABOVE the
  /// screen's `Theme(data: AppTheme.lightTheme)` override (kept as in the
  /// original code, which called `Theme.of(context)` with the State context).
  final ThemeData theme;
  final bool isVerySmallScreen;
  final TextEditingController controller;
  final bool focused;
  final ValueChanged<bool> onFocusChange;

  const RegisterNameField({
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
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        style: LummyFonts.body(
          fontSize: isVerySmallScreen ? 15 : 17,
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Nome do responsável',
          hintStyle: LummyFonts.body(
            color: theme.inputDecorationTheme.hintStyle?.color,
            fontSize: isVerySmallScreen ? 15 : 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.person_outline,
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
          errorStyle: LummyFonts.body(
            fontSize: isVerySmallScreen ? 11 : 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Insira o nome';
          }
          if (value.trim().length < 2) {
            return 'Nome com 2+ caracteres';
          }
          return null;
        },
      ),
    );
  }
}

/// "CPF" field (formats while typing and validates the check digits).
class RegisterCpfField extends StatelessWidget {
  /// Theme read by the screen with its own context, i.e. from ABOVE the
  /// screen's `Theme(data: AppTheme.lightTheme)` override (kept as in the
  /// original code, which called `Theme.of(context)` with the State context).
  final ThemeData theme;
  final bool isVerySmallScreen;
  final TextEditingController controller;
  final bool focused;
  final ValueChanged<bool> onFocusChange;
  final String Function(String cpf) formatCPF;
  final bool Function(String cpf) isValidCPF;

  const RegisterCpfField({
    super.key,
    required this.theme,
    required this.isVerySmallScreen,
    required this.controller,
    required this.focused,
    required this.onFocusChange,
    required this.formatCPF,
    required this.isValidCPF,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
          TextInputFormatter.withFunction((
            oldValue,
            newValue,
          ) {
            final formatted = formatCPF(newValue.text);
            return TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(
                offset: formatted.length,
              ),
            );
          }),
        ],
        style: LummyFonts.body(
          fontSize: isVerySmallScreen ? 15 : 17,
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'CPF',
          hintStyle: LummyFonts.body(
            color: theme.inputDecorationTheme.hintStyle?.color,
            fontSize: isVerySmallScreen ? 15 : 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.badge_outlined,
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
          errorStyle: LummyFonts.body(
            fontSize: isVerySmallScreen ? 11 : 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Insira o CPF';
          }
          if (!isValidCPF(value)) {
            return 'CPF inválido';
          }
          return null;
        },
      ),
    );
  }
}
