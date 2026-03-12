import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Configurações',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SettingsTile(
            icon: Icons.notifications_active_rounded,
            title: 'Notificações',
            subtitle: 'Alertas de aprovações e movimentações',
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacidade',
            subtitle: 'Controle de segurança da conta',
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Aparência',
            subtitle: 'Tema e preferências visuais',
            titleColor: titleColor,
            subtitleColor: subtitleColor,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: titleColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: subtitleColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
