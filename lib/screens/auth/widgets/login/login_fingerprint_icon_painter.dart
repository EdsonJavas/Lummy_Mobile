import 'package:flutter/material.dart';

// Painter para o ícone pequeno de digital
class LoginFingerprintIconPainter extends CustomPainter {
  final Color color;

  LoginFingerprintIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Desenhar linhas simples da digital
    final lines = [
      // Linha superior
      _createArcPath(center, radius * 0.3, -0.3, 0.6),
      // Linha do meio
      _createArcPath(center, radius * 0.5, -0.2, 0.4),
      // Linha inferior
      _createArcPath(center, radius * 0.7, -0.1, 0.2),
    ];

    for (final line in lines) {
      canvas.drawPath(line, paint);
    }

    // Pontos da digital
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dots = [
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.1),
      Offset(center.dx + radius * 0.15, center.dy - radius * 0.2),
      Offset(center.dx - radius * 0.1, center.dy + radius * 0.1),
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.05),
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, 0.8, dotPaint);
    }
  }

  Path _createArcPath(
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
    );
    return path;
  }

  @override
  bool shouldRepaint(LoginFingerprintIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
