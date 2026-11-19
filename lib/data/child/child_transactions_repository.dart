import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/utils/network_errors.dart';

/// "Você precisava ou só queria?" (coluna nova `transactions.need_or_want`).
enum NeedOrWant {
  need('need', 'Precisava'),
  want('want', 'Queria');

  const NeedOrWant(this.db, this.rotulo);

  /// Valor gravado no banco.
  final String db;

  /// Texto mostrado à criança.
  final String rotulo;

  static NeedOrWant? fromDb(Object? valor) {
    for (final v in NeedOrWant.values) {
      if (v.db == valor) return v;
    }
    return null;
  }
}

/// Saldo e categorias liberadas pelos pais (`children`).
class ChildMoneyContext {
  const ChildMoneyContext({required this.saldo, required this.categoriasPermitidas});

  /// `children.balance`.
  final double saldo;

  /// `children.allowed_categories` (ids). Lista vazia = sem restrição.
  /// Para a lista pronta de categorias use `ChildCategories.permitidas(...)`.
  final List<String> categoriasPermitidas;
}

/// Um gasto da criança, como a aba Gastos precisa.
class ChildExpense {
  const ChildExpense({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.categoriaId,
    required this.data,
    required this.status,
    this.criadoEm,
    this.needOrWant,
  });

  final String id;

  /// `description` (NOT NULL). Gastos do painel novo gravam o nome da
  /// categoria (D19); gastos antigos têm texto livre.
  final String descricao;
  final double valor;

  /// `category` (id do banco).
  final String categoriaId;

  /// `date` (coluna DATE, data local, sem hora).
  final DateTime data;

  /// `status`: pending, approved ou completed (rejeitados já vêm filtrados).
  final String status;

  /// `created_at` em hora local, para ordenar dentro do dia. Pode faltar.
  final DateTime? criadoEm;

  /// Nulo em gastos antigos ou se a migration ainda não foi aplicada.
  final NeedOrWant? needOrWant;
}

/// Resultado de [ChildTransactionsRepository.listarGastos].
class ChildExpensesResult {
  const ChildExpensesResult({required this.gastos, required this.temNeedOrWant});

  /// Ordenados do mais novo para o mais antigo (data, depois `created_at`).
  final List<ChildExpense> gastos;

  /// false = a coluna `need_or_want` ainda não existe no banco (migration
  /// não aplicada). Nesse caso esconda as seções "Precisava ou queria".
  final bool temNeedOrWant;
}

/// Resultado de gravar um gasto ou ganho.
enum SaveMoneyResult {
  /// Gravado.
  ok,

  /// O gasto é maior que o saldo (nada foi gravado nem debitado).
  saldoInsuficiente,

  /// Valor zero ou negativo.
  valorInvalido,

  /// Sem usuário logado.
  semSessao,

  /// Falha de banco ou rede. O saldo NÃO fica alterado (se o débito já tinha
  /// sido feito, ele é devolvido; se não tinha, nada é creditado).
  erro,
}

/// Acesso a `transactions` (e ao saldo em `children`) pela criança.
///
/// Substitui `_saveTransactionToDatabase` de `expenses_screen.dart`, com as
/// correções do DECISOES 8 e o fallback do DECISOES 11.
class ChildTransactionsRepository {
  ChildTransactionsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _colunasGasto = 'id, description, amount, category, date, status, created_at';

  /// Lê saldo e categorias liberadas da criança logada.
  /// Lança exceção em falha de rede/banco (a tela decide o estado de erro).
  Future<ChildMoneyContext> carregarContexto() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const ChildMoneyContext(saldo: 0, categoriasPermitidas: []);
    }
    final row = await _client
        .from('children')
        .select('allowed_categories, balance')
        .eq('id', user.id)
        .maybeSingle();
    final raw = (row?['allowed_categories'] as List<dynamic>?) ?? const [];
    return ChildMoneyContext(
      saldo: (row?['balance'] as num?)?.toDouble() ?? 0.0,
      categoriasPermitidas: raw.map((e) => e.toString()).toList(growable: false),
    );
  }

  /// Anota um gasto (status `pending`), debitando o cofrinho na hora, como o
  /// app já faz.
  ///
  /// Ordem: confere o saldo → debita → grava a transação. Se a gravação
  /// falhar, devolve o débito. Se o débito falhar, NÃO credita nada
  /// (correção do bug do DECISOES 8: antes o `catch` creditava sempre).
  ///
  /// [descricao]: o painel novo passa o nome da categoria ("Comida", D19).
  /// [needOrWant]: gravado em `need_or_want`; se a coluna não existir no banco,
  /// grava de novo sem ela, registra no log e segue (D11).
  Future<SaveMoneyResult> registrarGasto({
    required double valor,
    required String categoriaId,
    required String descricao,
    NeedOrWant? needOrWant,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return SaveMoneyResult.semSessao;
    final amount = _arredondar(valor);
    if (amount <= 0) return SaveMoneyResult.valorInvalido;

    var debitado = false;
    try {
      final saldo = await _lerSaldo(user.id);
      if (saldo < amount) return SaveMoneyResult.saldoInsuficiente;

      await _gravarSaldo(user.id, saldo - amount);
      debitado = true;

      final linha = <String, dynamic>{
        'child_id': user.id,
        'amount': amount,
        'type': 'expense',
        'description': descricao.trim().isEmpty ? 'Gasto' : descricao.trim(),
        'category': categoriaId,
        'status': 'pending',
        'date': DateTime.now().toIso8601String(),
        if (needOrWant != null) 'need_or_want': needOrWant.db,
      };
      await _inserirComFallback(linha);
      return SaveMoneyResult.ok;
    } catch (e, st) {
      debugLogDataLoad('Registrar gasto', e, st);
      if (debitado) {
        try {
          final atual = await _lerSaldo(user.id);
          await _gravarSaldo(user.id, atual + amount);
        } catch (e2) {
          // Risco já existente (saldo não atômico, D9): registra para o dono.
          appLog('❌ Registrar gasto: falhou ao devolver R\$ $amount ao saldo: $e2');
        }
      }
      return SaveMoneyResult.erro;
    }
  }

  /// Registra dinheiro ganho EXATAMENTE como a tela antiga
  /// (`expenses_screen.dart`, `_saveTransactionToDatabase` com type income):
  /// `type: 'income'`, `status: 'approved'`, `category` = origem
  /// ("Mesada", "Presente", "Trabalho", "Outros"), sem mexer no saldo.
  ///
  /// ATENÇÃO (D18 "sem mudar a regra"): a regra antiga NÃO soma o ganho ao
  /// `children.balance` (o trigger de saldo só age em UPDATE de status).
  /// Ver pendência no PLANO.md.
  Future<SaveMoneyResult> registrarGanho({
    required double valor,
    required String origemId,
    required String descricao,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return SaveMoneyResult.semSessao;
    final amount = _arredondar(valor);
    if (amount <= 0) return SaveMoneyResult.valorInvalido;
    try {
      await _client.from('transactions').insert({
        'child_id': user.id,
        'amount': amount,
        'type': 'income',
        'description': descricao.trim().isEmpty ? origemId : descricao.trim(),
        'category': origemId,
        'status': 'approved',
        'date': DateTime.now().toIso8601String(),
      });
      return SaveMoneyResult.ok;
    } catch (e, st) {
      debugLogDataLoad('Registrar ganho', e, st);
      return SaveMoneyResult.erro;
    }
  }

  /// Gastos da criança com `date >= desde` (data local), sem os rejeitados
  /// (correção D8: rejeitado não entra nas somas).
  ///
  /// Para Gastos com comparação mensal, peça desde o menor entre o dia 1 do
  /// mês anterior e 90 dias atrás, e filtre o período na tela.
  ///
  /// Se a coluna `need_or_want` não existir, repete a consulta sem ela e
  /// devolve `temNeedOrWant: false`. Lança exceção nas demais falhas.
  Future<ChildExpensesResult> listarGastos({required DateTime desde}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const ChildExpensesResult(gastos: [], temNeedOrWant: false);
    }
    final desdeIso = _dataIso(desde);
    try {
      final rows = await _consultaGastos(user.id, desdeIso, '$_colunasGasto, need_or_want');
      return ChildExpensesResult(gastos: rows.map(_gastoDe).toList(), temNeedOrWant: true);
    } catch (e) {
      if (!_ehColunaNeedOrWantAusente(e)) rethrow;
      appLog('⚠️ Gastos: coluna need_or_want ausente (migration não aplicada). '
          'Lendo sem ela. $e');
      final rows = await _consultaGastos(user.id, desdeIso, _colunasGasto);
      return ChildExpensesResult(gastos: rows.map(_gastoDe).toList(), temNeedOrWant: false);
    }
  }

  // ── internos ──

  Future<List<Map<String, dynamic>>> _consultaGastos(
    String childId,
    String desdeIso,
    String colunas,
  ) async {
    final rows = await _client
        .from('transactions')
        .select(colunas)
        .eq('child_id', childId)
        .eq('type', 'expense')
        .neq('status', 'rejected')
        .gte('date', desdeIso)
        .order('date', ascending: false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  ChildExpense _gastoDe(Map<String, dynamic> row) {
    final dataRaw = row['date'];
    final data = dataRaw is String ? DateTime.tryParse(dataRaw) : null;
    final criadoRaw = row['created_at'];
    final criado = criadoRaw is String ? DateTime.tryParse(criadoRaw)?.toLocal() : null;
    final d = data ?? criado ?? DateTime.now();
    return ChildExpense(
      id: (row['id'] ?? '').toString(),
      descricao: (row['description'] ?? '').toString(),
      valor: (row['amount'] as num?)?.toDouble() ?? 0.0,
      categoriaId: (row['category'] ?? 'other').toString(),
      data: DateTime(d.year, d.month, d.day),
      status: (row['status'] ?? 'pending').toString(),
      criadoEm: criado,
      needOrWant: NeedOrWant.fromDb(row['need_or_want']),
    );
  }

  Future<void> _inserirComFallback(Map<String, dynamic> linha) async {
    try {
      await _client.from('transactions').insert(linha);
    } catch (e) {
      if (!linha.containsKey('need_or_want') || !_ehColunaNeedOrWantAusente(e)) {
        rethrow;
      }
      appLog('⚠️ Gasto: coluna need_or_want ausente (migration não aplicada). '
          'Gravando sem ela. $e');
      final semColuna = Map<String, dynamic>.of(linha)..remove('need_or_want');
      await _client.from('transactions').insert(semColuna);
    }
  }

  /// PostgREST devolve `PGRST204` ("Could not find the 'need_or_want' column")
  /// no insert e `42703` (undefined_column) ou `PGRST100`/`PGRST200` no select.
  /// Por segurança, exige também que a mensagem cite a coluna.
  bool _ehColunaNeedOrWantAusente(Object e) {
    if (e is! PostgrestException) return false;
    final texto = '${e.message} ${e.details ?? ''} ${e.hint ?? ''}';
    return texto.contains('need_or_want');
  }

  Future<double> _lerSaldo(String childId) async {
    final row = await _client
        .from('children')
        .select('balance')
        .eq('id', childId)
        .maybeSingle();
    return (row?['balance'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> _gravarSaldo(String childId, double novo) async {
    await _client
        .from('children')
        .update({'balance': _arredondar(novo)})
        .eq('id', childId);
  }

  static double _arredondar(double v) => double.parse(v.toStringAsFixed(2));

  static String _dataIso(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dia';
  }
}
