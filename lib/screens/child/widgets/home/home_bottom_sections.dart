import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/data/child/child_achievements_repository.dart';
import 'package:lummy/data/child/child_missions_repository.dart';
import 'package:lummy/screens/child/daily_missions_screen.dart';
import 'package:lummy/screens/child/lessons_screen.dart';
import 'package:lummy/screens/child/profile_page.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'home_b_achievements.dart';
import 'home_b_lesson_card.dart';
import 'home_b_missions.dart';
import 'home_b_streak.dart';
import 'home_b_tip.dart';

/// Seções de baixo da Home, em ordem: "Missões de hoje" (com "Ver todas as
/// missões"), "Dica do Lummy", cartão de aula rápida, "Sequência de
/// dias" e "Conquistas" (`Main.dc.html` a partir de "Missões de hoje" e
/// `Home-rolagem.dc.html`).
///
/// CONTRATO (arquiteto) entre o DEV 2 (dono de `home_page.dart`, que coloca
/// este widget logo abaixo das ações rápidas) e o DEV 3 (dono deste arquivo):
/// - o construtor abaixo NÃO muda;
/// - este widget carrega sozinho missões e conquistas
///   (`ChildMissionsRepository.missoesDeHoje`, `ChildAchievementsRepository`)
///   e recarrega quando [refreshTick] muda (puxar para atualizar da Home) ou
///   quando `ChildDataChanges` avisa `missoes`/`conquistas`;
/// - a sequência vem pronta da Home em [streak] (a Home também usa o número
///   na pílula do topo); nula ou `diasSeguidos == 0` = esconder a seção;
/// - ao voltar da tela de Missões, chama SÓ [onMissoesTalvezMudaram]; a Home
///   avisa `ChildDataChanges` ({missoes}) e cada um recarrega pelo próprio
///   listener (a Home: sequência e perfil; este widget: a lista de missões).
/// - devolve uma `Column` (não é sliver; a Home usa `SingleChildScrollView`
///   ou `SliverToBoxAdapter`). Sem padding lateral: a Home já aplica 20.
///
/// Implementação: DEV 3 (ver devs/dev-3.md), nos arquivos `home_b_*.dart`.
class HomeBottomSections extends StatefulWidget {
  const HomeBottomSections({
    super.key,
    required this.refreshTick,
    required this.streak,
    required this.onMissoesTalvezMudaram,
  });

  /// Muda a cada "puxar para atualizar" da Home.
  final int refreshTick;

  /// Sequência de dias calculada pela Home (ou nula).
  final ChildStreak? streak;

  /// Chamado depois de voltar da `DailyMissionsScreen` (a Home avisa o resto).
  final VoidCallback onMissoesTalvezMudaram;

  @override
  State<HomeBottomSections> createState() => _HomeBottomSectionsState();
}

class _HomeBottomSectionsState extends State<HomeBottomSections> {
  final _missoesRepo = ChildMissionsRepository();
  final _conquistasRepo = ChildAchievementsRepository();

  late final ChildDataChanges _changes;
  late int _versaoMissoes;
  late int _versaoConquistas;

  /// Nula = primeira carga em andamento (esqueleto).
  List<DailyMissionItem>? _missoes;

  /// A primeira carga falhou: esconde a seção (briefing, "Erro: esconda").
  bool _missoesFalhou = false;

  /// Só as conquistadas, mais recentes primeiro. Vazia = seção escondida.
  List<ChildAchievement> _conquistas = const [];

  // Descartam respostas antigas quando duas cargas se cruzam.
  int _pedidoMissoes = 0;
  int _pedidoConquistas = 0;

  late final LessonItem? _aula = HomeBLessonCard.aulaRapida();

  @override
  void initState() {
    super.initState();
    _changes = context.read<ChildDataChanges>();
    _versaoMissoes = _changes.versao(ChildDataKind.missoes);
    _versaoConquistas = _changes.versao(ChildDataKind.conquistas);
    _changes.addListener(_aoMudarDados);
    _carregarMissoes();
    _carregarConquistas();
  }

  @override
  void didUpdateWidget(HomeBottomSections oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      // Puxar para atualizar: recarrega mantendo o conteúdo até chegar o novo.
      _carregarMissoes();
      _carregarConquistas();
    }
  }

  @override
  void dispose() {
    _changes.removeListener(_aoMudarDados);
    super.dispose();
  }

  void _aoMudarDados() {
    final vMissoes = _changes.versao(ChildDataKind.missoes);
    if (vMissoes != _versaoMissoes) {
      _versaoMissoes = vMissoes;
      _carregarMissoes();
    }
    final vConquistas = _changes.versao(ChildDataKind.conquistas);
    if (vConquistas != _versaoConquistas) {
      _versaoConquistas = vConquistas;
      _carregarConquistas();
    }
  }

  Future<void> _carregarMissoes() async {
    final pedido = ++_pedidoMissoes;
    try {
      final lista = await _missoesRepo.missoesDeHoje();
      if (!mounted || pedido != _pedidoMissoes) return;
      setState(() {
        _missoes = lista;
        _missoesFalhou = false;
      });
    } catch (e) {
      appLog('⚠️ Missões de hoje (Home): $e');
      if (!mounted || pedido != _pedidoMissoes) return;
      // Se já havia lista na tela, ela fica; só a primeira carga esconde a seção.
      if (_missoes == null) setState(() => _missoesFalhou = true);
    }
  }

  Future<void> _carregarConquistas() async {
    final pedido = ++_pedidoConquistas;
    try {
      final resultado = await _conquistasRepo.listar();
      if (!mounted || pedido != _pedidoConquistas) return;
      setState(() => _conquistas = resultado.conquistadas);
    } catch (e) {
      appLog('⚠️ Conquistas (Home): $e');
      // Mantém o que já estava na tela (vazio = seção escondida).
    }
  }

  /// Toque numa missão, no check ou em "Ver todas as missões". Concluir
  /// missão só existe na tela de Missões; ao voltar, a Home avisa
  /// `ChildDataChanges` e a lista recarrega pelo listener.
  Future<void> _abrirMissoes() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DailyMissionsScreen()),
    );
    if (!mounted) return;
    widget.onMissoesTalvezMudaram();
  }

  void _abrirAula() {
    ChildShellScope.read(context)?.goToTab(ChildTabs.aprender);
  }

  /// Não existe tela de conquistas da criança: elas ficam no Perfil.
  void _abrirConquistas() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missoes = _missoes;
    final mostrarMissoes = !_missoesFalhou && (missoes == null || missoes.isNotEmpty);
    final aula = _aula;
    final streak = widget.streak;

    // Cada seção leva o `margin-top` do mockup; a primeira que aparecer usa 26
    // (o espaço depois das ações rápidas), mesmo se "Missões de hoje" sumir.
    final secoes = <Widget>[];
    void secao(String chave, double margemTopo, Widget conteudo) {
      final indice = secoes.length;
      secoes.add(
        Padding(
          padding: EdgeInsets.only(top: indice == 0 ? 26 : margemTopo),
          child: conteudo,
        )
            .animate(key: ValueKey(chave))
            .fadeIn(delay: (60 * indice).ms, duration: 220.ms)
            // Herda o atraso e a duração do fadeIn (roda junto com ele).
            .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
      );
    }

    if (mostrarMissoes) {
      secao('missoes', 26, HomeBMissions(missoes: missoes, onAbrirMissoes: _abrirMissoes));
    }
    secao('dica', 18, const HomeBTip());
    if (aula != null) {
      secao('aula', 14, HomeBLessonCard(aula: aula, onTap: _abrirAula));
    }
    if (streak != null && streak.diasSeguidos > 0) {
      secao('sequencia', 22, HomeBStreak(streak: streak));
    }
    if (_conquistas.isNotEmpty) {
      secao(
        'conquistas',
        20,
        HomeBAchievements(conquistas: _conquistas, onVerTodas: _abrirConquistas),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: secoes,
    );
  }
}
