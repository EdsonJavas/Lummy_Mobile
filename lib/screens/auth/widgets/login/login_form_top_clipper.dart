import 'package:flutter/material.dart';

// Classe personalizada para criar a curva na parte superior do formulário
class LoginFormTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Começar do canto inferior esquerdo
    path.moveTo(0, size.height);

    // Linha para o canto inferior direito
    path.lineTo(size.width, size.height);

    // Linha para o canto superior direito (mas um pouco abaixo para criar a curva)
    path.lineTo(size.width, 60);

    // Criar uma curva suave na parte superior
    path.quadraticBezierTo(
      size.width * 0.75,
      20, // Ponto de controle
      size.width * 0.5,
      20, // Ponto médio
    );

    path.quadraticBezierTo(
      size.width * 0.25,
      20, // Ponto de controle
      0,
      60, // Ponto final
    );

    // Fechar o caminho
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
