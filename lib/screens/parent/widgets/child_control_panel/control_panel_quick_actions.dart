import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Seção "Ações Rápidas" do painel de controle do filho.
class ControlPanelQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onOpenMissions;
  final VoidCallback onOpenAchievements;
  final VoidCallback onOpenSettings;

  const ControlPanelQuickActions({
    super.key,
    required this.isDark,
    required this.onOpenMissions,
    required this.onOpenAchievements,
    required this.onOpenSettings,
  });

  static const _purple = LummyColors.violet500;
  static const _blue = LummyColors.blue500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ações Rápidas', isDark),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Gerenciar Missões',
                  Icons.assignment_rounded,
                  _purple,
                  isDark,
                  onOpenMissions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Conquistas',
                  Icons.emoji_events_rounded,
                  _orange,
                  isDark,
                  onOpenAchievements,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Configurações',
            Icons.tune_rounded,
            _blue,
            isDark,
            onOpenSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: isDark
            ? [LummyColors.blue500, LummyColors.violet500]
            : [LummyColors.slate800, LummyColors.slate800],
      ).createShader(bounds),
      child: Text(
        title,
        style: LummyFonts.body(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: LummyFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.6), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
