import 'package:flutter/material.dart';

/// Curvatura do topo do card (igual à tela de cadastro do responsável).
class DashboardFormTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Curvatura idêntica à tela de login.
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 60);
    path.quadraticBezierTo(size.width * 0.75, 20, size.width * 0.5, 20);
    path.quadraticBezierTo(size.width * 0.25, 20, 0, 60);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
