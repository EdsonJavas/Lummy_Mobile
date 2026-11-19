import 'package:lummy/data/child/child_transactions_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Contas puras da aba Gastos (redesenho V1). Sem widgets e sem banco:
/// recebem a lista que veio de `ChildTransactionsRepository.listarGastos`
/// (rejeitados já fora) e devolvem o que a tela mostra.

/// Períodos do segmentado do topo de Gastos.
enum ExpensesPeriod {
  /// Hoje e os 6 dias anteriores (7 dias de calendário).
  semana('Semana'),

  /// Do dia 1 do mês atual (inclusivo) até hoje. É o padrão.
  mes('Mês'),

  /// Hoje e os 89 dias anteriores.
  tresMeses('3 meses');

  const ExpensesPeriod(this.rotulo);

  /// Texto do botão.
  final String rotulo;
}

/// Comparação do mês atual com o mesmo trecho do mês anterior (do dia 1 até o
/// dia de hoje), para não pôr um mês pela metade contra um mês inteiro.
class ExpensesComparison {
  const ExpensesComparison({required this.diferenca, required this.mesAnterior});

  /// `totalMesAtual − totalMesAnterior`. Negativo = gastou menos. Nunca zero.
  final double diferenca;

  /// Um dia qualquer do mês anterior (para escrever "outubro").
  final DateTime mesAnterior;

  bool get gastouMenos => diferenca < 0;
}

/// Total de uma categoria no período.
class ExpensesCategoryTotal {
  const ExpensesCategoryTotal({
    required this.categoria,
    required this.valor,
    required this.fracao,
  });

  final ChildExpenseCategory categoria;
  final double valor;

  /// Fatia real do total do período (0..1).
  final double fracao;
}

/// Divisão "Precisava ou queria?" dos gastos classificados do período.
class ExpensesNeedWant {
  const ExpensesNeedWant({
    required this.precisava,
    required this.queria,
    required this.porcentoPrecisava,
    required this.porcentoQueria,
  });

  final double precisava;
  final double queria;

  /// Percentuais inteiros; a soma é sempre 100.
  final int porcentoPrecisava;
  final int porcentoQueria;

  /// Fração da barra para "Precisava" (0..1).
  double get fracaoPrecisava {
    final soma = precisava + queria;
    return soma <= 0 ? 0 : precisava / soma;
  }

  /// "Mais da metade foi com coisas que você queria."
  bool get maisDaMetadeQueria => queria > precisava;
}

/// Gastos de um mesmo dia, para "Últimos gastos".
class ExpensesDayGroup {
  const ExpensesDayGroup({required this.data, required this.gastos});

  final DateTime data;
  final List<ChildExpense> gastos;
}

/// Tudo o que a tela mostra para um período.
class ExpensesSummary {
  const ExpensesSummary({
    required this.periodo,
    required this.total,
    required this.comparacao,
    required this.categorias,
    required this.needWant,
    required this.gastos,
  });

  final ExpensesPeriod periodo;

  /// Soma dos gastos do período.
  final double total;

  /// Só em [ExpensesPeriod.mes], com mês anterior > 0 e diferença ≠ 0.
  final ExpensesComparison? comparacao;

  /// Só categorias com valor > 0, da maior para a menor.
  final List<ExpensesCategoryTotal> categorias;

  /// Nulo se não houver gasto classificado no período.
  final ExpensesNeedWant? needWant;

  /// Gastos do período, do mais novo para o mais antigo.
  final List<ChildExpense> gastos;
}

abstract final class ExpensesCalc {
  /// Quantos gastos "Últimos gastos" mostra antes de "Ver todos os gastos".
  static const limiteRecentes = 5;

  /// Data sem hora, no fuso local.
  static DateTime soData(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Primeiro dia que a consulta precisa trazer: o menor entre o dia 1 do mês
  /// anterior (comparação mensal) e hoje − 89 dias ("3 meses").
  static DateTime inicioDaConsulta(DateTime agora) {
    final mesAnterior = DateTime(agora.year, agora.month - 1, 1);
    final tresMeses = inicioDoPeriodo(ExpensesPeriod.tresMeses, agora);
    return mesAnterior.isBefore(tresMeses) ? mesAnterior : tresMeses;
  }

  /// Primeiro dia (inclusivo) do [periodo]. Usa o construtor de data (e não
  /// `subtract`) para o horário de verão não deslocar o dia.
  static DateTime inicioDoPeriodo(ExpensesPeriod periodo, DateTime agora) {
    return switch (periodo) {
      ExpensesPeriod.semana => DateTime(agora.year, agora.month, agora.day - 6),
      ExpensesPeriod.mes => DateTime(agora.year, agora.month, 1),
      ExpensesPeriod.tresMeses => DateTime(agora.year, agora.month, agora.day - 89),
    };
  }

  /// Gastos com data entre [inicio] e [fim], os dois INCLUSIVOS (corrige o
  /// `isAfter` antigo, que deixava o dia 1 de fora do mês).
  static List<ChildExpense> entre(
    List<ChildExpense> gastos,
    DateTime inicio,
    DateTime fim,
  ) {
    final a = soData(inicio);
    final b = soData(fim);
    return gastos.where((g) {
      final d = soData(g.data);
      return !d.isBefore(a) && !d.isAfter(b);
    }).toList();
  }

  static double somar(Iterable<ChildExpense> gastos) =>
      gastos.fold<double>(0, (soma, g) => soma + g.valor);

  /// Monta o resumo do [periodo] a partir de todos os [gastos] carregados.
  static ExpensesSummary resumir(
    List<ChildExpense> gastos,
    ExpensesPeriod periodo,
    DateTime agora,
  ) {
    final hoje = soData(agora);
    final doPeriodo = entre(gastos, inicioDoPeriodo(periodo, agora), hoje);
    final total = somar(doPeriodo);
    return ExpensesSummary(
      periodo: periodo,
      total: total,
      comparacao: periodo == ExpensesPeriod.mes ? _comparar(gastos, total, agora) : null,
      categorias: _porCategoria(doPeriodo, total),
      needWant: _needWant(doPeriodo),
      gastos: doPeriodo,
    );
  }

  static ExpensesComparison? _comparar(
    List<ChildExpense> gastos,
    double totalMesAtual,
    DateTime agora,
  ) {
    final inicio = DateTime(agora.year, agora.month - 1, 1);
    // Dia 0 do mês atual = último dia do mês anterior.
    final ultimoDia = DateTime(agora.year, agora.month, 0).day;
    final fim = DateTime(
      inicio.year,
      inicio.month,
      agora.day < ultimoDia ? agora.day : ultimoDia,
    );
    final totalAnterior = somar(entre(gastos, inicio, fim));
    if (_centavos(totalAnterior) <= 0) return null;
    final diferenca = totalMesAtual - totalAnterior;
    if (_centavos(diferenca) == 0) return null;
    return ExpensesComparison(diferenca: diferenca, mesAnterior: inicio);
  }

  static List<ExpensesCategoryTotal> _porCategoria(
    List<ChildExpense> doPeriodo,
    double total,
  ) {
    final somas = <String, double>{};
    for (final g in doPeriodo) {
      // Normaliza pelo catálogo para id vazio/nulo cair em "Outros".
      final id = ChildCategories.porId(g.categoriaId).id;
      somas[id] = (somas[id] ?? 0) + g.valor;
    }
    final lista = [
      for (final e in somas.entries)
        if (e.value > 0)
          ExpensesCategoryTotal(
            categoria: ChildCategories.porId(e.key),
            valor: e.value,
            fracao: total > 0 ? e.value / total : 0,
          ),
    ];
    lista.sort((a, b) {
      final porValor = b.valor.compareTo(a.valor);
      return porValor != 0 ? porValor : a.categoria.nome.compareTo(b.categoria.nome);
    });
    return lista;
  }

  static ExpensesNeedWant? _needWant(List<ChildExpense> doPeriodo) {
    var precisava = 0.0;
    var queria = 0.0;
    var classificados = 0;
    for (final g in doPeriodo) {
      switch (g.needOrWant) {
        case NeedOrWant.need:
          precisava += g.valor;
          classificados++;
        case NeedOrWant.want:
          queria += g.valor;
          classificados++;
        case null:
          break;
      }
    }
    final soma = precisava + queria;
    if (classificados == 0 || soma <= 0) return null;
    final pNeed = (precisava / soma * 100).round();
    return ExpensesNeedWant(
      precisava: precisava,
      queria: queria,
      porcentoPrecisava: pNeed,
      porcentoQueria: 100 - pNeed,
    );
  }

  /// Gastos do período filtrados pela categoria tocada (nulo = todos).
  static List<ChildExpense> filtrarPorCategoria(
    List<ChildExpense> gastos,
    String? categoriaId,
  ) {
    if (categoriaId == null) return gastos;
    return gastos
        .where((g) => ChildCategories.porId(g.categoriaId).id == categoriaId)
        .toList();
  }

  /// Agrupa por dia mantendo a ordem recebida (mais novo primeiro).
  static List<ExpensesDayGroup> agruparPorDia(List<ChildExpense> gastos) {
    final grupos = <ExpensesDayGroup>[];
    for (final g in gastos) {
      final dia = soData(g.data);
      if (grupos.isNotEmpty && grupos.last.data == dia) {
        grupos.last.gastos.add(g);
      } else {
        grupos.add(ExpensesDayGroup(data: dia, gastos: [g]));
      }
    }
    return grupos;
  }

  static int _centavos(double valor) => (valor * 100).round();
}
