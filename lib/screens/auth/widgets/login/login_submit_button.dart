import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Botão "Entrar" (gradiente laranja) com indicador de carregamento.
class LoginSubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isVerySmallScreen;
  final VoidCallback onPressed;

  const LoginSubmitButton({
    super.key,
    required this.isLoading,
    required this.isVerySmallScreen,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LummyColors.brandOrange,
            LummyColors.brandOrangeDeep,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          isVerySmallScreen ? 25 : 28,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFFF8C42,
            ).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: isLoading
              ? SizedBox(
                  height: isVerySmallScreen ? 18 : 20,
                  width: isVerySmallScreen ? 18 : 20,
                  child:
                      const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<
                              Color
                            >(Colors.white),
                      ),
                )
              : Text(
                  'Entrar',
                  style: LummyFonts.body(
                    fontSize: isVerySmallScreen
                        ? 16
                        : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
