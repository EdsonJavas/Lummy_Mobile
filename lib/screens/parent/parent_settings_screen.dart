import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lummy/core/providers/theme_provider.dart';
import 'package:lummy/di/locator.dart';
import 'package:lummy/domain/repositories/auth_repository.dart';
import 'package:lummy/application/app_facade.dart';
import 'package:lummy/screens/auth/login_screen.dart';
import 'package:lummy/screens/parent/parent_change_password_screen.dart';
import 'package:lummy/screens/parent/parent_help_screen.dart';
import 'package:lummy/screens/parent/parent_notifications_screen.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  static const _blue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;
  static const _orange = LummyColors.amber500;
  static const _red = LummyColors.red500;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? LummyColors.darkMaterial : LummyColors.slate50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 12,
                20,
                24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [LummyColors.violet950, LummyColors.violet900]
                      : [_blue, _purple],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Configurações',
                        style: LummyFonts.body(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conta, preferências e segurança',
                    style: LummyFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildThemeToggle(context, isDark),
                const SizedBox(height: 20),
                _buildSectionLabel('Conta', isDark),
                const SizedBox(height: 10),
                _buildSectionContainer(
                  isDark: isDark,
                  children: [
                    _buildSettingItem(
                      context: context,
                      icon: Icons.lock_reset_rounded,
                      title: 'Alterar senha',
                      subtitle: 'Alterar sua senha de acesso',
                      color: _purple,
                      isDark: isDark,
                      onTap: () => _openChangePassword(context),
                    ),
                    const SizedBox(height: 10),
                    _buildSettingItem(
                      context: context,
                      icon: Icons.lock_outline_rounded,
                      title: 'Privacidade',
                      subtitle: 'Controle de segurança da conta',
                      color: _blue,
                      isDark: isDark,
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSectionLabel('Preferências', isDark),
                const SizedBox(height: 10),
                _buildSectionContainer(
                  isDark: isDark,
                  children: [
                _buildSettingItem(
                      context: context,
                      icon: Icons.notifications_rounded,
                      title: 'Notificações',
                      subtitle: 'Gerenciar alertas de aprovações e movimentações',
                      color: _orange,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ParentNotificationsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSectionLabel('Suporte', isDark),
                const SizedBox(height: 10),
                _buildSectionContainer(
                  isDark: isDark,
                  children: [
                    _buildSettingItem(
                      context: context,
                      icon: Icons.help_outline_rounded,
                      title: 'Central de Ajuda',
                      subtitle: 'FAQ e suporte',
                      color: _blue,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ParentHelpScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSettingItem(
                      context: context,
                      icon: Icons.logout_rounded,
                      title: 'Sair da Conta',
                      subtitle: 'Desconectar deste dispositivo',
                      color: _red,
                      isDark: isDark,
                      onTap: () => _handleLogout(context, isDark),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [_purple, LummyColors.violet600]
                  : [_blue, _purple],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark ? _purple : _blue).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tema do App',
                      style: LummyFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isDark ? 'Modo escuro' : 'Modo claro',
                      style: LummyFonts.body(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.white.withValues(alpha: 0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? LummyColors.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? LummyColors.slate700 : LummyColors.slate200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: LummyFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : LummyColors.slate800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: LummyFonts.body(
                        fontSize: 12,
                        color: isDark
                            ? LummyColors.slate400
                            : LummyColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? LummyColors.slate500
                    : LummyColors.slate400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: LummyFonts.body(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? LummyColors.slate300 : LummyColors.slate700,
      ),
    );
  }

  Widget _buildSectionContainer({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? LummyColors.slate900 : LummyColors.slate100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? LummyColors.slate800 : LummyColors.slate200,
        ),
      ),
      child: Column(children: children),
    );
  }

  void _openChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParentChangePasswordScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.construction_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Em desenvolvimento',
              style: LummyFonts.body(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: _orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, bool isDark) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LummyColors.darkMaterial : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: _red, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Sair da conta?',
                style: LummyFonts.body(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark ? Colors.white : LummyColors.slate800,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Você precisará fazer login novamente para acessar sua conta.',
          style: LummyFonts.body(
            fontSize: 15,
            color: isDark ? LummyColors.slate400 : LummyColors.slate500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: LummyFonts.body(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? LummyColors.slate400
                    : LummyColors.slate500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_red, LummyColors.red600]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Sair',
                style: LummyFonts.body(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        final authRepo = locator<AuthRepository>();
        await authRepo.logout();
        await locator<BiometricAuthService>().clearCachedUser();

        if (!context.mounted) return;
        context.read<ThemeProvider>().setPreLoginLightOnly(true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: _red,
          ),
        );
      }
    }
  }
}
