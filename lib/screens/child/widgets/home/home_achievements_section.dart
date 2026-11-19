import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/home/home_achievement_item.dart';

/// Seção "Suas Conquistas" da home.
class HomeAchievementsSection extends StatelessWidget {
  const HomeAchievementsSection({
    super.key,
    required this.isSmallScreen,
    required this.achievements,
  });

  final bool isSmallScreen;
  final List<Map<String, dynamic>> achievements;

  @override
  Widget build(BuildContext context) {
    final completedAchievements = achievements
        .where((a) => a['isCompleted'] == true)
        .length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          LummyColors.emerald500,
                          LummyColors.blue500,
                        ] // Verde → Azul como no site
                      : [LummyColors.slate800, LummyColors.slate800],
                ).createShader(bounds),
                child: Text(
                  'Suas Conquistas',
                  style: LummyFonts.body(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$completedAchievements de ${achievements.length}',
                style: LummyFonts.body(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? LummyColors.slate600
                    : LummyColors.slate200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: achievements.asMap().entries.map((entry) {
                final index = entry.key;
                final achievement = entry.value;
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 16),
                    HomeAchievementItem(
                      emoji: achievement['emoji'],
                      title: achievement['title'],
                      description: achievement['description'],
                      isCompleted: achievement['isCompleted'],
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
