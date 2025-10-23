import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/notification_entity.dart';

class ParentDashboardState extends Equatable {
  final bool isLoading;
  final List<ChildEntity> children;
  final ChildEntity? selectedChild;
  final List<TransactionEntity> pendingApprovals;
  final List<NotificationEntity> notifications;
  final Map<String, double> totalSpendingByChild;
  final String? error;

  const ParentDashboardState({
    this.isLoading = false,
    this.children = const [],
    this.selectedChild,
    this.pendingApprovals = const [],
    this.notifications = const [],
    this.totalSpendingByChild = const {},
    this.error,
  });

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;

  int get pendingApprovalsCount => pendingApprovals.length;

  ParentDashboardState copyWith({
    bool? isLoading,
    List<ChildEntity>? children,
    ChildEntity? selectedChild,
    List<TransactionEntity>? pendingApprovals,
    List<NotificationEntity>? notifications,
    Map<String, double>? totalSpendingByChild,
    String? error,
  }) {
    return ParentDashboardState(
      isLoading: isLoading ?? this.isLoading,
      children: children ?? this.children,
      selectedChild: selectedChild,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      notifications: notifications ?? this.notifications,
      totalSpendingByChild: totalSpendingByChild ?? this.totalSpendingByChild,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    children,
    selectedChild,
    pendingApprovals,
    notifications,
    totalSpendingByChild,
    error,
  ];
}
