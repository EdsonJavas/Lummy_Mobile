import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/daily_missions/daily_mission_card.dart';

/// Lista "Missões de Hoje" (ou o estado vazio quando não há missões).
class DailyMissionsList extends StatelessWidget {
  const DailyMissionsList({
    super.key,
    required this.missions,
    required this.isSmallScreen,
    required this.onCompleteMission,
  });

  final List<Map<String, dynamic>> missions;
  final bool isSmallScreen;

  /// Recebe o id da missão a ser completada.
  final ValueChanged<String> onCompleteMission;

  @override
  Widget build(BuildContext context) {
    return missions.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma missão disponível',
                  style: LummyFonts.body(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'As missões diárias aparecerão aqui!',
                  style: LummyFonts.body(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      LinearGradient(
                        colors:
                            Theme.of(context).brightness ==
                                Brightness.dark
                            ? [
                                LummyColors.blue500,
                                LummyColors.violet500,
                              ] // Azul → Roxo
                            : [
                                LummyColors.slate800,
                                LummyColors.slate800,
                              ],
                      ).createShader(bounds),
                  child: Text(
                    'Missões de Hoje',
                    style: LummyFonts.body(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...missions.map(
                  (mission) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: DailyMissionCard(
                      mission: mission,
                      isSmallScreen: isSmallScreen,
                      onComplete: onCompleteMission,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
