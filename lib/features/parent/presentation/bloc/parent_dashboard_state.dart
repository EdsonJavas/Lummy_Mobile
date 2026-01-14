import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/notification_entity.dart';

class ParentDashboardState extends Equatable {
  final bool isLoading;
  final String? parentName;
  final List<ChildEntity> children;
  final ChildEntity? selectedChild;
  final List<TransactionEntity> pendingApprovals;
  final List<NotificationEntity> notifications;
  final Map<String, double> totalSpendingByChild;
  final double walletBalance;
  final double monthIncomeTotal;
  final double monthExpenseTotal;
  final List<MonthlySpendingPoint> monthlyTrend;
  final List<CategorySpendingData> categoryBreakdown;
  final List<ChildGoalSummary> goalSummaries;
  final String? error;

  const ParentDashboardState({
    this.isLoading = false,
    this.parentName,
    this.children = const [],
    this.selectedChild,
    this.pendingApprovals = const [],
    this.notifications = const [],
    this.totalSpendingByChild = const {},
    this.walletBalance = 0,
    this.monthIncomeTotal = 0,
    this.monthExpenseTotal = 0,
    this.monthlyTrend = const [],
    this.categoryBreakdown = const [],
    this.goalSummaries = const [],
    this.error,
  });

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;

  int get pendingApprovalsCount => pendingApprovals.length;

  ParentDashboardState copyWith({
    bool? isLoading,
    String? parentName,
    List<ChildEntity>? children,
    ChildEntity? selectedChild,
    List<TransactionEntity>? pendingApprovals,
    List<NotificationEntity>? notifications,
    Map<String, double>? totalSpendingByChild,
    double? walletBalance,
    double? monthIncomeTotal,
    double? monthExpenseTotal,
    List<MonthlySpendingPoint>? monthlyTrend,
    List<CategorySpendingData>? categoryBreakdown,
    List<ChildGoalSummary>? goalSummaries,
    String? error,
  }) {
    return ParentDashboardState(
      isLoading: isLoading ?? this.isLoading,
      parentName: parentName ?? this.parentName,
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      notifications: notifications ?? this.notifications,
      totalSpendingByChild: totalSpendingByChild ?? this.totalSpendingByChild,
      walletBalance: walletBalance ?? this.walletBalance,
      monthIncomeTotal: monthIncomeTotal ?? this.monthIncomeTotal,
      monthExpenseTotal: monthExpenseTotal ?? this.monthExpenseTotal,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      goalSummaries: goalSummaries ?? this.goalSummaries,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    parentName,
    children,
    selectedChild,
    pendingApprovals,
    notifications,
    totalSpendingByChild,
    walletBalance,
    monthIncomeTotal,
    monthExpenseTotal,
    monthlyTrend,
    categoryBreakdown,
    goalSummaries,
    error,
  ];
}

class MonthlySpendingPoint extends Equatable {
  final String month;
  final String monthLabel;
  final double income;
  final double expense;

  const MonthlySpendingPoint({
    required this.month,
    required this.monthLabel,
    required this.income,
    required this.expense,
  });

  @override
  List<Object?> get props => [month, monthLabel, income, expense];
}

class CategorySpendingData extends Equatable {
  final String category;
  final double value;
  final double percentage;
  final Color color;

  const CategorySpendingData({
    required this.category,
    required this.value,
    required this.percentage,
    required this.color,
  });

  @override
  List<Object?> get props => [category, value, percentage, color];
}

class ChildGoalSummary extends Equatable {
  final String childId;
  final String childName;
  final int completedGoals;
  final int totalGoals;
  final double averageProgress;

  const ChildGoalSummary({
    required this.childId,
    required this.childName,
    required this.completedGoals,
    required this.totalGoals,
    required this.averageProgress,
  });

  @override
  List<Object?> get props => [
    childId,
    childName,
    completedGoals,
    totalGoals,
    averageProgress,
  ];
}
