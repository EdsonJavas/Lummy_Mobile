enum GoalStatus { ongoing, completed }

class Goal {
  final String id;
  final String name;
  final String emoji;
  final double targetAmount;
  double currentAmount;
  final GoalStatus status;
  final DateTime createdDate;
  final DateTime? completedDate;
  final String description;

  Goal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.status = GoalStatus.ongoing,
    required this.createdDate,
    this.completedDate,
    this.description = '',
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  Goal copyWith({
    String? id,
    String? name,
    String? emoji,
    double? targetAmount,
    double? currentAmount,
    GoalStatus? status,
    DateTime? createdDate,
    DateTime? completedDate,
    String? description,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      completedDate: completedDate ?? this.completedDate,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'status': status.name,
      'createdDate': createdDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'description': description,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'] ?? 0.0,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.ongoing,
      ),
      createdDate: DateTime.parse(json['createdDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      description: json['description'] ?? '',
    );
  }
}
