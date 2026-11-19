import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/data/child/child_missions_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'home_b_mission_row.dart';

/// Seção "Missões de hoje" da Home (`Main.dc.html`, `<section
/// aria-label="Missões de hoje">`, e o começo de `Home-rolagem.dc.html`):
/// título com contagem, barra de segmentos com o baú, legenda, lista única
/// (pendentes primeiro, feitas depois: DECISOES 16) e "Ver todas as missões".
///
/// [missoes] nula = primeira carga (esqueleto). Lista vazia não chega aqui:
/// quem usa esconde a seção.
class HomeBMissions extends StatelessWidget {
  const HomeBMissions({super.key, required this.missoes, required this.onAbrirMissoes});

  final List<DailyMissionItem>? missoes;

  /// Abre a tela de Missões (toque na linha, no check ou no link).
  final VoidCallback onAbrirMissoes;

  @override
  Widget build(BuildContext context) {
    final lista = missoes;
    if (lista == null) return const _Carregando();

    final total = lista.length;
    final feitas = lista.where((m) => m.concluida).length;
    // DECISOES 16: pendentes primeiro, feitas depois; cada grupo na ordem do banco.
    final ordenadas = [
      ...lista.where((m) => !m.concluida),
      ...lista.where((m) => m.concluida),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionTitle(titulo: 'Missões de hoje', contagem: '$feitas de $total'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _Segmentos(total: total, feitas: feitas)),
            const SizedBox(width: 10),
            const LummyIcon(
              LummyGlyphs.gift,
              size: 20,
              color: LummyColors.brandGold,
              strokeWidth: 2.2,
            ),
          ],
        ),
        // Com todas feitas o mockup não desenhou texto: a legenda some.
        if (feitas < total) ...[
          const SizedBox(height: 8),
          Text('Complete as $total e abra o baú do dia.', style: LummyText.apoio()),
        ],
        const SizedBox(height: 4),
        for (final m in ordenadas)
          HomeBMissionRow(
            key: ValueKey('missao-${m.missionId}'),
            missao: m,
            onTap: onAbrirMissoes,
          ),
        const SizedBox(height: 4),
        ThemeLink(rotulo: 'Ver todas as missões', gap: 4, onTap: onAbrirMissoes),
      ],
    );
  }
}

/// Barra de progresso em [total] segmentos iguais (`gap: 4px`, altura 6,
/// raio 3): os feitos em verde, da esquerda para a direita.
class _Segmentos extends StatelessWidget {
  const _Segmentos({required this.total, required this.feitas});

  final int total;
  final int feitas;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 6,
                decoration: BoxDecoration(
                  color: i < feitas ? LummyColors.brandGreen : LummyColors.line100,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Primeira carga: título e 3 linhas-esqueleto de 56.
class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionTitle(titulo: 'Missões de hoje'),
        SizedBox(height: 4),
        HomeBMissionRowSkeleton(larguraTitulo: 0.75),
        HomeBMissionRowSkeleton(larguraTitulo: 0.9),
        HomeBMissionRowSkeleton(larguraTitulo: 0.6),
      ],
    );
  }
}
