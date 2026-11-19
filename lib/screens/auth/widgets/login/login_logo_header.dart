import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Logo "Lummy" no topo da tela de login.
class LoginLogoHeader extends StatelessWidget {
  final bool isVerySmallScreen;
  /// Tema lido pela LoginScreen com o próprio context, ou seja, acima do
  /// wrapper Theme(AppTheme.lightTheme) da tela (mantém o comportamento original).
  final ThemeData theme;

  const LoginLogoHeader({
    super.key,
    required this.isVerySmallScreen,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          top: isVerySmallScreen ? 10 : 20, // Reduzido de 30
        ),
        child: Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Lu',
                    style: LummyFonts.logo(
                      fontSize: isVerySmallScreen ? 28 : 32,
                      fontWeight: FontWeight.w400,
                      color:
                          theme.brightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'm',
                    style: LummyFonts.logo(
                      fontSize: isVerySmallScreen ? 28 : 32,
                      fontWeight: FontWeight.w400,
                      color: Colors.orange,
                    ),
                  ),
                  TextSpan(
                    text: 'm',
                    style: LummyFonts.logo(
                      fontSize: isVerySmallScreen ? 28 : 32,
                      fontWeight: FontWeight.w400,
                      color: theme.brightness == Brightness.dark
                          ? LummyColors.blue400
                          : LummyColors.brandNavy,
                    ),
                  ),
                  TextSpan(
                    text: 'y',
                    style: LummyFonts.logo(
                      fontSize: isVerySmallScreen ? 28 : 32,
                      fontWeight: FontWeight.w400,
                      color:
                          theme.brightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
