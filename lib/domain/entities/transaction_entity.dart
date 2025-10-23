import 'package:equatable/equatable.dart';

enum TransactionType {
  income, // Entrada de dinheiro
  expense, // Gasto
  allowance, // Mesada recebida
  reward, // Recompensa recebida
}

enum TransactionStatus {
  pending, // Aguardando aprovação
  approved, // Aprovada pelo responsável
  rejected, // Rejeitada pelo responsável
  completed, // Concluída
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId; // ID da criança
  final String? parentId; // ID do responsável (se aplicável)
  final String description;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String category;
  final DateTime date;
  final DateTime createdAt;
  final String? rejectionReason;
  final Map<String, dynamic>? metadata; // Dados extras

  const TransactionEntity({
    required this.id,
    required this.userId,
    this.parentId,
    required this.description,
    required this.amount,
    required this.type,
    required this.status,
    required this.category,
    required this.date,
    required this.createdAt,
    this.rejectionReason,
    this.metadata,
  });

  bool get isPending => status == TransactionStatus.pending;
  bool get isApproved => status == TransactionStatus.approved;
  bool get isRejected => status == TransactionStatus.rejected;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isIncome =>
      type == TransactionType.income ||
      type == TransactionType.allowance ||
      type == TransactionType.reward;
  bool get isExpense => type == TransactionType.expense;

  TransactionEntity copyWith({
    String? id,
    String? userId,
    String? parentId,
    String? description,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    String? category,
    DateTime? date,
    DateTime? createdAt,
    String? rejectionReason,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'parentId': parentId,
    'description': description,
    'amount': amount,
    'type': type.name,
    'status': status.name,
    'category': category,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'rejectionReason': rejectionReason,
    'metadata': metadata,
  };

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      parentId: map['parentId'] as String?,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.completed,
      ),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      rejectionReason: map['rejectionReason'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    parentId,
    description,
    amount,
    type,
    status,
    category,
    date,
    createdAt,
    rejectionReason,
    metadata,
  ];
}
