import 'package:flutter/material.dart';

import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Estado de erro da aba Metas (sem mockup): texto + "Tentar de novo".
///
/// Erro de carga NÃO vira "Você ainda não tem uma meta": a criança pode ter
/// meta e só estar sem internet.
class GoalsV1Error extends StatelessWidget {
  const GoalsV1Error({super.key, required this.onTentarDeNovo});

  final VoidCallback onTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Não foi possível carregar suas metas. Verifique a internet e tente de novo.',
          style: LummyText.poppins(
            context,
            size: 14,
            color: context.cores.tintaApoio,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        LummyWideButton(rotulo: 'Tentar de novo', onTap: onTentarDeNovo),
      ],
    );
  }
}
