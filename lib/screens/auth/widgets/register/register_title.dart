import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Crie sua conta de Responsável" title.
class RegisterTitle extends StatelessWidget {
  /// Theme read by the screen with its own context, i.e. from ABOVE the
  /// screen's `Theme(data: AppTheme.lightTheme)` override (kept as in the
  /// original code, which called `Theme.of(context)` with the State context).
  final ThemeData theme;
  final bool isVerySmallScreen;

  const RegisterTitle({
    super.key,
    required this.theme,
    required this.isVerySmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors:
            theme.brightness ==
                Brightness.dark
            ? [
                LummyColors.blue500,
                LummyColors.violet500,
              ] // Azul → Roxo como no site
            : [
                theme.textTheme.titleLarge?.color ??
                    LummyColors.slate800,
                theme.textTheme.titleLarge?.color ??
                    LummyColors.slate800,
              ],
      ).createShader(bounds),
      child: Text(
        'Crie sua conta de Responsável',
        style: LummyFonts.body(
          fontSize: isVerySmallScreen ? 24 : 28,
          fontWeight: FontWeight.w600,
          color: Colors
              .white, // This color is masked by the shader
        ),
      ),
    );
  }
}
