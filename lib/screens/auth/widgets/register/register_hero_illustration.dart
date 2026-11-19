import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Astronaut illustration (same size as on the login screen).
class RegisterHeroIllustration extends StatelessWidget {
  final bool isVerySmallScreen;
  final bool isSmallScreen;

  const RegisterHeroIllustration({
    super.key,
    required this.isVerySmallScreen,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.network(
        'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/astronauta-lummy-OXK8DpNpgdSxKxNZKtIyQynALBlh6n.svg',
        height: isVerySmallScreen
            ? 250
            : (isSmallScreen ? 300 : 380),
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          height: isVerySmallScreen
              ? 250
              : (isSmallScreen ? 300 : 380),
          width: isVerySmallScreen
              ? 250
              : (isSmallScreen ? 300 : 380),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              isVerySmallScreen ? 125 : (isSmallScreen ? 150 : 190),
            ),
          ),
          child: Icon(
            Icons.person,
            size: isVerySmallScreen
                ? 100
                : (isSmallScreen ? 120 : 180),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
