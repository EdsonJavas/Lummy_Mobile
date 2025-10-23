import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/goal_entity.dart';
import 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  GoalsCubit() : super(const GoalsState());

  // Carregar metas
  Future<void> loadGoals(String userId) async {
    emit(state.copyWith(isLoading: true));

    try {
      // TODO: Buscar do backend
      await Future.delayed(const Duration(seconds: 1));

      final goals = [
        GoalEntity(
          id: '1',
          userId: userId,
          name: 'Bicicleta Nova',
          emoji: '🚲',
          targetAmount: 200.0,
          currentAmount: 127.50,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          deadline: DateTime.now().add(const Duration(days: 30)),
          description: 'Uma bicicleta mountain bike azul',
        ),
        GoalEntity(
          id: '2',
          userId: userId,
          name: 'Videogame',
          emoji: '🎮',
          targetAmount: 500.0,
          currentAmount: 50.0,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          deadline: DateTime.now().add(const Duration(days: 60)),
          description: 'PlayStation 5',
        ),
      ];

      emit(state.copyWith(isLoading: false, goals: goals));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Criar nova meta
  Future<void> createGoal(GoalEntity goal) async {
    final updatedGoals = [...state.goals, goal];

    emit(state.copyWith(goals: updatedGoals));

    // TODO: Salvar no backend
  }

  // Atualizar meta
  Future<void> updateGoal(GoalEntity goal) async {
    final updatedGoals = state.goals.map((g) {
      return g.id == goal.id ? goal : g;
    }).toList();

    emit(state.copyWith(goals: updatedGoals, selectedGoal: goal));

    // TODO: Atualizar no backend
  }

  // Adicionar progresso à meta
  Future<void> addProgressToGoal(String goalId, double amount) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final newAmount = goal.currentAmount + amount;
    final updatedGoal = goal.copyWith(currentAmount: newAmount);

    // Verificar se completou
    if (updatedGoal.progress >= 1.0) {
      final completedGoal = updatedGoal.copyWith(
        status: GoalStatus.completed,
        completedAt: DateTime.now(),
      );
      await updateGoal(completedGoal);
    } else {
      await updateGoal(updatedGoal);
    }
  }

  // Cancelar meta
  Future<void> cancelGoal(String goalId) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final cancelledGoal = goal.copyWith(status: GoalStatus.cancelled);

    await updateGoal(cancelledGoal);
  }

  // Selecionar meta
  void selectGoal(GoalEntity goal) {
    emit(state.copyWith(selectedGoal: goal));
  }

  // Limpar seleção
  void clearSelection() {
    emit(state.copyWith(selectedGoal: null));
  }
}
