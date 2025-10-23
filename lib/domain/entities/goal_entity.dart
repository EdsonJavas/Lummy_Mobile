import 'package:equatable/equatable.dart';

enum GoalStatus {
  active, // Meta ativa
  completed, // Meta concluída
  cancelled, // Meta cancelada
}

class GoalEntity extends Equatable {
  final String id;
  final String userId; // ID da criança
  final String? parentId; // ID do responsável que criou (se aplicável)
  final String name;
  final String emoji;
  final double targetAmount;
  final double currentAmount;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? deadline; // Prazo para atingir a meta
  final String description;
  final bool isShared; // Se é uma meta compartilhada com o responsável
  final List<String> milestones; // Marcos intermediários

  const GoalEntity({
    required this.id,
    required this.userId,
    this.parentId,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.status = GoalStatus.active,
    required this.createdAt,
    this.completedAt,
    this.deadline,
    this.description = '',
    this.isShared = false,
    this.milestones = const [],
  });

  // Getters calculados
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  int get progressPercentage => (progress * 100).toInt();

  bool get isActive => status == GoalStatus.active;
  bool get isCompleted => status == GoalStatus.completed;
  bool get isCancelled => status == GoalStatus.cancelled;

  bool get hasDeadline => deadline != null;

  int? get daysUntilDeadline {
    if (deadline == null) return null;
    final now = DateTime.now();
    return deadline!.difference(now).inDays;
  }

  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isCompleted;
  }

  GoalEntity copyWith({
    String? id,
    String? userId,
    String? parentId,
    String? name,
    String? emoji,
    double? targetAmount,
    double? currentAmount,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? deadline,
    String? description,
    bool? isShared,
    List<String>? milestones,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      isShared: isShared ?? this.isShared,
      milestones: milestones ?? this.milestones,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'parentId': parentId,
    'name': name,
    'emoji': emoji,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'description': description,
    'isShared': isShared,
    'milestones': milestones,
  };

  factory GoalEntity.fromMap(Map<String, dynamic> map) {
    return GoalEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      parentId: map['parentId'] as String?,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GoalStatus.active,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      description: map['description'] as String? ?? '',
      isShared: map['isShared'] as bool? ?? false,
      milestones: map['milestones'] != null
          ? List<String>.from(map['milestones'] as List)
          : [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    parentId,
    name,
    emoji,
    targetAmount,
    currentAmount,
    status,
    createdAt,
    completedAt,
    deadline,
    description,
    isShared,
    milestones,
  ];
}
