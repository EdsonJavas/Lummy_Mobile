import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Lummy" wordmark shown at the top-left of the register screen.
class RegisterLogo extends StatelessWidget {
  /// Theme read by the screen with its own context, i.e. from ABOVE the
  /// screen's `Theme(data: AppTheme.lightTheme)` override (kept as in the
  /// original code, which called `Theme.of(context)` with the State context).
  final ThemeData theme;
  final bool isVerySmallScreen;

  const RegisterLogo({
    super.key,
    required this.theme,
    required this.isVerySmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          top: isVerySmallScreen ? 10 : 20,
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
                      color: LummyColors.brandNavy,
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
