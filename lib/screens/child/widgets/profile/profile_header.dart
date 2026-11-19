import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lummy/core/providers/theme_provider.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/shared/widgets/cached_image.dart';
import 'package:lummy/shared/widgets/widgets.dart';

/// Cabeçalho do perfil: imagem de fundo, avatar, nível, pontos e nome.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.isLoadingStats,
    required this.userLevel,
    required this.totalPoints,
    required this.userName,
    required this.userRole,
    required this.onBack,
  });

  final double screenWidth;
  final double screenHeight;
  final bool isLoadingStats;
  final int userLevel;
  final int totalPoints;
  final String userName;
  final String userRole;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.60,
      width: double.infinity,
      child: Stack(
        children: [
          SizedBox(
            height: screenHeight * 0.60,
            width: double.infinity,
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Container(
                  decoration: BoxDecoration(
                    image: themeProvider.isDarkMode
                        ? const DecorationImage(
                            image: AssetImage('dark.png'),
                            fit: BoxFit.cover,
                            opacity: 0.8,
                          )
                        : null,
                  ),
                  child: themeProvider.isDarkMode
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              stops: const [0.0, 0.7, 1.0],
                            ),
                          ),
                        )
                      : CachedImage(
                          imageUrl:
                              'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/fotocriancafodase%201-MFp8K8GLj7deZeGCFVqMJVDVgEtfsc.png',
                          width: double.infinity,
                          height: screenHeight * 0.60,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.topCenter,
                                colors: [LummyColors.skyWeb, LummyColors.materialGreen],
                              ),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: 55,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Seu Perfil',
                style: LummyFonts.body(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.12,
            left: screenWidth / 2 - 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CachedAvatar(
                imageUrl:
                    'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png',
                size: 120,
                borderColor: Colors.white,
                borderWidth: 4,
                fallbackIcon: Icons.person_rounded,
                fallbackIconColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.27,
            left: screenWidth / 2 - 80,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: LummyColors.brandOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoadingStats
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            userLevel.toString(),
                            style: LummyFonts.body(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: LummyColors.brandOrange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        isLoadingStats
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                totalPoints.toString(),
                                style: LummyFonts.body(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                    Text(
                      'PONTOS TOTAIS',
                      style: LummyFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.36,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  userName,
                  style: LummyFonts.body(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    userRole,
                    style: LummyFonts.body(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
