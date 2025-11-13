enum UserRole { parent, child }

class ParentAccount {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  const ParentAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'role': 'parent',
        'email': email,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  static ParentAccount fromMap(String id, Map<String, dynamic> map) =>
      ParentAccount(
        id: id,
        email: map['email'] as String,
        name: map['name'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class ChildAccount {
  final String id;
  final String parentId;
  final String displayName;
  final int age;
  final DateTime createdAt;

  const ChildAccount({
    required this.id,
    required this.parentId,
    required this.displayName,
    required this.age,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'role': 'child',
        'parentId': parentId,
        'displayName': displayName,
        'age': age,
        'createdAt': createdAt.toIso8601String(),
      };

  static ChildAccount fromMap(String id, Map<String, dynamic> map) =>
      ChildAccount(
        id: id,
        parentId: map['parentId'] as String,
        displayName: map['displayName'] as String,
        age: (map['age'] as num).toInt(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

/*
Supabase schema (proposta):

tables:
- users (id, role: 'parent' | 'child', email, name, created_at)

- children (id, parent_id, display_name, age, created_at)

- progress (id, child_id, type: 'lesson' | 'mission', ref_id, status, updated_at)

- transactions (id, child_id, kind: 'transaction' | 'goal', amount, category, created_at, meta...)

- goals (id, child_id, name, emoji, target_amount, current_amount, status, created_at, ...)

RLS (Row Level Security) policies:
- Parent pode ler/gravar seus filhos e progresso.
- Child pode ler/gravar somente seus próprios registros vinculados ao parent_id.
*/
