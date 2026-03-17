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

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'Controle financeiro',
      'subtitle': 'Acompanhe o saldo dos filhos, aprove pedidos e envie dinheiro de forma simples.',
      'color': _blue,
    },
    {
      'icon': Icons.school_rounded,
      'title': 'Educação financeira',
      'subtitle': 'Aulas e metas ajudam as crianças a aprender a economizar e planejar.',
      'color': _purple,
    },
    {
      'icon': Icons.family_restroom_rounded,
      'title': 'Tudo em família',
      'subtitle': 'Responsáveis e filhos conectados. Educação financeira que une a família.',
      'color': _green,
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
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
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
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (page['color'] as Color),
                                (page['color'] as Color).withOpacity(0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (page['color'] as Color).withOpacity(0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? _purple
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
