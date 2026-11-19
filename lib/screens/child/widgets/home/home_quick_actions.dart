import 'package:flutter/material.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/home/home_action_card.dart';

/// Seção "O que você quer fazer?" com os quatro atalhos da home.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.isSmallScreen,
    required this.claimShareSubtitle,
    required this.onDailyMissionsTap,
    required this.onNewGoalTap,
    required this.onRequestMoneyTap,
    required this.onClaimShareTap,
  });

  final bool isSmallScreen;
  final String claimShareSubtitle;
  final VoidCallback onDailyMissionsTap;
  final VoidCallback onNewGoalTap;
  final VoidCallback onRequestMoneyTap;
  final VoidCallback onClaimShareTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      LummyColors.blue500,
                      LummyColors.violet500,
                    ] // Azul → Roxo como no site
                  : [LummyColors.slate800, LummyColors.slate800],
            ).createShader(bounds),
            child: Text(
              'O que você quer fazer?',
              style: LummyFonts.body(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onDailyMissionsTap,
                      child: HomeActionCard(
                        title: 'Missões Diárias',
                        subtitle: 'Complete desafios e ganhe pontos',
                        icon: Icons.emoji_events_outlined,
                        color: LummyColors.amber500,
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: onNewGoalTap,
                      child: HomeActionCard(
                        title: 'Nova Meta',
                        subtitle: 'Defina um novo objetivo',
                        icon: Icons.flag_outlined,
                        color: LummyColors.violet500,
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onRequestMoneyTap,
                      child: HomeActionCard(
                        title: 'Pedir Dinheiro',
                        subtitle: 'Peça dinheiro ao responsável',
                        icon: Icons.request_quote_rounded,
                        color: LummyColors.emerald500,
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: onClaimShareTap,
                      child: HomeActionCard(
                        title: 'Retirar Minha Parte',
                        subtitle: claimShareSubtitle,
                        icon: Icons.payments_rounded,
                        color: LummyColors.emerald500,
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
