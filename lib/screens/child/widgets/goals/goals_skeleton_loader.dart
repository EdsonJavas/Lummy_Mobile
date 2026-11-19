import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/child_bottom_nav.dart';

/// Skeleton da primeira carga da aba Metas (redesenho V1).
///
/// Imita o layout novo: cabeçalho (avatar 40 + título), cartão da meta
/// (~214 de altura, raio 24), título e segmentado do simulador (44) e 4 linhas
/// de parada. Sempre claro (a área da criança não segue o modo escuro, D12).
class GoalsSkeletonLoader extends StatelessWidget {
  const GoalsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando suas metas',
      child: ExcludeSemantics(
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
              // Cabeçalho: avatar + título
              const Row(
                children: [
                  _Bloco(largura: 40, altura: 40, raio: 20),
                  SizedBox(width: 12),
                  _Bloco(largura: 96, altura: 26, raio: 8),
                ],
              ),
              const SizedBox(height: 14),
              // Cartão "Sua meta agora"
              const _Bloco(altura: 214, raio: 24),
              const SizedBox(height: 24),
              // Simulador
              const _Bloco(largura: 210, altura: 20, raio: 8),
              const SizedBox(height: 8),
              const _Bloco(largura: 250, altura: 14, raio: 7),
              const SizedBox(height: 10),
              const _Bloco(altura: 44, raio: 22),
              const SizedBox(height: 26),
              // Paradas da viagem
              const _Bloco(largura: 170, altura: 20, raio: 8),
              const SizedBox(height: 14),
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == 3 ? 0 : 18),
                  child: const Row(
                    children: [
                      _Bloco(largura: 28, altura: 28, raio: 14),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Bloco(largura: 160, altura: 15, raio: 7),
                            SizedBox(height: 6),
                            _Bloco(largura: 110, altura: 12, raio: 6),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      _Bloco(largura: 52, altura: 14, raio: 7),
                    ],
                  ),
                ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .fade(begin: 1, end: 0.55, duration: 800.ms, curve: Curves.easeInOut),
      ),
    );
  }
}

/// Bloco cinza-claro do skeleton. Sem [largura] = largura total.
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
        color: LummyColors.surface100,
        borderRadius: BorderRadius.circular(raio),
      ),
    );
  }
}
