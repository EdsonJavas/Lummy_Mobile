import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela de Ajuda: explicações por títulos e temas das principais funcionalidades do app.
class ParentHelpScreen extends StatelessWidget {
  const ParentHelpScreen({super.key});

  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final sectionBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Ajuda',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _HelpSection(
            icon: Icons.family_restroom_rounded,
            iconColor: _purple,
            title: 'Para responsáveis',
            body:
                'No Lummy você controla o saldo da família e envia dinheiro para os filhos. '
                'Defina mesadas, aprove ou rejeite pedidos de compra e acompanhe gastos e metas por criança.',
            bg: sectionBg,
            borderColor: borderColor,
            titleStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            bodyStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _HelpSection(
            icon: Icons.child_care_rounded,
            iconColor: _blue,
            title: 'Para as crianças',
            body:
                'Os filhos usam o app para ver saldo, fazer pedidos de compra (que podem exigir sua aprovação), '
                'cumprir metas e acompanhar aulas de educação financeira.',
            bg: sectionBg,
            borderColor: borderColor,
            titleStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            bodyStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _HelpSection(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: _green,
            title: 'Saldo e envio',
            body:
                'O saldo da família (responsável) é o valor disponível para enviar aos filhos. '
                'Use "Enviar" ou "Distribuir" para repassar valores. O saldo diminui ao enviar e pode ser ocultado com o ícone de olho no card.',
            bg: sectionBg,
            borderColor: borderColor,
            titleStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            bodyStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _HelpSection(
            icon: Icons.pending_actions_rounded,
            iconColor: _orange,
            title: 'Aprovações',
            body:
                'Quando um filho faz um pedido de compra que exige aprovação, ele aparece em "Aprovações". '
                'Você pode aprovar ou rejeitar. Aprovações pendentes aparecem no dashboard e no menu inferior.',
            bg: sectionBg,
            borderColor: borderColor,
            titleStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            bodyStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _HelpSection(
            icon: Icons.flag_rounded,
            iconColor: _purple,
            title: 'Metas',
            body:
                'Crie metas de economia por filho. O valor guardado para a meta fica separado do saldo disponível. '
                'Acompanhe o progresso na área de metas e no painel de cada criança.',
            bg: sectionBg,
            borderColor: borderColor,
            titleStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            bodyStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _HelpSection(
            icon: Icons.receipt_long_rounded,
            iconColor: _blue,
            title: 'Gastos e relatórios',
            body:
                'Visualize gastos por filho e por categoria. Use a aba de gastos e os insights para entender para onde vai o dinheiro '
                'e orientar a educação financeira.',
            bg: sectionBg,
            borderColor: borderColor,
            titleStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            bodyStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _HelpSection(
            icon: Icons.school_rounded,
            iconColor: _green,
            title: 'Aulas e educação',
            body:
                'O Lummy oferece conteúdo de educação financeira em formato de aulas. '
                'As crianças podem assistir e ganhar conquistas; você acompanha o progresso no perfil do dependente.',
            bg: sectionBg,
            borderColor: borderColor,
            titleStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            bodyStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: bodyColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Lummy — Educação financeira para a família',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: bodyColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final Color bg;
  final Color borderColor;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  const _HelpSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.bg,
    required this.borderColor,
    required this.titleStyle,
    required this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: titleStyle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: bodyStyle),
        ],
      ),
    );
  }
}
