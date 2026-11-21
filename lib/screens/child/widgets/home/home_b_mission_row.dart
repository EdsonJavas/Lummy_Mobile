import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/data/child/child_missions_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Uma linha da lista "Missões de hoje" (`Main.dc.html` e
/// `Home-rolagem.dc.html`, `<li>`): check 44×44 puxado 9 px para a esquerda,
/// título e "+N XP", com altura mínima 56 e linha `#EEF0F4` embaixo.
///
/// Tocar em qualquer ponto chama [onTap] (abre a tela de Missões: concluir
/// missão só existe lá).
class HomeBMissionRow extends StatelessWidget {
  const HomeBMissionRow({super.key, required this.missao, required this.onTap});

  final DailyMissionItem missao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final feita = missao.concluida;
    return Semantics(
      button: true,
      label: feita
          ? 'Missão concluída: ${missao.titulo}, mais ${missao.pontos} XP'
          : 'Marcar como feita: ${missao.titulo}, mais ${missao.pontos} XP',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          // 56 de conteúdo + 1 da linha de baixo (o <li> do mockup é
          // content-box).
          constraints: const BoxConstraints(minHeight: 57),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.cores.linha)),
          ),
          child: Row(
            children: [
              // `width: 44; margin-left: -9px`: ocupa 35 no layout e desenha
              // os 44 começando 9 px antes.
              SizedBox(
                width: 35,
                height: 44,
                child: OverflowBox(
                  alignment: Alignment.centerRight,
                  minWidth: 44,
                  maxWidth: 44,
                  child: Center(child: _Check(feita: feita)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Padding(
                  // Só protege títulos de 3 linhas ou mais (o mockup tem 1).
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    missao.titulo,
                    style: feita
                        ? LummyText.poppins(
                            context,
                            size: 15,
                            color: context.cores.tintaApoio,
                            decoration: TextDecoration.lineThrough,
                          )
                        : LummyText.corpo(context),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              XpChip(pontos: missao.pontos, feito: feita),
            ],
          ),
        ),
      ),
    );
  }
}

/// Círculo 26×26: pendente = borda 2 `#B4BACA`; feita = verde com `check`.
class _Check extends StatelessWidget {
  const _Check({required this.feita});

  final bool feita;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: feita ? LummyColors.brandGreen : null,
        border: feita ? null : Border.all(color: context.cores.bordaPendente, width: 2),
      ),
      child: feita
          ? const LummyIcon(
              LummyGlyphs.check,
              size: 15,
              color: LummyColors.white,
              strokeWidth: 3,
            )
          : null,
    );
  }
}

/// Linha-esqueleto da primeira carga (mesma altura e linha de baixo).
class HomeBMissionRowSkeleton extends StatelessWidget {
  const HomeBMissionRowSkeleton({super.key, this.larguraTitulo = 0.7});

  /// Fração do espaço do título ocupada pelo retângulo.
  final double larguraTitulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.cores.linha)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.cores.superficieNeutra,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: larguraTitulo,
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: context.cores.superficieNeutra,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 14,
            decoration: BoxDecoration(
              color: context.cores.superficieNeutra,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      ),
    );
  }
}
