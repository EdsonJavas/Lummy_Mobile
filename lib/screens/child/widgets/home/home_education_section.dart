import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/home/home_educational_tips.dart';

/// Seção "Aprenda Brincando" com a dica atual e o botão "Próxima Dica".
class HomeEducationSection extends StatelessWidget {
  const HomeEducationSection({
    super.key,
    required this.isSmallScreen,
    required this.educationalTips,
    required this.currentTipIndex,
    required this.onNextTip,
  });

  final bool isSmallScreen;
  final List<EducationalTip> educationalTips;
  final int currentTipIndex;
  final VoidCallback onNextTip;

  @override
  Widget build(BuildContext context) {
    final currentTip = educationalTips[currentTipIndex];

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      LummyColors.brandOrange,
                      LummyColors.emerald500,
                    ] // Laranja → Verde como no site
                  : [LummyColors.slate800, LummyColors.slate800],
            ).createShader(bounds),
            child: Text(
              'Aprenda Brincando',
              style: LummyFonts.body(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<int>(currentTipIndex),
              width: double.infinity,
              constraints: BoxConstraints(minHeight: isSmallScreen ? 200 : 220),
              padding: EdgeInsets.all(isSmallScreen ? 24.0 : 28.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    LummyColors.violet500,
                    LummyColors.violet600,
                    LummyColors.violet700,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: LummyColors.violet500.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: LummyColors.violet500.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          currentTip.emoji,
                          style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTip.category,
                              style: LummyFonts.body(
                                fontSize: isSmallScreen ? 15 : 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Dica ${currentTipIndex + 1} de ${educationalTips.length}',
                              style: LummyFonts.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentTip.content,
                    style: LummyFonts.body(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onNextTip,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: LummyColors.violet500,
                        size: 22,
                      ),
                      label: Text(
                        'Próxima Dica',
                        style: LummyFonts.body(
                          fontSize: isSmallScreen ? 15 : 16,
                          fontWeight: FontWeight.w700,
                          color: LummyColors.violet500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: LummyColors.violet500,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
