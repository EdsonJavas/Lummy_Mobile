import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Cabeçalho da tela de missões diárias com pontos e progresso do dia.
class DailyMissionsHeader extends StatelessWidget {
  const DailyMissionsHeader({
    super.key,
    required this.isSmallScreen,
    required this.earnedPoints,
    required this.totalPoints,
    required this.completedMissions,
    required this.missions,
    required this.onBack,
  });

  final bool isSmallScreen;
  final int earnedPoints;
  final int totalPoints;
  final int completedMissions;
  final List<Map<String, dynamic>> missions;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              Theme.of(context).brightness ==
                  Brightness.dark
              ? [
                  LummyColors.violet500,
                  LummyColors.blue500,
                ]
              : [
                  LummyColors.blue800,
                  LummyColors.blue900,
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 20.0 : 24.0,
        MediaQuery.of(context).padding.top + 16,
        isSmallScreen ? 20.0 : 24.0,
        isSmallScreen ? 20.0 : 24.0,
      ),
      child: Column(
        children: [
          // Botão voltar e título
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  'Missões Diárias',
                  style: LummyFonts.body(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                width: 48,
              ), // Para centralizar o título
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu Progresso',
                    style: LummyFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        earnedPoints.toString(),
                        style: LummyFonts.body(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ' / $totalPoints',
                        style: LummyFonts.body(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pontos hoje',
                    style: LummyFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$completedMissions/${missions.length}',
                      style: LummyFonts.body(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Completas',
                      style: LummyFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barra de progresso melhorada
          missions.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso Diário',
                          style: LummyFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                        Text(
                          missions.isEmpty
                              ? '0%'
                              : '${((completedMissions / missions.length) * 100).toStringAsFixed(0)}%',
                          style: LummyFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: missions.isEmpty
                              ? 0.0
                              : (completedMissions /
                                        missions.length)
                                    .clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                    colors: [
                                      LummyColors.emerald500,
                                      LummyColors.emerald400,
                                      LummyColors.emerald300,
                                    ],
                                  ),
                              borderRadius:
                                  BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(
                                    0,
                                    0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
