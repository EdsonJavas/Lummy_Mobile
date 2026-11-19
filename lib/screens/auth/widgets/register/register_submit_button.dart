import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Gradient "Avançar" button (shows a spinner while [isLoading]).
class RegisterSubmitButton extends StatelessWidget {
  final bool isVerySmallScreen;
  final bool isLoading;
  final VoidCallback? onPressed;

  const RegisterSubmitButton({
    super.key,
    required this.isVerySmallScreen,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: isVerySmallScreen ? 50 : 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LummyColors.brandOrange,
            LummyColors.brandOrangeMid,
          ],
        ),
        borderRadius: BorderRadius.circular(
          isVerySmallScreen ? 25 : 28,
        ),
        boxShadow: [
          BoxShadow(
            color: LummyColors.brandOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isVerySmallScreen ? 25 : 28,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: isVerySmallScreen ? 18 : 20,
                width: isVerySmallScreen ? 18 : 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                ),
              )
            : Text(
                'Avançar',
                style: LummyFonts.body(
                  fontSize: isVerySmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
