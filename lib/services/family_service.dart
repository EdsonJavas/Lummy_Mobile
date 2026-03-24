import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/user_entity.dart';

/// Resultado da checagem de e-mail nas tabelas `responsaveis` / `children`.
enum EmailRegistrationStatus {
  available,
  usedByParent,
  usedByChild,
  /// RPC indisponível ou erro de rede — o app pode seguir e confiar no Auth.
  checkFailed,
}

/// Resultado da checagem de CPF nas tabelas `responsaveis` / `children`.
enum CpfRegistrationStatus {
  available,
  usedByParent,
  usedByChild,
  checkFailed,
}

class FamilyService {
  final SupabaseClient _supabase;

  FamilyService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  static String normalizeSignupEmail(String email) =>
      email.trim().toLowerCase();

  /// Apenas dígitos, para comparar CPF com ou sem máscara.
  static String normalizeSignupCpf(String cpf) =>
      cpf.replaceAll(RegExp(r'[^0-9]'), '');

  /// Usa a RPC `email_registered_kind` (migration no repositório). Se não existir, retorna checkFailed.
  Future<EmailRegistrationStatus> getEmailRegistrationStatus(
    String email,
  ) async {
    final normalized = normalizeSignupEmail(email);
    if (normalized.isEmpty) return EmailRegistrationStatus.checkFailed;
    try {
      final res = await _supabase.rpc(
        'email_registered_kind',
        params: {'check_email': normalized},
      );
      final s = (res as String?)?.toLowerCase().trim() ?? 'none';
      if (s == 'parent') return EmailRegistrationStatus.usedByParent;
      if (s == 'child') return EmailRegistrationStatus.usedByChild;
      return EmailRegistrationStatus.available;
    } catch (e) {
      debugPrint('getEmailRegistrationStatus (RPC email_registered_kind): $e');
      return EmailRegistrationStatus.checkFailed;
    }
  }

  /// Quantidade de dependentes já cadastrados para o responsável.
  Future<int> countChildrenForParent(String responsavelId) async {
    try {
      final response = await _supabase
          .from('children')
          .select('id')
          .eq('responsavel_id', responsavelId);
      return response.length;
    } catch (e, st) {
      debugPrint('countChildrenForParent: $e\n$st');
      return 0;
    }
  }

  /// Usa a RPC `cpf_registered_kind` (migration no repositório). Se não existir, retorna checkFailed.
  Future<CpfRegistrationStatus> getCpfRegistrationStatus(String cpf) async {
    final normalized = normalizeSignupCpf(cpf);
    if (normalized.length != 11) return CpfRegistrationStatus.checkFailed;
    try {
      final res = await _supabase.rpc(
        'cpf_registered_kind',
        params: {'check_cpf': normalized},
      );
      final s = (res as String?)?.toLowerCase().trim() ?? 'none';
      if (s == 'parent') return CpfRegistrationStatus.usedByParent;
      if (s == 'child') return CpfRegistrationStatus.usedByChild;
      return CpfRegistrationStatus.available;
    } catch (e) {
      debugPrint('getCpfRegistrationStatus (RPC cpf_registered_kind): $e');
      return CpfRegistrationStatus.checkFailed;
    }
  }

  // Salva dados adicionais do responsável na tabela responsaveis
  // A autenticação já foi feita pelo AuthRepository
  Future<String> createResponsavelData({
    required String userId, // ID do usuário do Supabase Auth
    required String nome,
    required String cpf,
    required String email,
  }) async {
    debugPrint('🔄 Criando registro do responsável $userId...');

    // Tentar inserir imediatamente - na maioria dos casos funciona
    int attempts = 0;
    const int maxQuickAttempts = 3; // Apenas 3 tentativas rápidas
    const int quickDelayMs = 300; // 300ms entre tentativas

    while (attempts < maxQuickAttempts) {
      try {
        final response = await _supabase
            .from('responsaveis')
            .insert({
              'id': userId,
              'nome': nome,
              'cpf': cpf,
              'email': email,
              'balance': 2300.00,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        debugPrint('✅ Responsável $userId criado com sucesso!');
        return response['id'].toString();
      } catch (e) {
        // Log detalhado do erro
        debugPrint(
          '❌ Erro na tentativa ${attempts + 1} de criar responsável $userId:',
        );
        debugPrint('   Tipo: ${e.runtimeType}');
        if (e is PostgrestException) {
          debugPrint('   Código: ${e.code}');
          debugPrint('   Mensagem: ${e.message}');
          debugPrint('   Detalhes: ${e.details}');
          debugPrint('   Hint: ${e.hint}');
        } else {
          debugPrint('   Erro completo: $e');
        }

        // Verificar se é erro de foreign key constraint
        final isForeignKeyError =
            (e is PostgrestException && e.code == '23503') ||
            e.toString().contains('foreign key constraint') ||
            e.toString().contains('23503') ||
            e.toString().contains('is not present in table');

        if (isForeignKeyError && attempts < maxQuickAttempts - 1) {
          attempts++;
          debugPrint(
            '⏳ Tentativa $attempts de $maxQuickAttempts para responsável $userId. Aguardando ${quickDelayMs}ms...',
          );
          await Future.delayed(const Duration(milliseconds: quickDelayMs));
          continue;
        } else if (e.toString().contains('duplicate') ||
            e.toString().contains('unique')) {
          // Se já existe, retorna o ID existente
          debugPrint(
            'ℹ️ Responsável $userId já existe, buscando ID existente.',
          );
          final existing = await _supabase
              .from('responsaveis')
              .select('id')
              .eq('id', userId)
              .maybeSingle();
          if (existing != null) {
            return existing['id'].toString();
          }
          rethrow;
        } else if (isForeignKeyError) {
          // Se ainda falhar após tentativas rápidas, aguardar um pouco mais e tentar
          debugPrint(
            '⚠️ Tentativas rápidas falharam. Aguardando mais tempo e tentando novamente...',
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          // Tentar mais algumas vezes antes de desistir
          for (int i = 0; i < 5; i++) {
            try {
              final response = await _supabase
                  .from('responsaveis')
                  .insert({
                    'id': userId,
                    'nome': nome,
                    'cpf': cpf,
                    'email': email,
                    'balance': 2300.00,
                    'created_at': DateTime.now().toIso8601String(),
                  })
                  .select()
                  .single();
              debugPrint(
                '✅ Responsável $userId criado com sucesso após aguardar!',
              );
              return response['id'].toString();
            } catch (e) {
              if (i < 4) {
                debugPrint(
                  '⏳ Tentativa adicional ${i + 1}/5 para responsável $userId. Aguardando 500ms...',
                );
                await Future.delayed(const Duration(milliseconds: 500));
              } else {
                debugPrint(
                  '❌ Erro persistente ao criar responsável $userId: $e',
                );
                // Processar em background como último recurso
                _createResponsavelDataInBackground(userId, nome, cpf, email);
                return userId;
              }
            }
          }
          return userId;
        } else {
          debugPrint('❌ Erro ao criar responsável $userId: $e');
          rethrow; // Outro tipo de erro, rethrow imediatamente
        }
      }
    }
    return userId; // Nunca deve chegar aqui, mas retorna userId como fallback
  }

  // Processa criação do responsável em background (sem bloquear o fluxo)
  Future<void> _createResponsavelDataInBackground(
    String userId,
    String nome,
    String cpf,
    String email,
  ) async {
    debugPrint(
      '🔄 Iniciando processamento em background para responsável $userId...',
    );
    int attempts = 0;
    const int maxAttempts = 15;
    Duration delay = const Duration(milliseconds: 1000);

    while (attempts < maxAttempts) {
      try {
        await _supabase
            .from('responsaveis')
            .insert({
              'id': userId,
              'nome': nome,
              'cpf': cpf,
              'email': email,
              'balance': 2300.00,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        debugPrint(
          '✅ Responsável $userId criado com sucesso em background na tentativa ${attempts + 1}!',
        );
        return;
      } catch (e) {
        attempts++;
        final isForeignKeyError =
            (e is PostgrestException && e.code == '23503') ||
            e.toString().contains('foreign key constraint') ||
            e.toString().contains('23503');

        if (isForeignKeyError && attempts < maxAttempts) {
          debugPrint(
            '⏳ Tentativa $attempts/$maxAttempts em background para responsável $userId. Aguardando ${delay.inMilliseconds}ms...',
          );
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * 1.2).round());
          continue;
        } else if (e.toString().contains('duplicate') ||
            e.toString().contains('unique')) {
          debugPrint('ℹ️ Responsável $userId já existe em background.');
          return;
        } else {
          debugPrint(
            '❌ Erro ao criar responsável $userId em background (tentativa $attempts/$maxAttempts): $e',
          );
          if (attempts >= maxAttempts) {
            debugPrint(
              '❌ FALHA FINAL: Não foi possível criar responsável $userId após $maxAttempts tentativas em background.',
            );
            return; // Não rethrow em background para não quebrar o app
          }
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * 1.2).round());
        }
      }
    }
    debugPrint(
      '❌ FALHA FINAL: Não foi possível criar responsável $userId após $maxAttempts tentativas em background.',
    );
  }

  // Salva dados adicionais da criança na tabela children
  // A autenticação já foi feita pelo AuthRepository
  Future<void> addChildData({
    required String childUserId, // ID do usuário do Supabase Auth da criança
    required String responsavelId,
    required String nome,
    required String cpf,
    required String email,
    required int idade,
    required String sexo,
  }) async {
    debugPrint('🔄 Criando registro da criança $childUserId...');

    // Tentar inserir imediatamente - na maioria dos casos funciona
    int attempts = 0;
    const int maxQuickAttempts = 3; // Apenas 3 tentativas rápidas
    const int quickDelayMs = 300; // 300ms entre tentativas

    while (attempts < maxQuickAttempts) {
      try {
        await _supabase.from('children').insert({
          'id': childUserId,
          'responsavel_id': responsavelId,
          'nome': nome,
          'cpf': cpf,
          'email': email,
          'idade': idade,
          'sexo': sexo,
          'balance': 0.00,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Criança $childUserId criada com sucesso!');
        return; // Sucesso, sai do loop
      } catch (e) {
        // Log detalhado do erro
        debugPrint(
          '❌ Erro na tentativa ${attempts + 1} de criar criança $childUserId:',
        );
        debugPrint('   Tipo: ${e.runtimeType}');
        if (e is PostgrestException) {
          debugPrint('   Código: ${e.code}');
          debugPrint('   Mensagem: ${e.message}');
          debugPrint('   Detalhes: ${e.details}');
          debugPrint('   Hint: ${e.hint}');
        } else {
          debugPrint('   Erro completo: $e');
        }

        // Verificar se é erro de foreign key constraint
        final isForeignKeyError =
            (e is PostgrestException && e.code == '23503') ||
            e.toString().contains('foreign key constraint') ||
            e.toString().contains('23503') ||
            e.toString().contains('is not present in table');

        if (isForeignKeyError && attempts < maxQuickAttempts - 1) {
          attempts++;
          debugPrint(
            '⏳ Tentativa $attempts de $maxQuickAttempts para criança $childUserId. Aguardando ${quickDelayMs}ms...',
          );
          await Future.delayed(const Duration(milliseconds: quickDelayMs));
          continue;
        } else if (isForeignKeyError) {
          // Se ainda falhar após tentativas rápidas, aguardar um pouco mais e tentar
          debugPrint(
            '⚠️ Tentativas rápidas falharam. Aguardando mais tempo e tentando novamente...',
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          // Tentar mais algumas vezes antes de desistir
          for (int i = 0; i < 5; i++) {
            try {
              await _supabase.from('children').insert({
                'id': childUserId,
                'responsavel_id': responsavelId,
                'nome': nome,
                'cpf': cpf,
                'email': email,
                'idade': idade,
                'sexo': sexo,
                'balance': 0.00,
                'created_at': DateTime.now().toIso8601String(),
              });
              debugPrint(
                '✅ Criança $childUserId criada com sucesso após aguardar!',
              );
              return;
            } catch (e) {
              if (i < 4) {
                debugPrint(
                  '⏳ Tentativa adicional ${i + 1}/5 para criança $childUserId. Aguardando 500ms...',
                );
                await Future.delayed(const Duration(milliseconds: 500));
              } else {
                debugPrint(
                  '❌ Erro persistente ao criar criança $childUserId: $e',
                );
                // Processar em background como último recurso
                _addChildDataInBackground(
                  childUserId: childUserId,
                  responsavelId: responsavelId,
                  nome: nome,
                  cpf: cpf,
                  email: email,
                  idade: idade,
                  sexo: sexo,
                );
                return;
              }
            }
          }
          return;
        } else {
          debugPrint('❌ Erro ao criar criança $childUserId: $e');
          rethrow; // Outro tipo de erro, rethrow imediatamente
        }
      }
    }
  }

  // Processa criação da criança em background (sem bloquear o fluxo)
  Future<void> _addChildDataInBackground({
    required String childUserId,
    required String responsavelId,
    required String nome,
    required String cpf,
    required String email,
    required int idade,
    required String sexo,
  }) async {
    debugPrint(
      '🔄 Iniciando processamento em background para criança $childUserId...',
    );
    int attempts = 0;
    const int maxAttempts = 15;
    Duration delay = const Duration(milliseconds: 1000);

    while (attempts < maxAttempts) {
      try {
        await _supabase.from('children').insert({
          'id': childUserId,
          'responsavel_id': responsavelId,
          'nome': nome,
          'cpf': cpf,
          'email': email,
          'idade': idade,
          'sexo': sexo,
          'balance': 0.00,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint(
          '✅ Criança $childUserId criada com sucesso em background na tentativa ${attempts + 1}!',
        );
        return;
      } catch (e) {
        attempts++;
        final isForeignKeyError =
            (e is PostgrestException && e.code == '23503') ||
            e.toString().contains('foreign key constraint') ||
            e.toString().contains('23503');

        if (isForeignKeyError && attempts < maxAttempts) {
          debugPrint(
            '⏳ Tentativa $attempts/$maxAttempts em background para criança $childUserId. Aguardando ${delay.inMilliseconds}ms...',
          );
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * 1.2).round());
          continue;
        } else if (e.toString().contains('duplicate') ||
            e.toString().contains('unique')) {
          debugPrint('ℹ️ Criança $childUserId já existe em background.');
          return;
        } else {
          debugPrint(
            '❌ Erro ao criar criança $childUserId em background (tentativa $attempts/$maxAttempts): $e',
          );
          if (attempts >= maxAttempts) {
            debugPrint(
              '❌ FALHA FINAL: Não foi possível criar criança $childUserId após $maxAttempts tentativas em background.',
            );
            return; // Não rethrow em background para não quebrar o app
          }
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * 1.2).round());
        }
      }
    }
    debugPrint(
      '❌ FALHA FINAL: Não foi possível criar criança $childUserId após $maxAttempts tentativas em background.',
    );
  }

  Future<UserEntity?> fetchUserProfile(String authUserId) async {
    try {
      debugPrint('🔍 Buscando perfil do usuário: $authUserId');
      
      // Verificar se o usuário está autenticado
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        debugPrint('⚠️ Nenhum usuário autenticado no Supabase');
        return null;
      }
      
      if (currentUser.id != authUserId) {
        debugPrint('⚠️ ID do usuário autenticado (${currentUser.id}) não corresponde ao ID buscado ($authUserId)');
      }

      debugPrint('🔍 Tentando buscar como responsável...');
      final parent = await _getParentById(authUserId);
      if (parent != null) {
        debugPrint('✅ Perfil encontrado: Responsável - ${parent.name}');
        return parent;
      }

      debugPrint('🔍 Tentando buscar como criança...');
      final child = await _getChildById(authUserId);
      if (child != null) {
        debugPrint('✅ Perfil encontrado: Criança - ${child.name}');
        return child;
      }
      
      debugPrint('⚠️ Perfil não encontrado nas tabelas responsaveis ou children');
      debugPrint('   Isso pode significar que:');
      debugPrint('   1. O usuário ainda não completou o cadastro');
      debugPrint('   2. Há problema de RLS (Row Level Security) no Supabase');
      debugPrint('   3. O registro não foi criado após o signup');
      
      return null;
    } catch (e, stack) {
      debugPrint('❌ Erro ao buscar perfil do usuário $authUserId: $e');
      debugPrint('   Tipo do erro: ${e.runtimeType}');
      if (e is PostgrestException) {
        debugPrint('   Código: ${e.code}');
        debugPrint('   Mensagem: ${e.message}');
        debugPrint('   Detalhes: ${e.details}');
        debugPrint('   Hint: ${e.hint}');
      }
      debugPrint('   Stack trace: $stack');
      rethrow;
    }
  }

  Future<ParentEntity?> _getParentById(String parentId) async {
    final response = await _supabase
        .from('responsaveis')
        .select('id, nome, cpf, email, created_at')
        .eq('id', parentId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final childrenRows = await _supabase
        .from('children')
        .select('id')
        .eq('responsavel_id', parentId);

    final childrenIds = childrenRows
        .whereType<Map<String, dynamic>>()
        .map((row) => row['id'] as String)
        .toList();

    return ParentEntity(
      id: response['id'] as String,
      email: (response['email'] ?? '') as String,
      name: (response['nome'] ?? '') as String,
      cpf: (response['cpf'] ?? '') as String,
      childrenIds: childrenIds,
      createdAt: _parseDate(response['created_at']),
      profileImage: null, // Coluna não existe no banco de dados
    );
  }

  Future<ChildEntity?> _getChildById(String childId) async {
    final response = await _supabase
        .from('children')
        .select('''
          id,
          responsavel_id,
          nome,
          cpf,
          email,
          idade,
          sexo,
          balance,
          allowance,
          requires_approval,
          limits,
          allowed_categories,
          created_at
          ''')
        .eq('id', childId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ChildEntity(
      id: response['id'] as String,
      email: (response['email'] ?? '') as String,
      name: (response['nome'] ?? '') as String,
      parentId: (response['responsavel_id'] ?? '') as String,
      age: (response['idade'] as int?) ?? 0,
      gender: _mapGender(response['sexo'] as String?),
      cpf: (response['cpf'] ?? '') as String,
      createdAt: _parseDate(response['created_at']),
      balance: (response['balance'] as num?)?.toDouble() ?? 0.0,
      allowance: (response['allowance'] as num?)?.toDouble() ?? 0.0,
      limits: _parseLimits(response['limits']),
      requiresApproval: response['requires_approval'] as bool? ?? true,
      allowedCategories:
          _parseAllowedCategories(response['allowed_categories']),
      profileImage: null, // Coluna não existe no banco de dados
    );
  }

  Gender _mapGender(String? value) {
    final normalized = value?.toLowerCase().trim();
    switch (normalized) {
      case 'masculino':
      case 'male':
      case 'm':
        return Gender.male;
      case 'feminino':
      case 'female':
      case 'f':
        return Gender.female;
      default:
        return Gender.other;
    }
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

Map<String, double> _parseLimits(dynamic raw) {
  if (raw == null) return const {};
  if (raw is Map) {
    return raw.map((key, value) {
      final numeric = value is num ? value.toDouble() : 0.0;
      return MapEntry(key.toString(), numeric);
    });
  }
  return const {};
}

List<String> _parseAllowedCategories(dynamic raw) {
  if (raw == null) return const [];
  if (raw is List) {
    return raw.map((e) => e.toString()).toList();
  }
  return const [];
}
