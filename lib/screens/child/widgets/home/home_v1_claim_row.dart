import 'package:flutter/material.dart';

import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Linha "Retirar minha parte" (DECISOES 20), logo abaixo do cofrinho: texto
/// "Seus pais separaram R$ X para você" + botão laranja compacto "Retirar".
/// Sem cartão em volta. Quem decide se a linha aparece é a Home.
///
/// Não existe no mockup: segue o padrão de texto e o botão de 44 do kit.
class HomeV1ClaimRow extends StatelessWidget {
  const HomeV1ClaimRow({
    super.key,
    required this.minhaParte,
    required this.onRetirar,
  });

  /// Valor que cabe à criança na distribuição ativa.
  final double minhaParte;

  final VoidCallback onRetirar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Seus pais separaram ${V1Format.brl(minhaParte)} para você',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: LummyText.poppins(context, size: 14, weight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        LummyPillButton(rotulo: 'Retirar', onTap: onRetirar),
      ],
    );
  }
}
