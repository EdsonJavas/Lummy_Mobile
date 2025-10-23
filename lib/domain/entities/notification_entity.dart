import 'package:equatable/equatable.dart';

enum NotificationType {
  transactionApproved, // Transação aprovada
  transactionRejected, // Transação rejeitada
  allowanceReceived, // Mesada recebida
  goalCompleted, // Meta concluída
  goalMilestone, // Marco da meta atingido
  achievementEarned, // Conquista obtida
  requestPending, // Solicitação pendente (para responsável)
  reminder, // Lembrete
  other, // Outro
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId; // Destinatário
  final String? fromUserId; // Remetente (opcional)
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>?
  data; // Dados extras (ID da transação, meta, etc.)

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.fromUserId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? fromUserId,
    NotificationType? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fromUserId: fromUserId ?? this.fromUserId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'fromUserId': fromUserId,
    'type': type.name,
    'title': title,
    'message': message,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
    'data': data,
  };

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      fromUserId: map['fromUserId'] as String?,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.other,
      ),
      title: map['title'] as String,
      message: map['message'] as String,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      data: map['data'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    fromUserId,
    type,
    title,
    message,
    isRead,
    createdAt,
    data,
  ];
}
