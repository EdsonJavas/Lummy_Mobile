import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Botão "Entrar com Digital".
class LoginBiometricButton extends StatelessWidget {
  final bool isVerySmallScreen;
  final VoidCallback onPressed;

  const LoginBiometricButton({
    super.key,
    required this.isVerySmallScreen,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isVerySmallScreen ? 16 : 20,
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(
            Icons.fingerprint,
            color: LummyColors.brandBlue,
          ),
          label: Text(
            'Entrar com Digital',
            style: LummyFonts.body(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: LummyColors.brandBlue,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: LummyColors.brandBlue,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
