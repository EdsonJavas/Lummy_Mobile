import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy_login/application/app_facade.dart';
import 'package:lummy_login/core/config/supabase_config.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/screens/auth/login_screen.dart';
import 'package:lummy_login/screens/child/main_navigation.dart';
import 'package:lummy_login/screens/parent/parent_main_navigation.dart';
import 'package:lummy_login/screens/app/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _logoController;
  late final AnimationController _pulseController;
  late final AnimationController _textController;
  late final AnimationController _loadingController;
  late final AnimationController _particleController;

  // Animações
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textSlide;
  late final Animation<double> _textOpacity;

  // Cores da marca Lummy
  static const _blue = Color(0xFF3B82F6);
  static const _purple = Color(0xFF8B5CF6);
  static const _orange = Color(0xFFF59E0B);
  static const _green = Color(0xFF10B981);

  String _loadingText = 'Inicializando';
  int _loadingDots = 0;
  Timer? _dotsTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _startLoadingDots();
    _bootstrap();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat(reverse: true);
    _particleController.repeat();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _loadingController.repeat();
  }

  void _startLoadingDots() {
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() => _loadingDots = (_loadingDots + 1) % 4);
      }
    });
  }

  /// Carrega tudo que a tela de login precisa (biometria, cache) antes de sair da splash.
  Future<void> _prepareLoginScreen() async {
    try {
      final bio = locator<BiometricAuthService>();
      await bio.canCheckBiometrics();
      await bio.isBiometricEnabled();
      await bio.readCachedUserId();
    } catch (e) {
      debugPrint('⚠️ Prep login: $e');
    }
  }

  Future<void> _bootstrap() async {
    try {
      setState(() => _loadingText = 'Conectando');
      debugPrint('🔧 Inicializando Supabase...');
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      setState(() => _loadingText = 'Configurando');
      setupLocator();

      setState(() => _loadingText = 'Preparando tela de login');
      await _prepareLoginScreen();

      setState(() => _loadingText = 'Quase pronto');
      await Future.delayed(const Duration(milliseconds: 400));

      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      Widget nextPage = const LoginScreen();

      if (session != null) {
        final userId = session.user.id;
        try {
          final parent = await client
              .from('responsaveis')
              .select('id, nome')
              .eq('id', userId)
              .maybeSingle();
          if (parent != null) {
            nextPage = ParentMainNavigation(
              parentId: userId,
              parentName: (parent['nome'] ?? '') as String,
            );
          } else {
            final child = await client
                .from('children')
                .select('id')
                .eq('id', userId)
                .maybeSingle();
            if (child != null) {
              nextPage = const MainNavigation();
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao decidir próxima tela: $e');
        }
      }

      if (!mounted) return;
      final showOnboarding = !await OnboardingScreen.hasCompleted();
      final targetPage = showOnboarding
          ? OnboardingScreen(nextPage: nextPage)
          : nextPage;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => targetPage,
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao inicializar: $e');
      debugPrint('   Stack: $stackTrace');
      try {
        setupLocator();
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF172554),
      body: Stack(
        children: [
          _buildBackground(),
          _buildParticles(),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  _buildAnimatedLogo(),
                  const SizedBox(height: 40),
                  _buildLummyText(),
                  const SizedBox(height: 12),
                  _buildSubtitle(),
                  const Spacer(flex: 2),
                  _buildLoadingSection(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172554), Color(0xFF1E1B4B), Color(0xFF172554)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlePainter(
            progress: _particleController.value,
            colors: [_blue, _purple, _orange, _green],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScale, _logoOpacity, _pulseController]),
      builder: (context, _) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withOpacity(
                            0.2 + _pulseController.value * 0.15),
                        blurRadius: 60 + _pulseController.value * 20,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: _purple.withOpacity(
                            0.15 + _pulseController.value * 0.1),
                        blurRadius: 80 + _pulseController.value * 30,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF8B5CF6),
                        Color(0xFF6366F1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(child: _buildLogoIcon()),
                ),
                ..._buildOrbitalRings(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoIcon() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFE0E7FF)],
      ).createShader(bounds),
      child: Text(
        'L',
        style: GoogleFonts.fredoka(
          fontSize: 72,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }

  List<Widget> _buildOrbitalRings() {
    return [
      AnimatedBuilder(
        animation: _particleController,
        builder: (context, _) {
          return Transform.rotate(
            angle: _particleController.value * 2 * math.pi,
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _OrbitalPainter(
                  color: _blue.withOpacity(0.3),
                  strokeWidth: 1.5,
                  dashLength: 8,
                  gapLength: 12,
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _particleController,
        builder: (context, _) {
          return Transform.rotate(
            angle: _particleController.value * 2 * math.pi,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  Positioned(
                      left: 100 - 6, top: 0, child: _buildOrbitalDot(_blue)),
                  Positioned(
                      right: 0, top: 100 - 6,
                      child: _buildOrbitalDot(_purple)),
                  Positioned(
                      left: 100 - 6, bottom: 0,
                      child: _buildOrbitalDot(_orange)),
                  Positioned(
                      left: 0, top: 100 - 6,
                      child: _buildOrbitalDot(_green)),
                ],
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildOrbitalDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildLummyText() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textSlide, _textOpacity]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Lu',
                    style: GoogleFonts.paytoneOne(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: 'm',
                    style: GoogleFonts.paytoneOne(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                  TextSpan(
                    text: 'm',
                    style: GoogleFonts.paytoneOne(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF003092),
                    ),
                  ),
                  TextSpan(
                    text: 'y',
                    style: GoogleFonts.paytoneOne(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _textOpacity,
      builder: (context, _) {
        final delayedOpacity =
            ((_textOpacity.value - 0.3) / 0.7).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayedOpacity,
          child: Text(
            'Educação Financeira Inteligente',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, _) {
        return Column(
          children: [
            SizedBox(
              width: 200,
              child: Stack(
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, _) {
                      return FractionallySizedBox(
                        widthFactor: _loadingController.value,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_blue, _purple, _orange]),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: _purple.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$_loadingText${'.' * _loadingDots}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  _ParticlePainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final particleSize = 1.5 + random.nextDouble() * 2.5;
      final y = (baseY + progress * size.height * speed) % size.height;
      final opacity = (0.1 + random.nextDouble() * 0.2) *
          (1 - (y / size.height).clamp(0.5, 1.0));
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _OrbitalPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  _OrbitalPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLength + gapLength) / radius);
      final sweepAngle = dashLength / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalPainter oldDelegate) => false;
}
