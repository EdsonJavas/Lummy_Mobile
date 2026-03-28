import 'dart:math' as math;
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

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _OnboardingPage {
  final String title;
  final String subtitle;
  final Color color;
  final Color colorDark;
  final IconData heroIcon;
  final List<_OnboardingStep> steps;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.colorDark,
    required this.heroIcon,
    required this.steps,
  });
}

class _OnboardingStep {
  final IconData icon;
  final String text;
  const _OnboardingStep({required this.icon, required this.text});
}

// ---------------------------------------------------------------------------
// Content widget
// ---------------------------------------------------------------------------

class _OnboardingContent extends StatefulWidget {
  final Widget nextPage;
  const _OnboardingContent({required this.nextPage});

  @override
  State<_OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<_OnboardingContent>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _heroController;
  late final AnimationController _contentController;
  late final AnimationController _floatController;

  static const _blue = Color(0xFF3B82F6);
  static const _purple = Color(0xFF8B5CF6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  static const _teal = Color(0xFF14B8A6);

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Bem-vindo ao Lummy',
      subtitle:
          'A forma mais simples de ensinar seus filhos a lidar com dinheiro — com segurança e controle total.',
      color: _blue,
      colorDark: Color(0xFF1E40AF),
      heroIcon: Icons.family_restroom_rounded,
      steps: [
        _OnboardingStep(
          icon: Icons.shield_rounded,
          text: 'Controle total dos gastos',
        ),
        _OnboardingStep(
          icon: Icons.school_rounded,
          text: 'Educação financeira na prática',
        ),
        _OnboardingStep(
          icon: Icons.favorite_rounded,
          text: 'Feito para famílias como a sua',
        ),
      ],
    ),
    _OnboardingPage(
      title: 'O saldo do seu filho',
      subtitle:
          'Cada filho tem um saldo virtual que você controla. Ele vê quanto tem, aprende a planejar e só gasta com sua aprovação.',
      color: _purple,
      colorDark: Color(0xFF6D28D9),
      heroIcon: Icons.account_balance_wallet_rounded,
      steps: [
        _OnboardingStep(
          icon: Icons.visibility_rounded,
          text: 'Saldo visível em tempo real para pai e filho',
        ),
        _OnboardingStep(
          icon: Icons.lock_rounded,
          text: 'Ninguém gasta sem a sua permissão',
        ),
        _OnboardingStep(
          icon: Icons.trending_up_rounded,
          text: 'Histórico completo de movimentações',
        ),
      ],
    ),
    _OnboardingPage(
      title: 'Envie dinheiro na hora',
      subtitle:
          'Mesada, presente ou um extra — envie valores direto pelo app em segundos, com biometria para segurança.',
      color: _orange,
      colorDark: Color(0xFFD97706),
      heroIcon: Icons.bolt_rounded,
      steps: [
        _OnboardingStep(
          icon: Icons.touch_app_rounded,
          text: 'Escolha o valor e o filho',
        ),
        _OnboardingStep(
          icon: Icons.fingerprint_rounded,
          text: 'Confirme com biometria',
        ),
        _OnboardingStep(
          icon: Icons.check_circle_rounded,
          text: 'Pronto — saldo atualizado na hora',
        ),
      ],
    ),
    _OnboardingPage(
      title: 'Pedidos e aprovações',
      subtitle:
          'Seu filho pede, você decide. Cada pedido chega com valor e motivo — aprove ou rejeite com um toque.',
      color: _green,
      colorDark: Color(0xFF059669),
      heroIcon: Icons.verified_user_rounded,
      steps: [
        _OnboardingStep(
          icon: Icons.front_hand_rounded,
          text: 'Filho envia pedido com valor e motivo',
        ),
        _OnboardingStep(
          icon: Icons.notifications_active_rounded,
          text: 'Você recebe e analisa',
        ),
        _OnboardingStep(
          icon: Icons.thumb_up_alt_rounded,
          text: 'Aprove ou rejeite — simples assim',
        ),
      ],
    ),
    _OnboardingPage(
      title: 'Acompanhe e eduque',
      subtitle:
          'Insights sobre gastos, metas de economia e conteúdos educativos para ensinar o valor do dinheiro.',
      color: _teal,
      colorDark: Color(0xFF0D9488),
      heroIcon: Icons.auto_graph_rounded,
      steps: [
        _OnboardingStep(
          icon: Icons.pie_chart_rounded,
          text: 'Relatórios de gastos por categoria',
        ),
        _OnboardingStep(
          icon: Icons.flag_rounded,
          text: 'Metas de economia com progresso visual',
        ),
        _OnboardingStep(
          icon: Icons.emoji_events_rounded,
          text: 'Conquistas e recompensas por bons hábitos',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heroController.dispose();
    _contentController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _heroController.reset();
    _contentController.reset();
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });
  }

  Future<void> _finish() async {
    await OnboardingScreen.markCompleted();
    if (!mounted) return;
    final nav = Navigator.of(context);
    nav.pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (ctx, a1, a2) => widget.nextPage,
        transitionsBuilder: (ctx, anim, a2, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isDark),
            _buildProgressBar(isDark),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (_, i) => _buildPage(i, isDark),
              ),
            ),
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Top bar: step counter + skip
  // -------------------------------------------------------------------------

  Widget _buildTopBar(bool isDark) {
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
      child: Row(
        children: [
          Text(
            '${_currentPage + 1} de ${_pages.length}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _pages[_currentPage].color,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _finish,
            child: Text(
              'Pular',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Animated progress bar
  // -------------------------------------------------------------------------

  Widget _buildProgressBar(bool isDark) {
    final trackColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final progress = (_currentPage + 1) / _pages.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _pages[_currentPage].color,
                      _pages[_currentPage].colorDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Page content
  // -------------------------------------------------------------------------

  Widget _buildPage(int index, bool isDark) {
    final page = _pages[index];
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0);

    final heroAnim = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutBack,
    );
    final contentAnim = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Hero illustration
          AnimatedBuilder(
            animation: Listenable.merge([heroAnim, _floatController]),
            builder: (context, child) {
              final float =
                  math.sin(_floatController.value * math.pi) * 6;
              return Transform.translate(
                offset: Offset(0, float),
                child: Opacity(
                  opacity: heroAnim.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.5 + heroAnim.value * 0.5,
                    child: _buildHeroIllustration(page, isDark),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Title
          AnimatedBuilder(
            animation: contentAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - contentAnim.value)),
                child: Opacity(
                  opacity: contentAnim.value.clamp(0.0, 1.0),
                  child: Text(
                    page.title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Subtitle
          AnimatedBuilder(
            animation: contentAnim,
            builder: (context, child) {
              final delayed =
                  ((contentAnim.value - 0.15) / 0.85).clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset(0, 16 * (1 - delayed)),
                child: Opacity(
                  opacity: delayed,
                  child: Text(
                    page.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: subtitleColor,
                      height: 1.55,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Step cards
          ...List.generate(page.steps.length, (i) {
            return AnimatedBuilder(
              animation: contentAnim,
              builder: (context, child) {
                final stagger = 0.15 + i * 0.12;
                final t =
                    ((contentAnim.value - stagger) / (1 - stagger))
                        .clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, 24 * (1 - t)),
                  child: Opacity(
                    opacity: t,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildStepCard(
                        page.steps[i],
                        i + 1,
                        page.color,
                        cardBg,
                        borderColor,
                        titleColor,
                        subtitleColor,
                        isDark,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Hero illustration (icon composition)
  // -------------------------------------------------------------------------

  Widget _buildHeroIllustration(_OnboardingPage page, bool isDark) {
    return Center(
      child: SizedBox(
        height: 160,
        width: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.color.withValues(alpha: 0.15),
                    page.color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            // Mid ring
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: page.color.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
            ),
            // Center icon circle
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [page.color, page.colorDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: page.color.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(page.heroIcon, size: 44, color: Colors.white),
            ),
            // Decorative orbiting dots
            ..._buildOrbitDots(page.color),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrbitDots(Color color) {
    const positions = [
      Alignment(-0.85, -0.6),
      Alignment(0.88, -0.45),
      Alignment(-0.7, 0.75),
      Alignment(0.8, 0.7),
    ];
    const sizes = [10.0, 8.0, 7.0, 9.0];
    const alphas = [0.5, 0.35, 0.25, 0.4];

    return List.generate(4, (i) {
      return Align(
        alignment: positions[i],
        child: Container(
          width: sizes[i],
          height: sizes[i],
          decoration: BoxDecoration(
            color: color.withValues(alpha: alphas[i]),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  // -------------------------------------------------------------------------
  // Step card
  // -------------------------------------------------------------------------

  Widget _buildStepCard(
    _OnboardingStep step,
    int number,
    Color color,
    Color cardBg,
    Color borderColor,
    Color titleColor,
    Color subtitleColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? borderColor : color.withValues(alpha: 0.12),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(step.icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              step.text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: titleColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Bottom bar: back + next/start
  // -------------------------------------------------------------------------

  Widget _buildBottomBar(bool isDark) {
    final isLast = _currentPage == _pages.length - 1;
    final page = _pages[_currentPage];
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Row(
        children: [
          // Back button (hidden on first page)
          AnimatedOpacity(
            opacity: _currentPage > 0 ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: _currentPage == 0,
              child: IconButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                  );
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: subtitleColor,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Next / Start button
          Expanded(
            child: SizedBox(
              height: 54,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLast
                        ? [page.color, page.colorDark]
                        : [page.color, page.color],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isLast
                      ? [
                          BoxShadow(
                            color: page.color.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _next,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Começar' : 'Próximo',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (isLast) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
