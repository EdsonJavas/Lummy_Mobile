import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/profile/profile_badge.dart';

/// Seção "Medalhas Conquistadas" do perfil.
class ProfileAchievementsSection extends StatelessWidget {
  const ProfileAchievementsSection({
    super.key,
    required this.isLoadingStats,
    required this.achievements,
  });

  final bool isLoadingStats;
  final List<Map<String, dynamic>> achievements;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: Theme.of(context).dividerColor)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Esta é a Row que estava causando o overflow
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // Adicionado Expanded aqui
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            LummyColors.brandOrange,
                            LummyColors.red500,
                          ] // Laranja → Vermelho como no site
                        : [LummyColors.slate800, LummyColors.slate800],
                  ).createShader(bounds),
                  child: Text(
                    'Medalhas Conquistadas',
                    style: LummyFonts.body(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Adicionado para evitar overflow de texto
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [LummyColors.brandOrange, LummyColors.brandOrangeMid],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: LummyColors.brandOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    final completedCount = achievements
                        .where((a) => a['is_completed'] == true)
                        .length;
                    final totalCount = achievements.isNotEmpty
                        ? achievements.length
                        : 5; // Default 5 se não houver conquistas
                    final uncompletedCount = totalCount - completedCount;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Medalhas conquistadas
                        ...List.generate(
                          completedCount > 5 ? 5 : completedCount,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (completedCount > 0 && uncompletedCount > 0) ...[
                          const SizedBox(width: 6),
                          // Separador
                          Container(
                            width: 1,
                            height: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                        ],

                        // Medalhas não conquistadas
                        ...List.generate(
                          uncompletedCount > 5 ? 5 : uncompletedCount,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          '$completedCount/$totalCount',
                          style: LummyFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          isLoadingStats
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : achievements.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma conquista ainda',
                          style: LummyFonts.body(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete missões para desbloquear conquistas!',
                          style: LummyFonts.body(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: achievements.map((achievement) {
                      final title = achievement['title'] ?? 'Conquista';
                      final emoji = achievement['emoji'] ?? '🏆';
                      final isCompleted = achievement['is_completed'] == true;

                      // Quebrar título em 2 linhas se necessário
                      final titleParts = title.split(' ');
                      String displayTitle;
                      if (titleParts.length > 1) {
                        final mid = (titleParts.length / 2).ceil();
                        displayTitle =
                            '${titleParts.sublist(0, mid).join(' ')}\n${titleParts.sublist(mid).join(' ')}';
                      } else {
                        displayTitle = title;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ProfileBadge(
                          emoji: emoji,
                          label: displayTitle,
                          isUnlocked: isCompleted,
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
