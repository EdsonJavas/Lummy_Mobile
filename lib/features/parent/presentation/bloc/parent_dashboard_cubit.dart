import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/notification_entity.dart';
import 'parent_dashboard_state.dart';

class ParentDashboardCubit extends Cubit<ParentDashboardState> {
  ParentDashboardCubit() : super(const ParentDashboardState());

  // Carregar dashboard do responsável
  Future<void> loadDashboard(String parentId) async {
    emit(state.copyWith(isLoading: true));

    try {
      // TODO: Buscar do backend
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final children = _getMockChildren(parentId);
      final pendingApprovals = _getMockPendingApprovals();
      final notifications = _getMockNotifications(parentId);
      final spending = _calculateSpending(children);
      final monthlyTrend = _getMockMonthlyTrend();
      final categoryBreakdown = _getMockCategoryBreakdown();
      final goalSummaries = _getMockGoalSummaries(children);

      emit(
        state.copyWith(
          isLoading: false,
          children: children,
          pendingApprovals: pendingApprovals,
          notifications: notifications,
          totalSpendingByChild: spending,
          walletBalance: 820.0,
          monthIncomeTotal:
              monthlyTrend.isNotEmpty ? monthlyTrend.last.income : 0,
          monthExpenseTotal:
              monthlyTrend.isNotEmpty ? monthlyTrend.last.expense : 0,
          monthlyTrend: monthlyTrend,
          categoryBreakdown: categoryBreakdown,
          goalSummaries: goalSummaries,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Aprovar transação
  Future<void> approveTransaction(String transactionId) async {
    final updatedApprovals = state.pendingApprovals
        .where((t) => t.id != transactionId)
        .toList();

    emit(state.copyWith(pendingApprovals: updatedApprovals));

    // TODO: Atualizar no backend
  }

  // Rejeitar transação
  Future<void> rejectTransaction(String transactionId, String reason) async {
    final updatedApprovals = state.pendingApprovals
        .where((t) => t.id != transactionId)
        .toList();

    emit(state.copyWith(pendingApprovals: updatedApprovals));

    // TODO: Atualizar no backend
  }

  // Transferir dinheiro para criança
  Future<void> transferToChild(String childId, double amount) async {
    final childIndex = state.children.indexWhere((c) => c.id == childId);

    if (childIndex != -1) {
      final child = state.children[childIndex];
      final updatedChild = child.copyWith(balance: child.balance + amount);

      final updatedChildren = List<ChildEntity>.from(state.children);
      updatedChildren[childIndex] = updatedChild;

      emit(
        state.copyWith(
          children: updatedChildren,
          walletBalance: (state.walletBalance - amount).clamp(
            0,
            double.infinity,
          ),
        ),
      );

      // TODO: Salvar no backend
    }
  }

  Future<void> distributeAmount(double amount) async {
    if (amount <= 0 || state.children.isEmpty) {
      return;
    }

    final count = state.children.length;
    final valuePerChild =
        double.parse((amount / count).toStringAsFixed(2));
    double remaining = amount;

    final updatedChildren = <ChildEntity>[];

    for (var i = 0; i < count; i++) {
      final child = state.children[i];
      final valueToAdd =
          i == count - 1 ? double.parse(remaining.toStringAsFixed(2)) : valuePerChild;
      remaining -= valueToAdd;
      updatedChildren.add(
        child.copyWith(
          balance: child.balance + valueToAdd,
        ),
      );
    }

    emit(
      state.copyWith(
        children: updatedChildren,
        walletBalance: (state.walletBalance - amount).clamp(
          0,
          double.infinity,
        ),
      ),
    );

    // TODO: Salvar no backend
  }

  // Configurar mesada
  Future<void> setAllowance(String childId, double amount) async {
    final childIndex = state.children.indexWhere((c) => c.id == childId);

    if (childIndex != -1) {
      final child = state.children[childIndex];
      final updatedChild = child.copyWith(allowance: amount);

      final updatedChildren = List<ChildEntity>.from(state.children);
      updatedChildren[childIndex] = updatedChild;

      emit(state.copyWith(children: updatedChildren));

      // TODO: Salvar no backend
    }
  }

  // Selecionar criança
  void selectChild(ChildEntity child) {
    emit(state.copyWith(selectedChild: child));
  }

  // Marcar notificação como lida
  Future<void> markNotificationAsRead(String notificationId) async {
    final updatedNotifications = state.notifications.map((n) {
      return n.id == notificationId ? n.copyWith(isRead: true) : n;
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications));

    // TODO: Atualizar no backend
  }

  // Mock data
  List<ChildEntity> _getMockChildren(String parentId) {
    return [
      ChildEntity(
        id: 'child_1',
        email: 'edson@example.com',
        name: 'Edson Jr',
        parentId: parentId,
        age: 12,
        gender: Gender.male,
        cpf: '12345678901',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        balance: 127.50,
        allowance: 50.0,
        requiresApproval: true,
      ),
      ChildEntity(
        id: 'child_2',
        email: 'maria@example.com',
        name: 'Maria',
        parentId: parentId,
        age: 10,
        gender: Gender.female,
        cpf: '98765432109',
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        balance: 85.00,
        allowance: 40.0,
        requiresApproval: true,
      ),
    ];
  }

  List<TransactionEntity> _getMockPendingApprovals() {
    return [
      TransactionEntity(
        id: 'pending_1',
        userId: 'child_1',
        description: 'Novo jogo',
        amount: 60.0,
        type: TransactionType.expense,
        status: TransactionStatus.pending,
        category: 'Jogos',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<NotificationEntity> _getMockNotifications(String parentId) {
    return [
      NotificationEntity(
        id: 'notif_1',
        userId: parentId,
        fromUserId: 'child_1',
        type: NotificationType.requestPending,
        title: 'Nova solicitação',
        message: 'Edson Jr solicitou R\$ 60,00 para comprar um jogo',
        createdAt: DateTime.now(),
      ),
    ];
  }

  Map<String, double> _calculateSpending(List<ChildEntity> children) {
    // Mock - seria calculado com base nas transações reais
    return {'child_1': 150.0, 'child_2': 80.0};
  }

  List<MonthlySpendingPoint> _getMockMonthlyTrend() {
    return const [
      MonthlySpendingPoint(
        month: 'Junho',
        monthLabel: 'Jun',
        income: 1200,
        expense: 840,
      ),
      MonthlySpendingPoint(
        month: 'Julho',
        monthLabel: 'Jul',
        income: 1350,
        expense: 910,
      ),
      MonthlySpendingPoint(
        month: 'Agosto',
        monthLabel: 'Ago',
        income: 1450,
        expense: 980,
      ),
      MonthlySpendingPoint(
        month: 'Setembro',
        monthLabel: 'Set',
        income: 1500,
        expense: 1020,
      ),
    ];
  }

  List<CategorySpendingData> _getMockCategoryBreakdown() {
    return const [
      CategorySpendingData(
        category: 'Educação',
        value: 320,
        percentage: 32,
        color: Color(AppConstants.primaryBlue),
      ),
      CategorySpendingData(
        category: 'Lazer',
        value: 240,
        percentage: 24,
        color: Color(AppConstants.accentOrange),
      ),
      CategorySpendingData(
        category: 'Jogos e apps',
        value: 200,
        percentage: 20,
        color: Color(AppConstants.purple),
      ),
      CategorySpendingData(
        category: 'Transporte',
        value: 160,
        percentage: 16,
        color: Color(AppConstants.successGreen),
      ),
      CategorySpendingData(
        category: 'Outros',
        value: 80,
        percentage: 8,
        color: Color(AppConstants.textSecondary),
      ),
    ];
  }

  List<ChildGoalSummary> _getMockGoalSummaries(List<ChildEntity> children) {
    if (children.isEmpty) return const [];

    return [
      ChildGoalSummary(
        childId: children[0].id,
        childName: children[0].name,
        completedGoals: 2,
        totalGoals: 4,
        averageProgress: 0.68,
      ),
      if (children.length > 1)
        ChildGoalSummary(
          childId: children[1].id,
          childName: children[1].name,
          completedGoals: 1,
          totalGoals: 3,
          averageProgress: 0.54,
        ),
    ];
  }
}
