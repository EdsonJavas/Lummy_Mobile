import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/core/utils/network_errors.dart';
import 'package:lummy/data/child/child_transactions_repository.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_load_error.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_skeleton_loader.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_calc.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_categories.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_need_want.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_recent.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_summary.dart';
import 'package:lummy/screens/child/widgets/sheets/money_sheets.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';
import 'package:lummy/shared/widgets/branded_refresh_indicator.dart';
import 'package:lummy/shared/widgets/lummy_feedback.dart';

/// Aba Gastos da criança (redesenho V1; mockups `Gastos-mes.dc.html` e
/// `Gastos-lista.dc.html`, que são a mesma tela no topo e rolada).
///
/// Uma lista rolável só: cabeçalho com avatar e "Anotar gasto", período,
/// resumo com comparação mensal, "Onde foi seu dinheiro", "Precisava ou
/// queria?" e "Últimos gastos" por dia.
///
/// Dados: uma consulta por carga (`listarGastos`) e o saldo (só como dica para
/// o painel de anotar gasto). Todas as contas são locais, em `ExpensesCalc`.
/// Segue o modo claro/escuro do app (cores de `context.cores`).
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  static const _mensagemErro =
      'Não foi possível carregar seus gastos. Verifique a internet e tente de novo.';

  final _repo = ChildTransactionsRepository();

  late final ChildDataChanges _changes;
  int _versaoGastos = 0;
  int _versaoSaldo = 0;

  /// Primeira carga (ou nova tentativa depois de erro): mostra o esqueleto.
  bool _carregando = true;
  String? _erro;

  /// Já houve uma carga com sucesso (a tela tem o que mostrar).
  bool _temDados = false;

  /// Todos os gastos carregados (cobrem os 3 períodos e o mês anterior).
  List<ChildExpense> _gastos = const [];
  bool _temNeedOrWant = false;

  /// Dica de saldo para o painel de anotar gasto. Nulo = não deu para ler.
  double? _saldo;

  ExpensesPeriod _periodo = ExpensesPeriod.mes;

  /// Categoria que filtra "Últimos gastos" (nulo = todas).
  String? _categoriaId;

  /// "Ver todos os gastos" já foi tocado.
  bool _expandido = false;

  /// Número da carga mais recente: resposta de carga antiga é descartada.
  int _pedido = 0;

  @override
  void initState() {
    super.initState();
    _changes = context.read<ChildDataChanges>();
    _versaoGastos = _changes.versao(ChildDataKind.gastos);
    _versaoSaldo = _changes.versao(ChildDataKind.saldo);
    _changes.addListener(_aoMudarDados);
    _carregar();
  }

  @override
  void dispose() {
    _changes.removeListener(_aoMudarDados);
    super.dispose();
  }

  /// Alguém gravou um gasto ou mexeu no saldo (ex.: o painel de anotar gasto,
  /// aberto daqui ou da Home): recarrega sem esqueleto, mantendo a rolagem.
  void _aoMudarDados() {
    final gastos = _changes.versao(ChildDataKind.gastos);
    final saldo = _changes.versao(ChildDataKind.saldo);
    if (gastos == _versaoGastos && saldo == _versaoSaldo) return;
    _versaoGastos = gastos;
    _versaoSaldo = saldo;
    _carregar(silencioso: true);
  }

  /// O saldo é só uma dica para o painel: falha aqui não derruba a tela.
  Future<double?> _lerSaldo() async {
    try {
      return (await _repo.carregarContexto()).saldo;
    } catch (e, st) {
      debugLogDataLoad('Gastos (saldo)', e, st);
      return null;
    }
  }

  /// Carrega os gastos. [silencioso] não mostra o esqueleto e, em caso de
  /// falha, mantém o que já está na tela. Devolve true se carregou.
  Future<bool> _carregar({bool silencioso = false}) async {
    final pedido = ++_pedido;
    if (!silencioso && mounted && (!_carregando || _erro != null)) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }

    try {
      final saldoFuturo = _lerSaldo();
      final resultado = await _repo.listarGastos(
        desde: ExpensesCalc.inicioDaConsulta(DateTime.now()),
      );
      final saldo = await saldoFuturo;
      if (!mounted || pedido != _pedido) return false;
      setState(() {
        _gastos = resultado.gastos;
        _temNeedOrWant = resultado.temNeedOrWant;
        _saldo = saldo ?? _saldo;
        _temDados = true;
        _carregando = false;
        _erro = null;
      });
      return true;
    } catch (e, st) {
      debugLogDataLoad('Gastos', e, st);
      if (!mounted || pedido != _pedido) return false;
      setState(() {
        _carregando = false;
        // Com dados na tela, a falha de uma recarga não apaga o que já há.
        _erro = _temDados ? null : _mensagemErro;
      });
      return false;
    }
  }

  Future<void> _aoPuxar() async {
    final ok = await _carregar(silencioso: true);
    if (!mounted || ok) return;
    LummyFeedback.error(context, 'Não foi possível atualizar. Tente de novo.');
  }

  void _abrirAnotarGasto() {
    // Ao gravar, o painel avisa `ChildDataChanges` e a tela recarrega sozinha.
    unawaited(showAnotarGastoSheet(context, saldoAtual: _saldo));
  }

  void _trocarPeriodo(ExpensesPeriod periodo) {
    if (periodo == _periodo) return;
    setState(() {
      _periodo = periodo;
      _expandido = false;
      // O filtro só continua se a categoria tiver gasto no período novo.
      final resumo = ExpensesCalc.resumir(_gastos, periodo, DateTime.now());
      if (!_temCategoria(resumo, _categoriaId)) _categoriaId = null;
    });
  }

  void _tocarCategoria(String id) {
    setState(() {
      _categoriaId = _categoriaId == id ? null : id;
      _expandido = false;
    });
  }

  static bool _temCategoria(ExpensesSummary resumo, String? id) =>
      id != null && resumo.categorias.any((c) => c.categoria.id == id);

  @override
  Widget build(BuildContext context) {
    final Widget corpo;
    if (_carregando && !_temDados) {
      corpo = const ExpensesSkeletonLoader();
    } else if (_erro != null) {
      corpo = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _cabecalho(),
          ),
          Expanded(
            child: ExpensesLoadError(message: _erro!, onRetry: _carregar),
          ),
        ],
      );
    } else {
      corpo = _conteudo(context);
    }

    return ColoredBox(
      color: context.cores.fundo,
      child: SafeArea(bottom: false, child: corpo),
    );
  }

  Widget _cabecalho() {
    return ChildTabHeader(
      title: 'Gastos',
      trailing: LummyPillButton(
        rotulo: 'Anotar gasto',
        glyph: LummyGlyphs.shoppingBag,
        onTap: _abrirAnotarGasto,
      ),
    );
  }

  Widget _conteudo(BuildContext context) {
    final tema = ChildThemeColorController.of(context).tema;
    final agora = DateTime.now();
    final resumo = ExpensesCalc.resumir(_gastos, _periodo, agora);
    // Depois de uma recarga a categoria filtrada pode ter sumido do período.
    final filtro = _temCategoria(resumo, _categoriaId) ? _categoriaId : null;
    final recentes = ExpensesCalc.filtrarPorCategoria(resumo.gastos, filtro);
    final needWant = _temNeedOrWant ? resumo.needWant : null;

    return BrandedRefreshIndicator(
      onRefresh: _aoPuxar,
      color: tema,
      backgroundColor: context.cores.superficie,
      // Coluna inteira montada (e não lista preguiçosa): as seções guardam o
      // estado e a animação de entrada não repete ao rolar de volta.
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          ChildBottomNavMetrics.scrollBottomPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _entrada(0, _cabecalho()),
            const SizedBox(height: 14),
            _entrada(
              1,
              LummySegmented<ExpensesPeriod>(
                semanticLabel: 'Período',
                opcoes: [
                  for (final p in ExpensesPeriod.values) LummySegment(p, p.rotulo),
                ],
                selecionado: _periodo,
                onChanged: _trocarPeriodo,
              ),
            ),
            const SizedBox(height: 22),
            _entrada(2, ExpensesV1Summary(resumo: resumo, agora: agora)),
            const SizedBox(height: 28),
            _entrada(
              3,
              ExpensesV1Categories(
                categorias: resumo.categorias,
                selecionadaId: filtro,
                onTap: _tocarCategoria,
              ),
            ),
            // Sem a migration, ou sem gasto classificado no período: a seção
            // inteira fica escondida (DECISOES 7 e 11).
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: needWant == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 26),
                      child: _entrada(4, ExpensesV1NeedWant(dados: needWant)),
                    ),
            ),
            const SizedBox(height: 26),
            _entrada(
              5,
              ExpensesV1Recent(
                gastos: recentes,
                expandido: _expandido,
                agora: agora,
                onVerTodos: () => setState(() => _expandido = true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Entrada da primeira carga: aparece e sobe de leve, escalonado por seção.
  /// A animação roda uma vez, quando a seção é montada.
  Widget _entrada(int ordem, Widget child) {
    return child
        .animate(delay: (40 * ordem).ms)
        .fadeIn(duration: 240.ms, curve: Curves.easeOut)
        .slideY(begin: 0.02, end: 0, duration: 240.ms, curve: Curves.easeOutCubic);
  }
}
