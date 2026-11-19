import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/profile/profile_stat_card.dart';

/// Seção "Minhas Conquistas" com os cartões de estatísticas do perfil.
class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({
    super.key,
    required this.completedGoals,
    required this.totalSaved,
  });

  final int completedGoals;
  final double totalSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    LummyColors.emerald500,
                    LummyColors.violet500,
                  ] // Verde → Roxo como no site
                : [LummyColors.slate800, LummyColors.slate800],
          ).createShader(bounds),
          child: Text(
            'Minhas Conquistas',
            style: LummyFonts.body(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileStatCard(
                label: 'Metas Concluídas',
                value: completedGoals.toString(),
                icon: Icons.flag_rounded,
                color: LummyColors.violet500,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfileStatCard(
                label: 'Total Economizado',
                value: 'R\$ ${totalSaved.toStringAsFixed(0)}',
                icon: Icons.savings_rounded,
                color: LummyColors.emerald500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
