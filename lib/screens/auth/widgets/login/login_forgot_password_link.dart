import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Link "Esqueci minha senha".
class LoginForgotPasswordLink extends StatelessWidget {
  final bool isVerySmallScreen;
  final VoidCallback? onPressed;

  const LoginForgotPasswordLink({
    super.key,
    required this.isVerySmallScreen,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Esqueci minha senha',
          style: LummyFonts.body(
            fontSize: isVerySmallScreen ? 12 : 13,
            fontWeight: FontWeight.w500,
            color: LummyColors.brandBlue,
          ),
        ),
      ),
    );
  }
}
