import 'package:equatable/equatable.dart';

enum UserRole { parent, child }

enum Gender { male, female, other }

// Classe base de usuário
abstract class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final String? profileImage;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, email, name, role, createdAt, profileImage];
}

// Entidade do Responsável (Parent)
class ParentEntity extends UserEntity {
  final String cpf;
  final List<String> childrenIds;

  const ParentEntity({
    required super.id,
    required super.email,
    required super.name,
    required this.cpf,
    required super.createdAt,
    this.childrenIds = const [],
    super.profileImage,
  }) : super(role: UserRole.parent);

  ParentEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? cpf,
    List<String>? childrenIds,
    DateTime? createdAt,
    String? profileImage,
  }) {
    return ParentEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      childrenIds: childrenIds ?? this.childrenIds,
      createdAt: createdAt ?? this.createdAt,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'name': name,
    'cpf': cpf,
    'role': 'parent',
    'childrenIds': childrenIds,
    'createdAt': createdAt.toIso8601String(),
    'profileImage': profileImage,
  };

  factory ParentEntity.fromMap(Map<String, dynamic> map) {
    return ParentEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      cpf: map['cpf'] as String,
      childrenIds: map['childrenIds'] != null
          ? List<String>.from(map['childrenIds'] as List)
          : [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      profileImage: map['profileImage'] as String?,
    );
  }

  @override
  List<Object?> get props => [...super.props, cpf, childrenIds];
}

// Entidade da Criança (Child)
class ChildEntity extends UserEntity {
  final String parentId;
  final int age;
  final Gender gender;
  final String cpf;
  final double balance;
  final double allowance; // Mesada
  final Map<String, double> limits; // Limites por categoria
  final bool requiresApproval; // Se transações precisam de aprovação
  final List<String> allowedCategories;

  const ChildEntity({
    required super.id,
    required super.email,
    required super.name,
    required this.parentId,
    required this.age,
    required this.gender,
    required this.cpf,
    required super.createdAt,
    this.balance = 0.0,
    this.allowance = 0.0,
    this.limits = const {},
    this.requiresApproval = true,
    this.allowedCategories = const [],
    super.profileImage,
  }) : super(role: UserRole.child);

  ChildEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? parentId,
    int? age,
    Gender? gender,
    String? cpf,
    DateTime? createdAt,
    double? balance,
    double? allowance,
    Map<String, double>? limits,
    bool? requiresApproval,
    List<String>? allowedCategories,
    String? profileImage,
  }) {
    return ChildEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      cpf: cpf ?? this.cpf,
      createdAt: createdAt ?? this.createdAt,
      balance: balance ?? this.balance,
      allowance: allowance ?? this.allowance,
      limits: limits ?? this.limits,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      allowedCategories: allowedCategories ?? this.allowedCategories,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'name': name,
    'parentId': parentId,
    'age': age,
    'gender': gender.name,
    'cpf': cpf,
    'role': 'child',
    'balance': balance,
    'allowance': allowance,
    'limits': limits,
    'requiresApproval': requiresApproval,
    'allowedCategories': allowedCategories,
    'createdAt': createdAt.toIso8601String(),
    'profileImage': profileImage,
  };

  factory ChildEntity.fromMap(Map<String, dynamic> map) {
    return ChildEntity(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      parentId: map['parentId'] as String,
      age: map['age'] as int,
      gender: Gender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => Gender.other,
      ),
      cpf: map['cpf'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      allowance: (map['allowance'] as num?)?.toDouble() ?? 0.0,
      limits: map['limits'] != null
          ? Map<String, double>.from(map['limits'] as Map)
          : {},
      requiresApproval: map['requiresApproval'] as bool? ?? true,
      allowedCategories: map['allowedCategories'] != null
          ? List<String>.from(map['allowedCategories'] as List)
          : [],
      profileImage: map['profileImage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    parentId,
    age,
    gender,
    cpf,
    balance,
    allowance,
    limits,
    requiresApproval,
    allowedCategories,
  ];
}
