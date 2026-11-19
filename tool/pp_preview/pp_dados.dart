// Dados de exemplo do harness de pixel perfect (VINGADORES / PIXEL PERFECT).
// Os mesmos números e textos dos mockups aprovados (*.dc.html): Ana, nível 4,
// R$ 86,50, meta bicicleta R$ 140, missões, gastos de novembro etc.
//
// Não é código de produção: só alimenta tool/pp_preview/main.dart.

import 'package:flutter/widgets.dart';

import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/data/child/child_achievements_repository.dart';
import 'package:lummy/data/child/child_goals_repository.dart';
import 'package:lummy/data/child/child_missions_repository.dart';
import 'package:lummy/data/child/child_transactions_repository.dart';
import 'package:lummy/models/goal.dart';

/// "Agora" fixo dos mockups: quinta, 19 de novembro de 2026, 15h.
final DateTime ppAgora = DateTime(2026, 11, 19, 15);

/// Perfil da Ana sem Supabase.
class PpPerfil extends ChildProfileController {
  @override
  String get nome => 'Ana';

  @override
  String get primeiroNome => 'Ana';

  @override
  String get inicial => 'A';

  @override
  int get level => 4;

  @override
  int get totalPoints => 3320;

  @override
  int get xpNoNivel => 320;

  @override
  double get progressoNivel => 320 / ChildProfileController.xpPorNivel;

  @override
  bool get carregado => true;

  @override
  bool get nivelConhecido => true;
}

/// Cor do tema fixa (escolhida pela URL), sem SharedPreferences.
class PpCores extends ChildThemeColorController {
  PpCores(this._fixa);

  final ChildThemeColor _fixa;

  @override
  ChildThemeColor get opcao => _fixa;

  @override
  Color get tema => _fixa.color;
}

const List<DailyMissionItem> ppMissoes = [
  DailyMissionItem(
    missionId: 'm1',
    titulo: 'Assistir a uma aula de 3 min',
    pontos: 40,
    concluida: false,
  ),
  DailyMissionItem(
    missionId: 'm2',
    titulo: 'Esperar 1 dia antes de comprar algo',
    pontos: 60,
    concluida: false,
  ),
  DailyMissionItem(
    missionId: 'm3',
    titulo: 'Conferir o saldo da semana',
    pontos: 20,
    concluida: false,
  ),
  DailyMissionItem(
    missionId: 'm4',
    titulo: 'Anotar um gasto de hoje',
    pontos: 30,
    concluida: true,
  ),
  DailyMissionItem(
    missionId: 'm5',
    titulo: r'Guardar R$ 2 no cofrinho',
    pontos: 50,
    concluida: true,
  ),
];

/// 5 dias seguidos; "Hoje" é a sexta (6ª coluna), sábado ainda não chegou.
final ChildStreak ppSequencia = ChildStreak(
  diasSeguidos: 5,
  hojeFeito: false,
  semana: [
    for (var i = 0; i < 7; i++)
      StreakDay(
        dia: DateTime(2026, 11, 15 + i),
        estado: i < 5
            ? StreakDayState.feito
            : (i == 5 ? StreakDayState.hojePendente : StreakDayState.futuro),
        ehHoje: i == 5,
      ),
  ],
);

const List<ChildAchievement> ppConquistas = [
  ChildAchievement(id: 'a1', titulo: 'Primeira meta', emoji: '🏆', concluida: true),
  ChildAchievement(id: 'a2', titulo: '5 dias seguidos', emoji: '🔥', concluida: true),
  ChildAchievement(id: 'a3', titulo: 'Poupador', emoji: '⭐', concluida: true),
];

const double ppSaldo = 86.5;

final Goal ppMeta = Goal(
  id: 'g1',
  name: 'Bicicleta nova',
  emoji: '🚲',
  targetAmount: 140,
  currentAmount: ppSaldo,
  createdDate: DateTime(2026, 10, 1),
);

final ChildGoalState ppEstadoMeta = ChildGoalState(saldo: ppSaldo, atual: ppMeta);

final List<Goal> ppConcluidas = [
  Goal(
    id: 'c1',
    name: 'Fone de ouvido',
    emoji: '🎧',
    targetAmount: 80,
    currentAmount: 80,
    status: GoalStatus.completed,
    createdDate: DateTime(2026, 7, 20),
    completedDate: DateTime(2026, 9, 12),
  ),
  Goal(
    id: 'c2',
    name: 'Jogo novo',
    emoji: '🎮',
    targetAmount: 60,
    currentAmount: 60,
    status: GoalStatus.completed,
    createdDate: DateTime(2026, 5, 20),
    completedDate: DateTime(2026, 7, 8),
  ),
  Goal(
    id: 'c3',
    name: 'Bola de futebol',
    emoji: '⚽',
    targetAmount: 45,
    currentAmount: 45,
    status: GoalStatus.completed,
    createdDate: DateTime(2026, 4, 2),
    completedDate: DateTime(2026, 5, 3),
  ),
];

ChildExpense _gasto(
  String id,
  String descricao,
  double valor,
  String categoria,
  DateTime quando,
  NeedOrWant marca,
) {
  return ChildExpense(
    id: id,
    descricao: descricao,
    valor: valor,
    categoriaId: categoria,
    data: DateTime(quando.year, quando.month, quando.day),
    status: 'approved',
    criadoEm: quando,
    needOrWant: marca,
  );
}

/// Gastos do mockup (mais novo primeiro). Novembro soma R$ 42,30 (Comida
/// 18,50; Jogos 12,00; Diversão 7,80; Roupas 4,00; precisava 17,00 e queria
/// 25,30); outubro soma R$ 48,50 (comparação "R$ 6,20 a menos").
final List<ChildExpense> ppGastos = [
  _gasto('e1', 'Lanche na escola', 4.5, 'food', DateTime(2026, 11, 19, 12), NeedOrWant.need),
  _gasto('e2', 'Sorvete', 5, 'food', DateTime(2026, 11, 19, 10), NeedOrWant.want),
  _gasto('e3', 'Skin no jogo', 12, 'games', DateTime(2026, 11, 18, 17), NeedOrWant.want),
  _gasto('e4', 'Ingresso do cinema', 7.8, 'entertainment', DateTime(2026, 11, 16, 18), NeedOrWant.want),
  _gasto('e5', 'Meia nova', 4, 'clothes', DateTime(2026, 11, 16, 9), NeedOrWant.need),
  _gasto('e6', 'Almoço', 8.5, 'food', DateTime(2026, 11, 10, 12), NeedOrWant.need),
  _gasto('e7', 'Bala', 0.5, 'food', DateTime(2026, 11, 5, 16), NeedOrWant.want),
  _gasto('e8', 'Lanche', 48.5, 'food', DateTime(2026, 10, 15, 12), NeedOrWant.need),
];
