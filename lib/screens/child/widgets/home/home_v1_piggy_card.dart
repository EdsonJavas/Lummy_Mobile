import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/data/child/child_goals_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Cofrinho espacial da Home (`Main.dc.html`, `<section aria-label="Meu
/// cofrinho">`): rótulo, saldo grande e, embaixo, a viagem até a meta.
///
/// Estados:
/// - [saldo] nulo = não deu para ler: mostra "—" e tocar tenta de novo;
/// - [estado] nulo = não deu para ler a meta: o bloco de baixo some (não
///   oferece "Criar uma meta" por engano);
/// - sem meta em andamento (inclui meta recém-concluída, DECISOES 23): link
///   branco "Criar uma meta";
/// - com meta: "Rumo à meta: {nome}" (DECISOES 22), trilha e legendas.
class HomeV1PiggyCard extends StatelessWidget {
  const HomeV1PiggyCard({
    super.key,
    required this.saldo,
    required this.estado,
    required this.onTentarDeNovo,
    required this.onCriarMeta,
  });

  final double? saldo;
  final ChildGoalState? estado;
  final VoidCallback onTentarDeNovo;
  final VoidCallback onCriarMeta;

  /// Largura reservada ao astronauta (102 de largura + folga), para o valor
  /// não entrar embaixo dele.
  static const double _reservaAstronauta = 110;

  @override
  Widget build(BuildContext context) {
    return SpaceCard.cofrinho(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meu cofrinho',
            style: LummyText.poppins(
              size: 13,
              weight: FontWeight.w500,
              color: LummyColors.white75,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(right: _reservaAstronauta),
            child: _valor(),
          ),
          const Spacer(),
          ..._blocoDaMeta(),
        ],
      ),
    );
  }

  Widget _valor() {
    final s = saldo;
    if (s == null) {
      return Semantics(
        button: true,
        label: 'Não foi possível carregar o saldo. Toque para tentar de novo.',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTentarDeNovo,
          child: Text('—', style: LummyText.valorCofrinho()),
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        V1Format.brl(s),
        maxLines: 1,
        softWrap: false,
        style: LummyText.valorCofrinho(),
      ),
    );
  }

  List<Widget> _blocoDaMeta() {
    final e = estado;
    // Primeira leitura do saldo falhou: diz o que houve e como resolver.
    if (saldo == null) {
      return [
        Text(
          'Não deu para carregar seu saldo.',
          style: LummyText.poppins(
            size: 13,
            weight: FontWeight.w500,
            color: LummyColors.white75,
          ),
        ),
        const SizedBox(height: 4),
        ThemeLink(
          rotulo: 'Tentar de novo',
          cor: LummyColors.white,
          onTap: onTentarDeNovo,
        ),
      ];
    }
    // Leitura da meta falhou: nada embaixo.
    if (e == null) return const [];

    final meta = e.atual;
    if (meta == null) {
      return [
        ThemeLink(
          rotulo: 'Criar uma meta',
          cor: LummyColors.white,
          onTap: onCriarMeta,
        ),
      ];
    }

    return [
      Text(
        'Rumo à meta: ${meta.name}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: LummyText.poppins(
          size: 15,
          weight: FontWeight.w600,
          color: LummyColors.white,
        ),
      ),
      const SizedBox(height: 12),
      GoalTrail(
        progress: e.progresso,
        semanticLabel: 'Progresso da meta ${meta.name}',
      ),
      const SizedBox(height: 12),
      GoalTrailLegend(
        esquerda:
            '${V1Format.porcento(e.progresso)} de ${V1Format.brl(meta.targetAmount)}',
        direita: 'Faltam ${V1Format.brl(e.falta)}',
      ),
    ];
  }
}
