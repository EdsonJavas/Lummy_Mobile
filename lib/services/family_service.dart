import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/user_entity.dart';

class FamilyService {
  final SupabaseClient _supabase;

  FamilyService({SupabaseClient? supabase}) 
      : _supabase = supabase ?? Supabase.instance.client;

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
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        debugPrint('✅ Responsável $userId criado com sucesso!');
        return response['id'].toString();
      } catch (e) {
        // Log detalhado do erro
        debugPrint('❌ Erro na tentativa ${attempts + 1} de criar responsável $userId:');
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
          debugPrint('⏳ Tentativa $attempts de $maxQuickAttempts para responsável $userId. Aguardando ${quickDelayMs}ms...');
          await Future.delayed(const Duration(milliseconds: quickDelayMs));
          continue;
        } else if (e.toString().contains('duplicate') || e.toString().contains('unique')) {
          // Se já existe, retorna o ID existente
          debugPrint('ℹ️ Responsável $userId já existe, buscando ID existente.');
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
          debugPrint('⚠️ Tentativas rápidas falharam. Aguardando mais tempo e tentando novamente...');
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
                    'created_at': DateTime.now().toIso8601String(),
                  })
                  .select()
                  .single();
              debugPrint('✅ Responsável $userId criado com sucesso após aguardar!');
              return response['id'].toString();
            } catch (e) {
              if (i < 4) {
                debugPrint('⏳ Tentativa adicional ${i + 1}/5 para responsável $userId. Aguardando 500ms...');
                await Future.delayed(const Duration(milliseconds: 500));
              } else {
                debugPrint('❌ Erro persistente ao criar responsável $userId: $e');
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
    debugPrint('🔄 Iniciando processamento em background para responsável $userId...');
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
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        debugPrint('✅ Responsável $userId criado com sucesso em background na tentativa ${attempts + 1}!');
        return;
      } catch (e) {
        attempts++;
        final isForeignKeyError = 
            (e is PostgrestException && e.code == '23503') ||
            e.toString().contains('foreign key constraint') ||
            e.toString().contains('23503');
        
        if (isForeignKeyError && attempts < maxAttempts) {
          debugPrint('⏳ Tentativa $attempts/$maxAttempts em background para responsável $userId. Aguardando ${delay.inMilliseconds}ms...');
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * 1.2).round());
          continue;
        } else if (e.toString().contains('duplicate') || e.toString().contains('unique')) {
          debugPrint('ℹ️ Responsável $userId já existe em background.');
          return;
        } else {
          debugPrint('❌ Erro ao criar responsável $userId em background (tentativa $attempts/$maxAttempts): $e');
          if (attempts >= maxAttempts) {
            debugPrint('❌ FALHA FINAL: Não foi possível criar responsável $userId após $maxAttempts tentativas em background.');
            return; // Não rethrow em background para não quebrar o app
          }
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * 1.2).round());
        }
      }
    }
    debugPrint('❌ FALHA FINAL: Não foi possível criar responsável $userId após $maxAttempts tentativas em background.');
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
        await _supabase
            .from('children')
            .insert({
              'id': childUserId,
              'responsavel_id': responsavelId,
              'nome': nome,
              'cpf': cpf,
              'email': email,
              'idade': idade,
              'sexo': sexo,
              'created_at': DateTime.now().toIso8601String(),
            });
        debugPrint('✅ Criança $childUserId criada com sucesso!');
        return; // Sucesso, sai do loop
      } catch (e) {
        // Log detalhado do erro
        debugPrint('❌ Erro na tentativa ${attempts + 1} de criar criança $childUserId:');
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
          debugPrint('⏳ Tentativa $attempts de $maxQuickAttempts para criança $childUserId. Aguardando ${quickDelayMs}ms...');
          await Future.delayed(const Duration(milliseconds: quickDelayMs));
          continue;
        } else if (isForeignKeyError) {
          // Se ainda falhar após tentativas rápidas, aguardar um pouco mais e tentar
          debugPrint('⚠️ Tentativas rápidas falharam. Aguardando mais tempo e tentando novamente...');
          await Future.delayed(const Duration(milliseconds: 1000));
          // Tentar mais algumas vezes antes de desistir
          for (int i = 0; i < 5; i++) {
            try {
              await _supabase
                  .from('children')
                  .insert({
                    'id': childUserId,
                    'responsavel_id': responsavelId,
                    'nome': nome,
                    'cpf': cpf,
                    'email': email,
                    'idade': idade,
                    'sexo': sexo,
                    'created_at': DateTime.now().toIso8601String(),
                  });
              debugPrint('✅ Criança $childUserId criada com sucesso após aguardar!');
              return;
            } catch (e) {
              if (i < 4) {
                debugPrint('⏳ Tentativa adicional ${i + 1}/5 para criança $childUserId. Aguardando 500ms...');
                await Future.delayed(const Duration(milliseconds: 500));
              } else {
                debugPrint('❌ Erro persistente ao criar criança $childUserId: $e');
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
    debugPrint('🔄 Iniciando processamento em background para criança $childUserId...');
    int attempts = 0;
    const int maxAttempts = 15;
    Duration delay = const Duration(milliseconds: 1000);

    while (attempts < maxAttempts) {
      try {
        await _supabase
            .from('children')
            .insert({
              'id': childUserId,
              'responsavel_id': responsavelId,
              'nome': nome,
              'cpf': cpf,
              'email': email,
              'idade': idade,
              'sexo': sexo,
              'created_at': DateTime.now().toIso8601String(),
            });
        debugPrint('✅ Criança $childUserId criada com sucesso em background na tentativa ${attempts + 1}!');
        return;
      } catch (e) {
        attempts++;
        final isForeignKeyError = 
            (e is PostgrestException && e.code == '23503') ||
            e.toString().contains('foreign key constraint') ||
            e.toString().contains('23503');
        
        if (isForeignKeyError && attempts < maxAttempts) {
          debugPrint('⏳ Tentativa $attempts/$maxAttempts em background para criança $childUserId. Aguardando ${delay.inMilliseconds}ms...');
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * 1.2).round());
          continue;
        } else if (e.toString().contains('duplicate') || e.toString().contains('unique')) {
          debugPrint('ℹ️ Criança $childUserId já existe em background.');
          return;
        } else {
          debugPrint('❌ Erro ao criar criança $childUserId em background (tentativa $attempts/$maxAttempts): $e');
          if (attempts >= maxAttempts) {
            debugPrint('❌ FALHA FINAL: Não foi possível criar criança $childUserId após $maxAttempts tentativas em background.');
            return; // Não rethrow em background para não quebrar o app
          }
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * 1.2).round());
        }
      }
    }
    debugPrint('❌ FALHA FINAL: Não foi possível criar criança $childUserId após $maxAttempts tentativas em background.');
  }

  Future<UserEntity?> fetchUserProfile(String authUserId) async {
    try {
      final parent = await _getParentById(authUserId);
      if (parent != null) {
        return parent;
      }

      final child = await _getChildById(authUserId);
      return child;
    } catch (e, stack) {
      debugPrint('❌ Erro ao buscar perfil do usuário $authUserId: $e');
      debugPrint(stack.toString());
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
        .select(
          '''
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
          created_at
          ''',
        )
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
      limits: const {}, // Coluna não existe no banco de dados
      requiresApproval: response['requires_approval'] as bool? ?? true,
      allowedCategories: const [], // Coluna não existe no banco de dados
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
