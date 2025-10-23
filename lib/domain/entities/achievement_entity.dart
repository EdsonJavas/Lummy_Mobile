import 'package:equatable/equatable.dart';

enum AchievementCategory {
  savings, // Economia
  spending, // Gastos
  goals, // Metas
  learning, // Aprendizado
  consistency, // Consistência
  milestones, // Marcos importantes
}

class AchievementEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final bool isCompleted;
  final DateTime? earnedAt;
  final int points; // Pontos conquistados
  final Map<String, dynamic>? metadata; // Dados extras sobre a conquista

  const AchievementEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    this.isCompleted = false,
    this.earnedAt,
    this.points = 0,
    this.metadata,
  });

  AchievementEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? emoji,
    AchievementCategory? category,
    bool? isCompleted,
    DateTime? earnedAt,
    int? points,
    Map<String, dynamic>? metadata,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      earnedAt: earnedAt ?? this.earnedAt,
      points: points ?? this.points,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'emoji': emoji,
    'category': category.name,
    'isCompleted': isCompleted,
    'earnedAt': earnedAt?.toIso8601String(),
    'points': points,
    'metadata': metadata,
  };

  factory AchievementEntity.fromMap(Map<String, dynamic> map) {
    return AchievementEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AchievementCategory.milestones,
      ),
      isCompleted: map['isCompleted'] as bool? ?? false,
      earnedAt: map['earnedAt'] != null
          ? DateTime.parse(map['earnedAt'] as String)
          : null,
      points: map['points'] as int? ?? 0,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    emoji,
    category,
    isCompleted,
    earnedAt,
    points,
    metadata,
  ];
}

// Conquistas pré-definidas
class PredefinedAchievements {
  static List<AchievementEntity> getDefaultAchievements(String userId) {
    return [
      AchievementEntity(
        id: 'first_saving',
        userId: userId,
        title: 'Primeira Economia',
        description: 'Você guardou seu primeiro dinheiro!',
        emoji: '🥇',
        category: AchievementCategory.savings,
        points: 10,
      ),
      AchievementEntity(
        id: 'expense_control',
        userId: userId,
        title: 'Controle de Gastos',
        description: 'Anotou gastos por 7 dias seguidos',
        emoji: '📊',
        category: AchievementCategory.consistency,
        points: 20,
      ),
      AchievementEntity(
        id: 'goal_reached',
        userId: userId,
        title: 'Meta Alcançada',
        description: 'Complete sua primeira meta de economia',
        emoji: '🎯',
        category: AchievementCategory.goals,
        points: 50,
      ),
      AchievementEntity(
        id: 'wise_spender',
        userId: userId,
        title: 'Gastador Consciente',
        description: 'Economizou mais de 50% da sua mesada',
        emoji: '🧠',
        category: AchievementCategory.spending,
        points: 30,
      ),
      AchievementEntity(
        id: 'early_learner',
        userId: userId,
        title: 'Aprendiz Dedicado',
        description: 'Completou 5 lições sobre educação financeira',
        emoji: '📚',
        category: AchievementCategory.learning,
        points: 25,
      ),
      AchievementEntity(
        id: 'savings_master',
        userId: userId,
        title: 'Mestre das Economias',
        description: 'Economizou mais de R\$ 500,00',
        emoji: '💰',
        category: AchievementCategory.milestones,
        points: 100,
      ),
    ];
  }
}
