import 'package:supabase_flutter/supabase_flutter.dart';

/// Uma conquista da tabela `achievements` (modelo da criança: uma linha por
/// criança, com `is_completed`). Ver R5: o lado dos pais usa outro modelo.
class ChildAchievement {
  const ChildAchievement({
    required this.id,
    required this.titulo,
    required this.emoji,
    required this.concluida,
    this.concluidaEm,
  });

  final String id;

  /// `title`.
  final String titulo;

  /// `emoji` (o banco não tem ícone vetorial nem cor por conquista).
  final String emoji;

  /// `is_completed`.
  final bool concluida;

  /// `completed_date` em hora local.
  final DateTime? concluidaEm;
}

/// Resultado de [ChildAchievementsRepository.listar].
class ChildAchievementsResult {
  const ChildAchievementsResult(this.todas);

  /// Todas as linhas da criança, concluídas primeiro (mais recentes antes).
  final List<ChildAchievement> todas;

  /// Só as conquistadas, mais recentes primeiro (Home mostra até 4).
  List<ChildAchievement> get conquistadas =>
      todas.where((a) => a.concluida).toList(growable: false);

  /// "N" de "N de M".
  int get totalConquistadas => conquistadas.length;

  /// "M" de "N de M". Só tem sentido se o banco guarda também as ainda não
  /// conquistadas; por isso é nulo quando todas as linhas estão concluídas
  /// (aí esconda o "de M" ou o valor inteiro: D7, nada de número inventado).
  int? get totalPossivel =>
      todas.any((a) => !a.concluida) ? todas.length : null;
}

/// Leitura de `achievements` da criança logada (como `profile_page.dart`).
class ChildAchievementsRepository {
  ChildAchievementsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Lança exceção em falha (a tela esconde a seção/valor).
  Future<ChildAchievementsResult> listar() async {
    final user = _client.auth.currentUser;
    if (user == null) return const ChildAchievementsResult([]);
    final rows = await _client
        .from('achievements')
        .select('*') // igual a profile_page.dart: tolera colunas a mais/menos
        .eq('child_id', user.id)
        .order('completed_date', ascending: false);
    final lista = rows.map<ChildAchievement>((r) {
      final quando = r['completed_date'];
      return ChildAchievement(
        id: (r['id'] ?? '').toString(),
        titulo: (r['title'] ?? r['name'] ?? '').toString(),
        emoji: (r['emoji'] ?? '🏆').toString(),
        concluida: r['is_completed'] == true,
        concluidaEm: quando is String ? DateTime.tryParse(quando)?.toLocal() : null,
      );
    }).toList();
    lista.sort((a, b) {
      if (a.concluida != b.concluida) return a.concluida ? -1 : 1;
      final da = a.concluidaEm, db = b.concluidaEm;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return ChildAchievementsResult(lista);
  }
}
