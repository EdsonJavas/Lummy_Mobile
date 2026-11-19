import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/shared/widgets/widgets.dart';

/// Cabeçalho da home: saudação com o nome da criança e avatar (abre o perfil).
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.isSmallScreen,
    required this.onAvatarTap,
  });

  final String userName;
  final bool isSmallScreen;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.all(isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Olá, ',
                      style: LummyFonts.body(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Flexible(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            primary,
                            LummyColors.violet500,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          userName,
                          style: LummyFonts.body(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  'Como estão suas finanças hoje?',
                  style: LummyFonts.body(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAvatarTap,
            child: CachedAvatar(
              imageUrl:
                  'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png',
              size: isSmallScreen ? 50 : 56,
              borderColor: primary,
              borderWidth: 2,
              fallbackIcon: Icons.person_rounded,
              fallbackIconColor: primary,
            ),
          ),
        ],
      ),
    );
  }
}
