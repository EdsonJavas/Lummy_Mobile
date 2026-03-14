import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:lummy_login/domain/entities/user_entity.dart';
import 'package:lummy_login/auth/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final _supabase = Supabase.instance.client;

  // Login com email e senha
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      // Autenticar no Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        emit(const AuthError('Falha ao fazer login. Tente novamente.'));
        return;
      }

      // Buscar dados do usuário no banco
      final user = await _fetchUserData(response.user!.id);
      
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Dados do usuário não encontrados no banco de dados.'));
      }
    } on AuthException catch (e) {
      emit(AuthError(_getErrorMessage(e.message)));
    } catch (e) {
      emit(AuthError('Erro ao fazer login: ${e.toString()}'));
    }
  }

  // Login com biometria
  Future<void> loginWithBiometrics(String userId) async {
    emit(AuthLoading());

    try {
      // Buscar dados do usuário no banco usando o userId (email) cacheado
      final user = await _fetchUserDataByEmail(userId);
      
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Usuário não encontrado no banco de dados.'));
      }
    } catch (e) {
      emit(AuthError('Erro ao fazer login com biometria: ${e.toString()}'));
    }
  }

  // Registro
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required Map<String, dynamic> additionalData,
  }) async {
    emit(AuthLoading());

    try {
      // Criar usuário no Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
          'role': role.name,
          ...additionalData,
        },
      );

      if (response.user == null) {
        emit(const AuthError('Falha ao criar conta. Tente novamente.'));
        return;
      }

      // Criar registro na tabela apropriada
      if (role == UserRole.child) {
        // Validar dados obrigatórios
        if (additionalData['parentId'] == null) {
          emit(const AuthError('ID do responsável é obrigatório.'));
          return;
        }

        await _supabase.from('children').insert({
          'id': response.user!.id,
          'responsavel_id': additionalData['parentId'],
          'nome': name,
          'email': email.trim(),
          'cpf': additionalData['cpf'] ?? '',
          'idade': additionalData['age'] ?? 0,
          'sexo': _mapGenderToString(additionalData['gender'] as Gender?),
        });

        // Buscar dados criados
        final user = await _fetchUserData(response.user!.id);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthError('Conta criada mas dados não foram encontrados.'));
        }
      } else {
        await _supabase.from('responsaveis').insert({
          'id': response.user!.id,
          'nome': name,
          'email': email.trim(),
          'cpf': additionalData['cpf'] ?? '',
        });

        // Buscar dados criados
        final user = await _fetchUserData(response.user!.id);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthError('Conta criada mas dados não foram encontrados.'));
        }
      }
    } on AuthException catch (e) {
      emit(AuthError(_getErrorMessage(e.message)));
    } catch (e) {
      emit(AuthError('Erro ao criar conta: ${e.toString()}'));
    }
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _supabase.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Mesmo com erro, desautenticar localmente
      emit(AuthUnauthenticated());
    }
  }

  // Verificar status de biometria
  Future<void> checkBiometricStatus() async {
    // Esta verificação deve ser feita pelo serviço de biometria
    // Aqui apenas retornamos o estado inicial
    emit(
      const AuthBiometricAvailable(
        isAvailable: true,
        isEnabled: false,
        cachedUserId: null,
      ),
    );
  }

  // Atualizar usuário
  void updateUser(UserEntity user) {
    emit(AuthAuthenticated(user));
  }

  // Métodos auxiliares privados

  /// Busca dados do usuário no banco pelo ID
  Future<UserEntity?> _fetchUserData(String userId) async {
    try {
      // Tentar buscar como criança primeiro
      final childData = await _supabase
          .from('children')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (childData != null) {
        return ChildEntity(
          id: childData['id'] as String,
          email: (childData['email'] ?? '') as String,
          name: (childData['nome'] ?? '') as String,
          parentId: (childData['responsavel_id'] ?? '') as String,
          age: (childData['idade'] as int?) ?? 0,
          gender: _mapGenderFromString(childData['sexo'] as String?),
          cpf: (childData['cpf'] ?? '') as String,
          createdAt: _parseDate(childData['created_at']),
          balance: (childData['balance'] as num?)?.toDouble() ?? 0.0,
          allowance: (childData['allowance'] as num?)?.toDouble() ?? 0.0,
          limits: _parseLimits(childData['limits']),
          requiresApproval: childData['requires_approval'] as bool? ?? true,
          allowedCategories:
              _parseAllowedCategories(childData['allowed_categories']),
        );
      }

      // Tentar buscar como responsável
      final parentData = await _supabase
          .from('responsaveis')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (parentData != null) {
        // Buscar IDs dos filhos
        final childrenData = await _supabase
            .from('children')
            .select('id')
            .eq('responsavel_id', userId);

        return ParentEntity(
          id: parentData['id'] as String,
          email: (parentData['email'] ?? '') as String,
          name: (parentData['nome'] ?? '') as String,
          cpf: (parentData['cpf'] ?? '') as String,
          createdAt: _parseDate(parentData['created_at']),
          childrenIds: childrenData.map((c) => c['id'] as String).toList(),
        );
      }

      return null;
    } catch (e) {
      debugPrint('Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  /// Busca dados do usuário no banco pelo email
  Future<UserEntity?> _fetchUserDataByEmail(String email) async {
    try {
      // Buscar ID do usuário pelo email no auth
      final authUser = _supabase.auth.currentUser;
      if (authUser == null || authUser.email != email) {
        return null;
      }

      return await _fetchUserData(authUser.id);
    } catch (e) {
      debugPrint('Erro ao buscar dados do usuário por email: $e');
      return null;
    }
  }

  Gender _mapGenderFromString(String? value) {
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

  String _mapGenderToString(Gender? gender) {
    switch (gender) {
      case Gender.male:
        return 'Masculino';
      case Gender.female:
        return 'Feminino';
      default:
        return 'Outro';
    }
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
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

  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou senha incorretos';
    } else if (message.contains('Email not confirmed')) {
      return 'Email não confirmado. Verifique sua caixa de entrada.';
    } else if (message.contains('User already registered')) {
      return 'Este email já está cadastrado';
    } else if (message.contains('Password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres';
    } else if (message.contains('Invalid email')) {
      return 'Email inválido';
    }
    return message;
  }
}
