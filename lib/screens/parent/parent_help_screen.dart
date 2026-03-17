import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central de Ajuda (FAQ): perguntas frequentes expandíveis.
class ParentHelpScreen extends StatelessWidget {
  const ParentHelpScreen({super.key});

  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);

  static final List<Map<String, dynamic>> _faqItems = [
    {
      'q': 'Como funciona o Lummy para responsáveis?',
      'a': 'No Lummy você controla o saldo da família e envia dinheiro para os filhos. '
          'Defina mesadas, aprove ou rejeite pedidos (incluindo o motivo) e acompanhe gastos e metas por criança.',
    },
    {
      'q': 'O que as crianças podem fazer no app?',
      'a': 'Os filhos usam o app para ver saldo, pedir dinheiro (informando o motivo), registrar gastos '
          '(que podem exigir sua aprovação), cumprir metas e acompanhar aulas de educação financeira.',
    },
    {
      'q': 'Como enviar dinheiro para meus filhos?',
      'a': 'O saldo da família é o valor disponível para enviar. Use "Enviar" ou "Distribuir" para repassar valores. '
          'O saldo diminui ao enviar e pode ser ocultado com o ícone de olho no card.',
    },
    {
      'q': 'Como funcionam as aprovações?',
      'a': 'Quando um filho faz um pedido de dinheiro ou um gasto que exige aprovação, aparece em "Aprovações". '
          'Você vê o motivo e pode aprovar ou rejeitar. Pendentes aparecem no dashboard e no menu inferior.',
    },
    {
      'q': 'O que são as metas de economia?',
      'a': 'Crie metas de economia por filho. O valor guardado para a meta fica separado do saldo disponível. '
          'Acompanhe o progresso na área de metas e no painel de cada criança.',
    },
    {
      'q': 'Como ver gastos e relatórios?',
      'a': 'Visualize gastos por filho e por categoria. Use a aba de gastos e os insights para entender '
          'para onde vai o dinheiro e orientar a educação financeira.',
    },
    {
      'q': 'Onde ficam as aulas de educação financeira?',
      'a': 'O Lummy oferece conteúdo em formato de aulas. As crianças podem assistir e ganhar conquistas; '
          'você acompanha o progresso no perfil do dependente.',
    },
    {
      'q': 'Esqueci minha senha. O que fazer?',
      'a': 'Na tela de login, toque em "Esqueci minha senha" e informe seu e-mail. '
          'Você receberá um link para redefinir a senha.',
    },
  ];

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
          'Central de Ajuda',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_purple, _blue],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Perguntas frequentes',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._faqItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FaqTile(
                question: item['q'] as String,
                answer: item['a'] as String,
                isDark: isDark,
                sectionBg: sectionBg,
                borderColor: borderColor,
                accentColor: [
                  _purple,
                  _blue,
                  _green,
                  _orange,
                ][i % 4],
              ),
            );
          }),
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

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isDark;
  final Color sectionBg;
  final Color borderColor;
  final Color accentColor;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.isDark,
    required this.sectionBg,
    required this.borderColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.help_outline_rounded, color: accentColor, size: 20),
          ),
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: bodyColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

