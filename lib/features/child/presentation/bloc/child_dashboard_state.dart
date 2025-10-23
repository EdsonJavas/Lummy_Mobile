import 'package:equatable/equatable.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/goal_entity.dart';
import '../../../../domain/entities/achievement_entity.dart';

class ChildDashboardState extends Equatable {
  final bool isLoading;
  final double balance;
  final List<TransactionEntity> recentTransactions;
  final GoalEntity? currentGoal;
  final List<AchievementEntity> achievements;
  final String? error;
  final Map<String, double> categorySpending; // Gastos por categoria
  final double weeklyChange; // Mudança semanal no saldo

  const ChildDashboardState({
    this.isLoading = false,
    this.balance = 0.0,
    this.recentTransactions = const [],
    this.currentGoal,
    this.achievements = const [],
    this.error,
    this.categorySpending = const {},
    this.weeklyChange = 0.0,
  });

  ChildDashboardState copyWith({
    bool? isLoading,
    double? balance,
    List<TransactionEntity>? recentTransactions,
    GoalEntity? currentGoal,
    List<AchievementEntity>? achievements,
    String? error,
    Map<String, double>? categorySpending,
    double? weeklyChange,
  }) {
    return ChildDashboardState(
      isLoading: isLoading ?? this.isLoading,
      balance: balance ?? this.balance,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      currentGoal: currentGoal ?? this.currentGoal,
      achievements: achievements ?? this.achievements,
      error: error,
      categorySpending: categorySpending ?? this.categorySpending,
      weeklyChange: weeklyChange ?? this.weeklyChange,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    balance,
    recentTransactions,
    currentGoal,
    achievements,
    error,
    categorySpending,
    weeklyChange,
  ];
}
