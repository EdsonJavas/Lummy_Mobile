import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/goal_entity.dart';
import '../../../../domain/entities/achievement_entity.dart';
import 'child_dashboard_state.dart';

class ChildDashboardCubit extends Cubit<ChildDashboardState> {
  ChildDashboardCubit() : super(const ChildDashboardState());

  // Carregar dados do dashboard
  Future<void> loadDashboard(String userId) async {
    emit(state.copyWith(isLoading: true));

    try {
      // TODO: Buscar do backend
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final transactions = _getMockTransactions(userId);
      final goals = _getMockGoals(userId);
      final achievements = _getMockAchievements(userId);

      final categorySpending = _calculateCategorySpending(transactions);
      final weeklyChange = _calculateWeeklyChange(transactions);

      emit(
        state.copyWith(
          isLoading: false,
          balance: 127.50,
          recentTransactions: transactions.take(5).toList(),
          currentGoal: goals.isNotEmpty ? goals.first : null,
          achievements: achievements,
          categorySpending: categorySpending,
          weeklyChange: weeklyChange,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Adicionar transação
  Future<void> addTransaction(TransactionEntity transaction) async {
    final updatedTransactions = [transaction, ...state.recentTransactions];
    final newBalance = transaction.isIncome
        ? state.balance + transaction.amount
        : state.balance - transaction.amount;

    emit(
      state.copyWith(
        recentTransactions: updatedTransactions.take(5).toList(),
        balance: newBalance,
      ),
    );

    // Atualizar meta atual se houver
    if (state.currentGoal != null && transaction.isIncome) {
      final updatedGoal = state.currentGoal!.copyWith(
        currentAmount: state.currentGoal!.currentAmount + transaction.amount,
      );
      emit(state.copyWith(currentGoal: updatedGoal));

      // Verificar se meta foi completada
      if (updatedGoal.progress >= 1.0) {
        _completeGoal(updatedGoal);
      }
    }
  }

  // Completar meta
  void _completeGoal(GoalEntity goal) {
    final completedGoal = goal.copyWith(
      status: GoalStatus.completed,
      completedAt: DateTime.now(),
    );

    emit(state.copyWith(currentGoal: completedGoal));

    // Adicionar conquista de meta completada
    final goalAchievement = AchievementEntity(
      id: 'goal_${goal.id}',
      userId: goal.userId,
      title: 'Meta Alcançada!',
      description: 'Você completou a meta "${goal.name}"',
      emoji: '🎯',
      category: AchievementCategory.goals,
      isCompleted: true,
      earnedAt: DateTime.now(),
      points: 50,
    );

    final updatedAchievements = [goalAchievement, ...state.achievements];

    emit(state.copyWith(achievements: updatedAchievements));
  }

  // Atualizar meta
  void updateGoal(GoalEntity goal) {
    emit(state.copyWith(currentGoal: goal));
  }

  // Calcular gastos por categoria
  Map<String, double> _calculateCategorySpending(
    List<TransactionEntity> transactions,
  ) {
    final Map<String, double> spending = {};

    for (final transaction in transactions) {
      if (transaction.isExpense) {
        spending[transaction.category] =
            (spending[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return spending;
  }

  // Calcular mudança semanal
  double _calculateWeeklyChange(List<TransactionEntity> transactions) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    double change = 0.0;

    for (final transaction in transactions) {
      if (transaction.date.isAfter(weekAgo)) {
        if (transaction.isIncome) {
          change += transaction.amount;
        } else {
          change -= transaction.amount;
        }
      }
    }

    return change;
  }

  // Mock data
  List<TransactionEntity> _getMockTransactions(String userId) {
    return [
      TransactionEntity(
        id: '1',
        userId: userId,
        description: 'Mesada',
        amount: 50.0,
        type: TransactionType.allowance,
        status: TransactionStatus.completed,
        category: 'Mesada',
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionEntity(
        id: '2',
        userId: userId,
        description: 'Sorvete',
        amount: 10.0,
        type: TransactionType.expense,
        status: TransactionStatus.completed,
        category: 'Doces',
        date: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<GoalEntity> _getMockGoals(String userId) {
    return [
      GoalEntity(
        id: '1',
        userId: userId,
        name: 'Bicicleta Nova',
        emoji: '🚲',
        targetAmount: 200.0,
        currentAmount: 127.50,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        deadline: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }

  List<AchievementEntity> _getMockAchievements(String userId) {
    return PredefinedAchievements.getDefaultAchievements(userId);
  }
}
