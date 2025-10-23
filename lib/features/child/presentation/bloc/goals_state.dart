import 'package:equatable/equatable.dart';
import '../../../../domain/entities/goal_entity.dart';

class GoalsState extends Equatable {
  final bool isLoading;
  final List<GoalEntity> goals;
  final GoalEntity? selectedGoal;
  final String? error;

  const GoalsState({
    this.isLoading = false,
    this.goals = const [],
    this.selectedGoal,
    this.error,
  });

  List<GoalEntity> get activeGoals => goals.where((g) => g.isActive).toList();

  List<GoalEntity> get completedGoals =>
      goals.where((g) => g.isCompleted).toList();

  GoalsState copyWith({
    bool? isLoading,
    List<GoalEntity>? goals,
    GoalEntity? selectedGoal,
    String? error,
  }) {
    return GoalsState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      selectedGoal: selectedGoal,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, goals, selectedGoal, error];
}
