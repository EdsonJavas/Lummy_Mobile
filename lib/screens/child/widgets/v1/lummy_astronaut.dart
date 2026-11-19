import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// O astronauta mascote (`assets/images/astronauta.svg`, DECISOES 1).
///
/// Tamanhos do mockup: 102×130 girado 8° (cofrinho da Home), 42×54 (avatar
/// da Dica do Lummy), 66×84 (prévia do Tons-azul).
class LummyAstronaut extends StatelessWidget {
  const LummyAstronaut({
    super.key,
    required this.width,
    required this.height,
    this.rotationDegrees = 0,
  });

  /// Caminho do asset (declarado no pubspec).
  static const asset = 'assets/images/astronauta.svg';

  final double width;
  final double height;

  /// Rotação no sentido horário, em graus (`transform: rotate(8deg)`).
  final double rotationDegrees;

  @override
  Widget build(BuildContext context) {
    final img = SvgPicture.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    if (rotationDegrees == 0) return img;
    return Transform.rotate(angle: rotationDegrees * math.pi / 180, child: img);
  }
}
