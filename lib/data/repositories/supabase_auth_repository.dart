import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<Result<String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        return const FailureResult<String>(
          Failure('Falha ao fazer login. Tente novamente.'),
        );
      }

      return Success<String>(response.user!.id);
    } on AuthException catch (e) {
      return FailureResult<String>(
        Failure(_getErrorMessage(e.message)),
      );
    } catch (e) {
      return FailureResult<String>(
        Failure('Erro ao fazer login: ${e.toString()}'),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // Log error but don't throw
      print('Erro ao fazer logout: $e');
    }
  }

  @override
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Métodos adicionais para registro

  @override
  Future<Result<String>> register({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
          ...?metadata,
        },
      );

      if (response.user == null) {
        return const FailureResult<String>(
          Failure('Falha ao criar conta. Tente novamente.'),
        );
      }

      return Success<String>(response.user!.id);
    } on AuthException catch (e) {
      return FailureResult<String>(
        Failure(_getErrorMessage(e.message)),
      );
    } catch (e) {
      return FailureResult<String>(
        Failure('Erro ao criar conta: ${e.toString()}'),
      );
    }
  }

  // Helper para traduzir mensagens de erro do Supabase
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
