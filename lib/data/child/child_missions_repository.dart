import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/utils/app_log.dart';

/// Uma missão do dia (RPC `select_daily_missions` + `daily_missions`).
class DailyMissionItem {
  const DailyMissionItem({
    required this.missionId,
    required this.titulo,
    required this.pontos,
    required this.concluida,
  });

  final String missionId;

  /// `missions.title`.
  final String titulo;

  /// `missions.points` (o "+N XP").
  final int pontos;

  /// `daily_missions.is_completed` de hoje.
  final bool concluida;
}

/// Estado de um dia na grade da sequência (Dom a Sáb da semana atual).
enum StreakDayState {
  /// Teve pelo menos 1 missão concluída (círculo laranja com check).
  feito,

  /// Hoje, ainda sem missão concluída (círculo tracejado laranja, "Hoje").
  hojePendente,

  /// Dia passado sem missão (não desenhado no mockup: `#EEF0F4`, proposta R1).
  perdido,

  /// Dia que ainda não chegou (`#EEF0F4`).
  futuro,
}

class StreakDay {
  const StreakDay({required this.dia, required this.estado, required this.ehHoje});

  final DateTime dia;
  final StreakDayState estado;

  /// A coluna de hoje troca o rótulo por "Hoje" (feito ou não).
  final bool ehHoje;
}

/// Sequência de dias com missão concluída (regra PROPOSTA DO RELATOR,
/// adotada pelo arquiteto): dias consecutivos com pelo menos 1 missão
/// concluída, terminando hoje (se hoje já tem) ou ontem (se hoje ainda não).
class ChildStreak {
  const ChildStreak({
    required this.diasSeguidos,
    required this.hojeFeito,
    required this.semana,
  });

  /// "5 dias seguidos". 0 = esconder pílula e seção (D7).
  final int diasSeguidos;

  /// Hoje já tem missão concluída.
  final bool hojeFeito;

  /// 7 dias, domingo a sábado da semana atual.
  final List<StreakDay> semana;
}

/// Missões diárias da criança. Mesma fonte que `DailyMissionsScreen`.
///
/// Concluir missão continua SÓ na `DailyMissionsScreen` (não duplicar a
/// lógica de pagamento de XP; ver riscos D9).
class ChildMissionsRepository {
  ChildMissionsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Missões de hoje, na ordem que o banco devolve (ordenar na tela: D16,
  /// pendentes primeiro). Atenção: a RPC sorteia e GRAVA 5 missões se o dia
  /// ainda não tem (mesmo efeito de abrir a tela de Missões hoje).
  /// Lança exceção em falha (a Home esconde a seção).
  Future<List<DailyMissionItem>> missoesDeHoje() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final hoje = _dataIso(DateTime.now());

    final result = await _client.rpc(
      'select_daily_missions',
      params: {'p_child_id': user.id, 'p_selected_date': hoje},
    );

    final status = await _client
        .from('daily_missions')
        .select('mission_id, is_completed')
        .eq('child_id', user.id)
        .eq('selected_date', hoje);
    final concluidas = <String, bool>{
      for (final r in status) (r['mission_id'] ?? '').toString(): r['is_completed'] == true,
    };

    final lista = <DailyMissionItem>[];
    if (result is List && result.isNotEmpty) {
      for (final m in result) {
        if (m is! Map) continue;
        final id = (m['mission_id'] ?? m['id'] ?? '').toString();
        lista.add(DailyMissionItem(
          missionId: id,
          titulo: (m['title'] ?? '').toString(),
          pontos: (m['points'] as num?)?.toInt() ?? 0,
          concluida: concluidas[id] ?? false,
        ));
      }
      return lista;
    }

    // Mesmo plano B da DailyMissionsScreen: lê direto as tabelas.
    if (concluidas.isEmpty) return const [];
    final missoes = await _client
        .from('missions')
        .select('id, title, points')
        .inFilter('id', concluidas.keys.toList());
    for (final m in missoes) {
      final id = (m['id'] ?? '').toString();
      lista.add(DailyMissionItem(
        missionId: id,
        titulo: (m['title'] ?? '').toString(),
        pontos: (m['points'] as num?)?.toInt() ?? 0,
        concluida: concluidas[id] ?? false,
      ));
    }
    return lista;
  }

  /// Sequência de dias. Nula se a consulta falhar (esconder, D7).
  Future<ChildStreak?> sequencia({DateTime? agora}) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final now = agora ?? DateTime.now();
    final hoje = DateTime(now.year, now.month, now.day);
    try {
      final rows = await _client
          .from('daily_missions')
          .select('selected_date')
          .eq('child_id', user.id)
          .eq('is_completed', true)
          .gte('selected_date', _dataIso(hoje.subtract(const Duration(days: 400))))
          // Mais recentes primeiro: o Supabase devolve no máximo 1000 linhas
          // (5 missões por dia), e o que importa são os dias mais novos.
          .order('selected_date', ascending: false);
      final dias = <String>{
        for (final r in rows) (r['selected_date'] ?? '').toString().split('T').first,
      };
      return calcularSequencia(dias, hoje);
    } catch (e) {
      appLog('⚠️ Sequência de dias: $e');
      return null;
    }
  }

  /// Cálculo puro (testável): [diasFeitos] em `yyyy-MM-dd`.
  static ChildStreak calcularSequencia(Set<String> diasFeitos, DateTime hoje) {
    bool feito(DateTime d) => diasFeitos.contains(_dataIso(d));
    DateTime menos(DateTime d, int n) => DateTime(d.year, d.month, d.day - n);

    final hojeFeito = feito(hoje);
    var cursor = hojeFeito ? hoje : menos(hoje, 1);
    var dias = 0;
    while (feito(cursor)) {
      dias++;
      cursor = menos(cursor, 1);
    }

    // DateTime.weekday: segunda = 1 ... domingo = 7. A semana começa no domingo.
    final domingo = menos(hoje, hoje.weekday % 7);
    final semana = <StreakDay>[];
    for (var i = 0; i < 7; i++) {
      final d = DateTime(domingo.year, domingo.month, domingo.day + i);
      final ehHoje = d == hoje;
      final StreakDayState estado;
      if (d.isAfter(hoje)) {
        estado = StreakDayState.futuro;
      } else if (feito(d)) {
        estado = StreakDayState.feito;
      } else if (ehHoje) {
        estado = StreakDayState.hojePendente;
      } else {
        estado = StreakDayState.perdido;
      }
      semana.add(StreakDay(dia: d, estado: estado, ehHoje: ehHoje));
    }
    return ChildStreak(diasSeguidos: dias, hojeFeito: hojeFeito, semana: semana);
  }

  static String _dataIso(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dia';
  }
}
