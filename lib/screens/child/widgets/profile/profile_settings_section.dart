import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/profile/profile_setting_item.dart';
import 'package:lummy/screens/child/widgets/profile/profile_theme_color_item.dart';
import 'package:lummy/screens/child/widgets/profile/profile_theme_setting_item.dart';

/// Seção "Configurações" do perfil.
class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    super.key,
    required this.onEditProfileTap,
    required this.onNotificationsTap,
    required this.onHelpTap,
    required this.onLogoutTap,
  });

  final VoidCallback onEditProfileTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onHelpTap;
  final VoidCallback onLogoutTap;

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
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      LummyColors.blue500,
                      LummyColors.emerald500,
                    ] // Azul → Verde como no site
                  : [LummyColors.slate800, LummyColors.slate800],
            ).createShader(bounds),
            child: Text(
              'Configurações',
              style: LummyFonts.body(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ProfileSettingItem(
            icon: Icons.edit_rounded,
            title: 'Editar Perfil',
            subtitle: 'Altere suas informações pessoais',
            color: LummyColors.blue800,
            onTap: onEditProfileTap,
          ),
          ProfileSettingItem(
            icon: Icons.notifications_rounded,
            title: 'Notificações',
            subtitle: 'Gerencie suas notificações',
            color: LummyColors.violet500,
            onTap: onNotificationsTap,
          ),
          const ProfileThemeSettingItem(),
          const ProfileThemeColorItem(),
          ProfileSettingItem(
            icon: Icons.help_rounded,
            title: 'Ajuda',
            subtitle: 'Tire suas dúvidas',
            color: LummyColors.emerald500,
            onTap: onHelpTap,
          ),
          ProfileSettingItem(
            icon: Icons.logout_rounded,
            title: 'Sair',
            subtitle: 'Desconectar da conta',
            color: LummyColors.red500,
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}
