import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  final Widget nextPage;

  const OnboardingScreen({super.key, required this.nextPage});

  static const _prefKey = 'onboarding_completed';

  static Future<bool> hasCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingContent(nextPage: nextPage);
  }
}

class _OnboardingContent extends StatefulWidget {
  final Widget nextPage;

  const _OnboardingContent({required this.nextPage});

  @override
  State<_OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<_OnboardingContent> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _blue = Color(0xFF3B82F6);
  static const _purple = Color(0xFF8B5CF6);
  static const _green = Color(0xFF10B981);

  /// Cada passo: título, descrição, e lista de itens (ícone + texto).
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Controle financeiro',
      'subtitle': 'Tudo que você precisa para acompanhar e orientar os gastos dos filhos.',
      'color': _blue,
      'items': [
        {'icon': Icons.account_balance_wallet_rounded, 'text': 'Acompanhe o saldo de cada filho em tempo real'},
        {'icon': Icons.pending_actions_rounded, 'text': 'Aprove ou rejeite pedidos de compra com um toque'},
        {'icon': Icons.send_rounded, 'text': 'Envie dinheiro na hora, direto pelo app'},
        {'icon': Icons.insights_rounded, 'text': 'Relatórios e gastos por categoria'},
      ],
    },
    {
      'title': 'Educação financeira',
      'subtitle': 'Ferramentas para as crianças aprenderem a economizar e planejar.',
      'color': _purple,
      'items': [
        {'icon': Icons.menu_book_rounded, 'text': 'Aulas e conteúdos sobre dinheiro e economia'},
        {'icon': Icons.flag_rounded, 'text': 'Metas de economia com progresso visual'},
        {'icon': Icons.star_rounded, 'text': 'Conquistas e recompensas por bons hábitos'},
        {'icon': Icons.savings_rounded, 'text': 'Mesada e limites configuráveis por categoria'},
      ],
    },
    {
      'title': 'Tudo em família',
      'subtitle': 'Responsáveis e filhos conectados em uma experiência segura e simples.',
      'color': _green,
      'items': [
        {'icon': Icons.people_rounded, 'text': 'Perfis separados: responsável e criança'},
        {'icon': Icons.notifications_active_rounded, 'text': 'Avisos quando o filho recebe ou gasta'},
        {'icon': Icons.security_rounded, 'text': 'Controle e segurança em um só lugar'},
        {'icon': Icons.celebration_rounded, 'text': 'Celebre conquistas juntos'},
      ],
    },
  ];

  Future<void> _finish() async {
    await OnboardingScreen.markCompleted();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.nextPage),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 56),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _pages.length,
                      (i) => GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? _purple
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Pular',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final color = page['color'] as Color;
                  final items = page['items'] as List<Map<String, dynamic>>;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        // Título com barra de destaque (sem ícone grande)
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                page['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page['subtitle'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Card populado com os itens
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 1),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(items.length, (i) {
                                final item = items[i];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < items.length - 1 ? 20 : 0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          item['icon'] as IconData,
                                          size: 22,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            item['text'] as String,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: titleColor,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Dica interativa
                        Center(
                          child: Text(
                            'Deslize para o próximo',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: subtitleColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finish();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Próximo' : 'Começar',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
