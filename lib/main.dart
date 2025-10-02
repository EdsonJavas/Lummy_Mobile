// main.dart
import 'package:flutter/material.dart';
import 'package:lummy_login/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'di/locator.dart';
import 'application/app_facade.dart';
import 'main_navigation.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator();
  runApp(const LummyApp());
}

class LummyApp extends StatelessWidget {
  const LummyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lummy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _BiometricGate extends StatefulWidget {
  const _BiometricGate();

  @override
  State<_BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<_BiometricGate>
    with TickerProviderStateMixin {
  bool _loading = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _isAuthenticating = false;
  late AnimationController _pulseController;
  late AnimationController _fingerprintController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fingerprintAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fingerprintController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fingerprintAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fingerprintController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fingerprintController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final bio = locator<BiometricAuthService>();
    final supported = await bio.isDeviceSupported();
    final canCheck = await bio.canCheckBiometrics();
    final enabled = await bio.isBiometricEnabled();
    final cached = await bio.readCachedUserId();

    setState(() {
      _biometricAvailable = supported && canCheck;
      _biometricEnabled = enabled;
    });

    if (_biometricAvailable && _biometricEnabled && cached != null) {
      await _tryBiometricAuth();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _tryBiometricAuth() async {
    setState(() {
      _isAuthenticating = true;
    });

    _fingerprintController.forward();

    final bio = locator<BiometricAuthService>();
    final success =
        await bio.authenticate(reason: 'Use sua digital para entrar');

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else if (mounted) {
      setState(() {
        _loading = false;
        _isAuthenticating = false;
      });
      _fingerprintController.reset();
    }
  }

  Future<void> _handleBiometricTap() async {
    if (_isAuthenticating) return;
    await _tryBiometricAuth();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildBiometricScreen();
    }
    return const LoginScreen();
  }

  Widget _buildBiometricScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF357ABD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Lu',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          TextSpan(
                            text: 'm',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: Colors.orange,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          TextSpan(
                            text: 'm',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF003092),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          TextSpan(
                            text: 'y',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone de digital animado
                      GestureDetector(
                        onTap: _handleBiometricTap,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isAuthenticating
                                  ? 1.0
                                  : _pulseAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _fingerprintAnimation,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(60, 60),
                                        painter: FingerprintPainter(
                                          progress: _fingerprintAnimation.value,
                                          isAuthenticating: _isAuthenticating,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Texto principal
                      Text(
                        _isAuthenticating
                            ? 'Autenticando...'
                            : 'Toque para usar sua digital',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Texto secundário
                      Text(
                        _isAuthenticating
                            ? 'Aguarde um momento'
                            : 'Ou use email e senha',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Botão para usar login tradicional
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _loading = false;
                          });
                        },
                        child: Text(
                          'Usar email e senha',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter para o ícone de digital estilo Banco Inter
class FingerprintPainter extends CustomPainter {
  final double progress;
  final bool isAuthenticating;

  FingerprintPainter({
    required this.progress,
    required this.isAuthenticating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isAuthenticating ? const Color(0xFF4CAF50) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Desenhar as linhas da digital de forma progressiva
    _drawFingerprintLines(canvas, center, radius, paint);
  }

  void _drawFingerprintLines(
      Canvas canvas, Offset center, double radius, Paint paint) {
    // Linhas principais da digital
    final lines = [
      // Linha superior
      _createArcPath(center, radius * 0.3, -0.3, 0.6),
      // Linha do meio
      _createArcPath(center, radius * 0.5, -0.2, 0.4),
      // Linha inferior
      _createArcPath(center, radius * 0.7, -0.1, 0.2),
      // Linhas laterais
      _createVerticalLine(center, radius * 0.4, -0.4, 0.8),
      _createVerticalLine(center, radius * 0.6, -0.3, 0.6),
    ];

    for (int i = 0; i < lines.length; i++) {
      final lineProgress = (progress * lines.length - i).clamp(0.0, 1.0);
      if (lineProgress > 0) {
        final linePath = lines[i];
        final pathMetrics = linePath.computeMetrics();

        for (final pathMetric in pathMetrics) {
          final extractPath = pathMetric.extractPath(
            0.0,
            pathMetric.length * lineProgress,
          );
          canvas.drawPath(extractPath, paint);
        }
      }
    }

    // Pontos da digital
    _drawFingerprintDots(canvas, center, radius, paint);
  }

  Path _createArcPath(
      Offset center, double radius, double startAngle, double sweepAngle) {
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
    );
    return path;
  }

  Path _createVerticalLine(
      Offset center, double radius, double startAngle, double sweepAngle) {
    final path = Path();
    final startX = center.dx + radius * math.cos(startAngle);
    final startY = center.dy + radius * math.sin(startAngle);
    final endX = center.dx + radius * math.cos(startAngle + sweepAngle);
    final endY = center.dy + radius * math.sin(startAngle + sweepAngle);

    path.moveTo(startX, startY);
    path.lineTo(endX, endY);
    return path;
  }

  void _drawFingerprintDots(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    final dots = [
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.1),
      Offset(center.dx + radius * 0.15, center.dy - radius * 0.2),
      Offset(center.dx - radius * 0.1, center.dy + radius * 0.1),
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.05),
    ];

    for (int i = 0; i < dots.length; i++) {
      final dotProgress = (progress * dots.length - i).clamp(0.0, 1.0);
      if (dotProgress > 0) {
        canvas.drawCircle(dots[i], 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(FingerprintPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isAuthenticating != isAuthenticating;
  }
}
