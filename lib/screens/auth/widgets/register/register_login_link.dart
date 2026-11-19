import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Já tem uma conta Lummy? Faça Login" link.
class RegisterLoginLink extends StatelessWidget {
  final bool isVerySmallScreen;
  final VoidCallback onTap;

  const RegisterLoginLink({
    super.key,
    required this.isVerySmallScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Já tem uma conta Lummy? ',
                style: LummyFonts.body(
                  color: LummyColors.materialGrey,
                  fontSize: isVerySmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Faça L',
                style: LummyFonts.body(
                  color: LummyColors.materialGrey,
                  fontSize: isVerySmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: 'o',
                style: LummyFonts.body(
                  color: Colors.orange,
                  fontSize: isVerySmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: 'g',
                style: LummyFonts.body(
                  color: LummyColors.brandNavy,
                  fontSize: isVerySmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: 'in',
                style: LummyFonts.body(
                  color: LummyColors.materialGrey,
                  fontSize: isVerySmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
