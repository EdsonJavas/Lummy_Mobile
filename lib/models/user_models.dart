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
Firestore schema (proposta):

collections:
- users/{userId}
  role: 'parent' | 'child'
  email, name, createdAt

- users/{parentId}/children/{childId}
  displayName, age, createdAt

- users/{parentId}/children/{childId}/progress/{autoId}
  type: 'lesson' | 'mission'
  refId: string (lessonId ou missionId)
  status: 'not_started' | 'in_progress' | 'completed'
  updatedAt: timestamp

- users/{parentId}/children/{childId}/finance/{autoId}
  kind: 'transaction' | 'goal'
  amount, category, createdAt, meta...

security rules (alto nível):
- Parent pode ler/gravar seus filhos e progresso.
- Child pode ler/gravar somente seus próprios documentos sob parentId vinculado.
*/
