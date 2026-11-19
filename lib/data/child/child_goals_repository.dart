import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/utils/network_errors.dart';
import 'package:lummy/models/goal.dart';
import 'package:lummy/utils/ensure_child_record.dart';

/// Meta atual já sincronizada com o cofrinho.
class ChildGoalState {
  const ChildGoalState({required this.saldo, this.atual, this.ultimaConcluida});

  /// `children.balance` lido na mesma carga.
  final double saldo;

  /// Meta em andamento (`status = 'ongoing'`), já com `currentAmount` igual
  /// ao saldo limitado ao alvo. Nula se não há meta em andamento (inclusive
  /// se a sincronização acabou de concluí-la).
  final Goal? atual;

  /// Meta concluída mais recente (para o estado "Você conquistou {nome}!").
  /// Só é lida quando [atual] é nula.
  final Goal? ultimaConcluida;

  /// Progresso 0..1 da meta atual (saldo / alvo). 0 sem meta.
  double get progresso {
    final m = atual;
    if (m == null || m.targetAmount <= 0) return 0;
    return (saldo / m.targetAmount).clamp(0.0, 1.0);
  }

  /// Quanto falta para a meta atual. 0 sem meta.
  double get falta {
    final m = atual;
    if (m == null) return 0;
    final f = m.targetAmount - saldo;
    return f < 0 ? 0 : double.parse(f.toStringAsFixed(2));
  }
}

/// Resultado de [ChildGoalsRepository.criarMeta].
enum CriarMetaResultado {
  criada,

  /// Já existe meta `ongoing` (uma por vez; índice único no banco).
  jaExisteMeta,

  /// O registro em `children` não existe e não pôde ser criado.
  semRegistro,

  semSessao,
  dadosInvalidos,
  erro,
}

/// Acesso a `goals` pela criança. Status vigente: `ongoing` / `completed`
/// (D8; `'active'` é de `allowance_distributions` e de arquivos antigos).
///
/// Regra do produto (CONTEXTO D1): o progresso da meta é o saldo do cofrinho.
/// Não existe "adicionar progresso".
class ChildGoalsRepository {
  ChildGoalsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Lê saldo + meta em andamento, sincroniza a meta com o saldo e, se não
  /// houver meta em andamento, lê a última concluída.
  ///
  /// Sincronização (mesma regra de `goals_screen.dart`/`home_page.dart`):
  /// `current_amount = clamp(saldo, 0, alvo)`; se `saldo >= alvo`, a meta
  /// vira `completed` com `completed_at = agora`. Diferença: só grava se o
  /// valor mudou (evita o ciclo UPDATE → realtime → recarga, RELATORIO 7.5).
  ///
  /// Lança exceção se não conseguir ler o saldo ou a meta.
  Future<ChildGoalState> carregarMetaSincronizada() async {
    final user = _client.auth.currentUser;
    if (user == null) return const ChildGoalState(saldo: 0);

    final childRow = await _client
        .from('children')
        .select('balance')
        .eq('id', user.id)
        .maybeSingle();
    final saldo = (childRow?['balance'] as num?)?.toDouble() ?? 0.0;

    var atual = await buscarMetaAtual();
    if (atual != null) {
      atual = await _sincronizar(user.id, atual, saldo);
    }
    Goal? concluida;
    if (atual == null) {
      concluida = await buscarUltimaConcluida();
    }
    return ChildGoalState(saldo: saldo, atual: atual, ultimaConcluida: concluida);
  }

  /// Meta `ongoing` da criança, sem sincronizar. Lança exceção em falha.
  Future<Goal?> buscarMetaAtual() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('goals')
        .select('*')
        .eq('child_id', user.id)
        .eq('status', 'ongoing')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : goalFromRow(row);
  }

  /// Última meta concluída. Lança exceção em falha.
  Future<Goal?> buscarUltimaConcluida() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('goals')
        .select('*')
        .eq('child_id', user.id)
        .eq('status', 'completed')
        .order('completed_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : goalFromRow(row);
  }

  /// Metas concluídas, da mais recente para a mais antiga ("Metas conquistadas").
  /// Lança exceção em falha.
  Future<List<Goal>> listarConcluidas() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final rows = await _client
        .from('goals')
        .select('*')
        .eq('child_id', user.id)
        .eq('status', 'completed')
        .order('completed_at', ascending: false);
    return rows.map<Goal>(goalFromRow).toList();
  }

  /// Cria a meta (único ponto de criação: Home e Metas usam este método,
  /// via `abrirCriacaoDeMeta`). Corrige o bug do DECISOES 8 (a Home não
  /// gravava). Não lança exceção.
  Future<CriarMetaResultado> criarMeta({
    required String nome,
    required String emoji,
    required double valorAlvo,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return CriarMetaResultado.semSessao;
    final nomeLimpo = nome.trim();
    if (nomeLimpo.isEmpty || valorAlvo <= 0) return CriarMetaResultado.dadosInvalidos;

    try {
      final existe = await EnsureChildRecord.ensureChildExists();
      if (!existe) return CriarMetaResultado.semRegistro;

      final emAndamento = await _client
          .from('goals')
          .select('id')
          .eq('child_id', user.id)
          .eq('status', 'ongoing')
          .limit(1)
          .maybeSingle();
      if (emAndamento != null) return CriarMetaResultado.jaExisteMeta;

      final emojiLimpo = emoji.trim().isEmpty ? '🎯' : emoji.trim();
      await _client.from('goals').insert({
        'child_id': user.id,
        'name': nomeLimpo,
        'emoji': emojiLimpo,
        'target_amount': double.parse(valorAlvo.toStringAsFixed(2)),
        'current_amount': 0.0,
        'status': 'ongoing',
        'description': '',
      });
      return CriarMetaResultado.criada;
    } on PostgrestException catch (e, st) {
      // 23505 = violou o índice único idx_goals_one_ongoing_per_child.
      if (e.code == '23505') return CriarMetaResultado.jaExisteMeta;
      debugLogDataLoad('Criar meta', e, st);
      return CriarMetaResultado.erro;
    } catch (e, st) {
      debugLogDataLoad('Criar meta', e, st);
      return CriarMetaResultado.erro;
    }
  }

  /// Exclui a meta ("Desistir da meta"). Lança exceção em falha.
  Future<void> excluirMeta(String goalId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('goals').delete().eq('id', goalId).eq('child_id', user.id);
  }

  /// Converte uma linha de `goals` no modelo [Goal].
  static Goal goalFromRow(Map<String, dynamic> row) {
    final target = (row['target_amount'] as num?)?.toDouble() ?? 0.0;
    final current = (row['current_amount'] as num?)?.toDouble() ?? 0.0;
    final criado = row['created_at'] is String
        ? DateTime.tryParse(row['created_at'] as String)?.toLocal()
        : null;
    final concluido = row['completed_at'] is String
        ? DateTime.tryParse(row['completed_at'] as String)?.toLocal()
        : null;
    return Goal(
      id: (row['id'] ?? '').toString(),
      name: (row['name'] ?? '').toString(),
      emoji: (row['emoji'] as String?) ?? '🎯',
      targetAmount: target,
      currentAmount: current > target && target > 0 ? target : current,
      status: row['status'] == 'completed' ? GoalStatus.completed : GoalStatus.ongoing,
      createdDate: criado ?? DateTime.now(),
      completedDate: concluido,
      description: (row['description'] as String?) ?? '',
    );
  }

  /// Devolve a meta atualizada, ou nula se ela foi concluída agora.
  Future<Goal?> _sincronizar(String childId, Goal meta, double saldo) async {
    final alvo = meta.targetAmount;
    if (alvo <= 0) return meta;
    try {
      if (saldo >= alvo) {
        await _client
            .from('goals')
            .update({
              'status': 'completed',
              'current_amount': alvo,
              'completed_at': DateTime.now().toIso8601String(),
            })
            .eq('id', meta.id)
            .eq('child_id', childId);
        return null;
      }
      final novo = double.parse(saldo.clamp(0.0, alvo).toStringAsFixed(2));
      if ((novo - meta.currentAmount).abs() >= 0.005) {
        await _client
            .from('goals')
            .update({'current_amount': novo})
            .eq('id', meta.id)
            .eq('child_id', childId);
      }
      return meta.copyWith(currentAmount: novo);
    } catch (e) {
      // Mesmo comportamento de hoje: falha de sincronização não esconde a meta.
      appLog('⚠️ Sincronizar meta com saldo: $e');
      final local = saldo.clamp(0.0, alvo).toDouble();
      return meta.copyWith(currentAmount: local);
    }
  }
}
