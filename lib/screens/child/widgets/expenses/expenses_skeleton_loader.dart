import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Esqueleto da aba Gastos (redesenho V1), com as medidas da tela pronta:
/// cabeçalho, segmentado de 44, bloco do valor e 4 linhas de categoria de 56.
///
/// Sempre claro (DECISOES 12): não lê o tema do app.
class ExpensesSkeletonLoader extends StatelessWidget {
  const ExpensesSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando seus gastos',
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: LummyColors.line100,
          highlightColor: LummyColors.surface100,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              ChildBottomNavMetrics.scrollBottomPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho: avatar 40, título e a pílula "Anotar gasto".
                const Row(
                  children: [
                    _Bloco(largura: 40, altura: 40, raio: 20),
                    SizedBox(width: 12),
                    _Bloco(largura: 72, altura: 26, raio: 8),
                    Spacer(),
                    _Bloco(largura: 132, altura: 44, raio: 22),
                  ],
                ),
                const SizedBox(height: 14),
                // Período.
                const _Bloco(altura: 44, raio: 22),
                const SizedBox(height: 22),
                // Resumo: rótulo, valor e comparação.
                const _Bloco(largura: 170, altura: 16, raio: 6),
                const SizedBox(height: 8),
                const _Bloco(largura: 190, altura: 44, raio: 10),
                const SizedBox(height: 10),
                const _Bloco(largura: 210, altura: 14, raio: 6),
                const SizedBox(height: 28),
                // "Onde foi seu dinheiro".
                const _Bloco(largura: 200, altura: 20, raio: 6),
                const SizedBox(height: 8),
                const _Bloco(largura: 260, altura: 14, raio: 6),
                const SizedBox(height: 10),
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  const _LinhaCategoria(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinhaCategoria extends StatelessWidget {
  const _LinhaCategoria();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 56,
      child: Row(
        children: [
          _Bloco(largura: 40, altura: 40, raio: 14),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _Bloco(largura: 90, altura: 14, raio: 6),
                    Spacer(),
                    _Bloco(largura: 64, altura: 14, raio: 6),
                  ],
                ),
                SizedBox(height: 10),
                _Bloco(altura: 8, raio: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Retângulo arredondado do esqueleto. Sem [largura] ocupa a linha toda.
class _Bloco extends StatelessWidget {
  const _Bloco({this.largura, required this.altura, required this.raio});

  final double? largura;
  final double altura;
  final double raio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largura ?? double.infinity,
      height: altura,
      decoration: BoxDecoration(
        color: LummyColors.line100,
        borderRadius: BorderRadius.circular(raio),
      ),
    );
  }
}
