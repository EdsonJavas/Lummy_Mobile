import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/data/child/child_goals_repository.dart';
import 'package:lummy/models/goal.dart';
import 'package:lummy/screens/child/flows/criar_meta_flow.dart';
import 'package:lummy/screens/child/widgets/goals/goals_delete_confirmation_dialog.dart';
import 'package:lummy/screens/child/widgets/goals/goals_skeleton_loader.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_calc.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_card.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_completed.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_empty_card.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_error.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_manage.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_simulator.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_stops.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';
import 'package:lummy/shared/widgets/branded_refresh_indicator.dart';
import 'package:lummy/shared/widgets/lummy_feedback.dart';

/// Aba Metas (redesenho V1; `Metas-atual.dc.html` + `Metas-rolagem.dc.html`).
///
/// Regras do produto:
/// - uma meta por vez;
/// - o progresso da meta é o saldo do cofrinho (não existe "adicionar
///   progresso" nem "marcar concluída": a conclusão é automática pelo saldo,
///   feita por `ChildGoalsRepository.carregarMetaSincronizada`);
/// - criar meta passa sempre por `abrirCriacaoDeMeta`.
///
/// Sempre clara (o `Theme` claro vem da casca, `MainNavigation`).
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final ChildGoalsRepository _repo = ChildGoalsRepository();

  late final ChildDataChanges _changes;
  int _versaoMeta = 0;
  int _versaoSaldo = 0;

  /// Nulo até a primeira carga dar certo.
  ChildGoalState? _estado;

  /// Metas concluídas. Vazia também quando a leitura falha (a seção some).
  List<Goal> _concluidas = const [];

  bool _carregando = true;
  bool _erro = false;
  bool _excluindo = false;

  /// Valor escolhido no simulador; sobrevive às recargas.
  int _valorPorSemana = GoalsV1Calc.valorPorSemanaPadrao;

  /// Descarta a resposta de uma carga antiga quando outra começou depois.
  int _cargaAtual = 0;

  @override
  void initState() {
    super.initState();
    _changes = context.read<ChildDataChanges>();
    _versaoMeta = _changes.versao(ChildDataKind.meta);
    _versaoSaldo = _changes.versao(ChildDataKind.saldo);
    _changes.addListener(_aoMudarDados);
    _carregar();
  }

  @override
  void dispose() {
    _changes.removeListener(_aoMudarDados);
    super.dispose();
  }

  /// Outra tela gravou meta ou saldo (ex.: gasto anotado na Home): recarrega
  /// sem skeleton, mantendo a rolagem e o valor do simulador.
  void _aoMudarDados() {
    final meta = _changes.versao(ChildDataKind.meta);
    final saldo = _changes.versao(ChildDataKind.saldo);
    if (meta == _versaoMeta && saldo == _versaoSaldo) return;
    _versaoMeta = meta;
    _versaoSaldo = saldo;
    if (!mounted) return;
    _carregar(silencioso: true);
  }

  /// Carrega a meta (já sincronizada com o cofrinho) e as concluídas.
  ///
  /// [silencioso]: não mostra o skeleton e, se falhar, mantém o que já está
  /// na tela. Devolve false se a leitura da meta falhou.
  Future<bool> _carregar({bool silencioso = false}) async {
    final carga = ++_cargaAtual;
    final mostrarSkeleton = !silencioso || _estado == null;
    if (mostrarSkeleton && mounted && (!_carregando || _erro)) {
      setState(() {
        _carregando = true;
        _erro = false;
      });
    }

    try {
      // A meta vem antes das concluídas (e não em paralelo) porque a
      // sincronização pode concluir a meta agora: lendo depois, ela já entra
      // em "Metas conquistadas" na mesma carga.
      final estado = await _repo.carregarMetaSincronizada();
      final concluidas = await _listarConcluidas();
      if (!mounted || carga != _cargaAtual) return true;
      final metaAntes = _estado?.atual;
      setState(() {
        _estado = estado;
        _concluidas = concluidas;
        _carregando = false;
        _erro = false;
      });
      // A sincronização concluiu a meta nesta carga: avisa a Home. A versão é
      // adiantada antes do aviso para esta tela não recarregar de novo.
      if (metaAntes != null &&
          estado.atual == null &&
          estado.ultimaConcluida?.id == metaAntes.id) {
        _versaoMeta = _changes.versao(ChildDataKind.meta) + 1;
        _changes.avisar({ChildDataKind.meta});
      }
      return true;
    } catch (e) {
      appLog('❌ Metas: erro ao carregar: $e');
      if (!mounted || carga != _cargaAtual) return false;
      setState(() {
        _carregando = false;
        // Com dados na tela, uma recarga que falha não apaga nada.
        _erro = _estado == null;
      });
      return false;
    }
  }

  /// Falha aqui só esconde a seção "Metas conquistadas".
  Future<List<Goal>> _listarConcluidas() async {
    try {
      return await _repo.listarConcluidas();
    } catch (e) {
      appLog('⚠️ Metas: erro ao listar concluídas: $e');
      return const [];
    }
  }

  Future<void> _aoPuxar() async {
    final ok = await _carregar(silencioso: true);
    if (!mounted || ok || _erro) return;
    LummyFeedback.error(
      context,
      'Não foi possível atualizar. Verifique a internet e tente de novo.',
    );
  }

  void _criarMeta() {
    // O fluxo grava, mostra o retorno e avisa ChildDataChanges ({meta});
    // esta tela recarrega pelo aviso.
    abrirCriacaoDeMeta(context);
  }

  Future<void> _desistirDaMeta(Goal meta) async {
    if (_excluindo) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => GoalsDeleteConfirmationDialog(
        goal: meta,
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (confirmou != true || !mounted) return;

    setState(() => _excluindo = true);
    try {
      await _repo.excluirMeta(meta.id);
    } catch (e) {
      appLog('❌ Metas: erro ao remover meta: $e');
      if (!mounted) return;
      setState(() => _excluindo = false);
      LummyFeedback.error(
        context,
        'Não foi possível remover a meta. Tente de novo.',
      );
      return;
    }
    if (!mounted) return;

    // A meta já saiu do banco: tira da tela agora, sem esperar a recarga.
    final anterior = _estado;
    setState(() {
      _excluindo = false;
      _estado = ChildGoalState(
        saldo: anterior?.saldo ?? 0,
        ultimaConcluida: _concluidas.isEmpty ? null : _concluidas.first,
      );
    });
    // O aviso atualiza a Home e, pelo listener, recarrega esta tela.
    _changes.avisar({ChildDataKind.meta});
    LummyFeedback.success(context, 'Meta removida');
  }

  @override
  Widget build(BuildContext context) {
    final tema = ChildThemeColorController.of(context).tema;
    final estado = _estado;

    final Widget corpo;
    if (estado == null && !_erro) {
      corpo = const GoalsSkeletonLoader();
    } else {
      corpo = BrandedRefreshIndicator(
        color: tema,
        backgroundColor: LummyColors.white,
        onRefresh: _aoPuxar,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ConstrainedBox(
              // Conteúdo curto ainda ocupa a tela toda, para dar para puxar
              // e atualizar de qualquer ponto.
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ChildTabHeader(title: 'Metas'),
                  if (estado == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: GoalsV1Error(onTentarDeNovo: () => _carregar()),
                    )
                  else
                    ..._secoes(estado),
                  SizedBox(
                    height: ChildBottomNavMetrics.scrollBottomPadding(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: LummyColors.white,
      child: SafeArea(bottom: false, child: corpo),
    );
  }

  /// Seções da tela, com os espaços do mockup (`margin-top` de cada uma).
  List<Widget> _secoes(ChildGoalState estado) {
    final meta = estado.atual;
    final secoes = <Widget>[];

    void adicionar(String chave, int ordem, double topo, Widget child) {
      secoes.add(
        Padding(
          key: ValueKey(chave),
          padding: EdgeInsets.only(top: topo),
          child: child
              .animate()
              .fadeIn(
                delay: (60 * ordem).ms,
                duration: 240.ms,
                curve: Curves.easeOut,
              )
              .slideY(begin: 0.02, end: 0, curve: Curves.easeOutCubic),
        ),
      );
    }

    if (meta == null) {
      // Sem meta em andamento: "concluída" se já existe alguma concluída;
      // "sem meta" se não existe nenhuma (DECISOES 23).
      adicionar(
        'vazio',
        0,
        14,
        GoalsV1EmptyCard(
          ultimaConcluida: estado.ultimaConcluida,
          onCriarMeta: _criarMeta,
        ),
      );
      if (_concluidas.isNotEmpty) {
        adicionar('conquistadas', 3, 30, GoalsV1Completed(metas: _concluidas));
      }
      return secoes;
    }

    adicionar(
      'cartao',
      0,
      14,
      GoalsV1Card(meta: meta, progresso: estado.progresso, falta: estado.falta),
    );
    if (estado.falta > 0) {
      adicionar(
        'simulador',
        1,
        24,
        GoalsV1Simulator(
          falta: estado.falta,
          valorPorSemana: _valorPorSemana,
          onValorChanged: (valor) {
            if (valor == _valorPorSemana) return;
            setState(() => _valorPorSemana = valor);
          },
        ),
      );
    }
    final paradas = GoalsV1Calc.paradas(
      nomeDaMeta: meta.name,
      alvo: meta.targetAmount,
      saldo: estado.saldo,
    );
    if (paradas.isNotEmpty) {
      adicionar('paradas', 2, 26, GoalsV1Stops(paradas: paradas));
    }
    if (_concluidas.isNotEmpty) {
      adicionar('conquistadas', 3, 30, GoalsV1Completed(metas: _concluidas));
    }
    adicionar(
      'gerenciar',
      4,
      28,
      GoalsV1Manage(
        nomeDaMeta: meta.name,
        onDesistir: _excluindo ? null : () => _desistirDaMeta(meta),
      ),
    );
    return secoes;
  }
}
