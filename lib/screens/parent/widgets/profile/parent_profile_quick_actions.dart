import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// "Ações Rápidas" card (edit profile / security).
class ParentProfileQuickActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;

  const ParentProfileQuickActions({
    super.key,
    required this.isDark,
    required this.onEditProfile,
    required this.onChangePassword,
  });

  static const _blue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [_blue.withValues(alpha: 0.15), _purple.withValues(alpha: 0.1)]
              : [_blue.withValues(alpha: 0.08), _purple.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _blue.withValues(alpha: isDark ? 0.2 : 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt_rounded, color: _blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Ações Rápidas',
                style: LummyFonts.body(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : LummyColors.slate800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Editar Perfil',
                  color: _orange,
                  isDark: isDark,
                  onTap: onEditProfile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.lock_rounded,
                  label: 'Segurança',
                  color: _green,
                  isDark: isDark,
                  onTap: onChangePassword,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? LummyColors.darkMaterial : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: LummyFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : LummyColors.slate800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
