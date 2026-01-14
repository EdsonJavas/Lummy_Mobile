import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
      debugPrint('🔐 Tentando fazer login com email: ${email.trim()}');
      
      debugPrint('🚀 Chamando signInWithPassword...');
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ Timeout após 30 segundos');
          throw TimeoutException('Tempo de conexão esgotado ao fazer login');
        },
      );
      
      debugPrint('📥 Resposta recebida do Supabase');

      if (response.user == null) {
        debugPrint('❌ Login falhou: usuário é null');
        return const FailureResult<String>(
          Failure('Falha ao fazer login. Tente novamente.'),
        );
      }

      debugPrint('✅ Login bem-sucedido! User ID: ${response.user!.id}');
      debugPrint('📧 Email do usuário: ${response.user!.email}');
      
      return Success<String>(response.user!.id);
    } on AuthException catch (e) {
      debugPrint('❌ Erro de autenticação: ${e.message}');
      debugPrint('   Código: ${e.statusCode}');
      return FailureResult<String>(Failure(_getErrorMessage(e.message)));
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout ao fazer login: $e');
      return const FailureResult<String>(
        Failure('Tempo de conexão esgotado.\n\n'
            'O servidor demorou muito para responder.\n'
            'Verifique sua conexão com a internet e tente novamente.'),
      );
    } on SocketException catch (e) {
      debugPrint('❌ Erro de socket ao fazer login: $e');
      debugPrint('   Tipo: ${e.runtimeType}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   OSError: ${e.osError}');
      debugPrint('   Address: ${e.address}');
      debugPrint('   Port: ${e.port}');
      
      String errorMsg = 'Erro de conexão com o servidor.\n\n';
      if (e.message.contains('Failed host lookup') || 
          e.message.contains('No address associated with hostname')) {
        errorMsg += 'Não foi possível resolver o endereço do servidor.\n\n';
        errorMsg += 'Possíveis causas:\n';
        errorMsg += '• Sem conexão com internet (verifique Wi-Fi/dados móveis)\n';
        errorMsg += '• URL do Supabase incorreta ou projeto inativo\n';
        errorMsg += '• Problema de DNS no dispositivo\n\n';
        errorMsg += 'Solução: Verifique sua conexão e tente novamente.';
      } else {
        errorMsg += 'Verifique:\n';
        errorMsg += '• Sua conexão com a internet\n';
        errorMsg += '• Se a URL do Supabase está correta\n';
        errorMsg += '• Se o projeto Supabase está ativo\n\n';
        errorMsg += 'Erro: ${e.message}';
      }
      
      return FailureResult<String>(Failure(errorMsg));
    } catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado ao fazer login: $e');
      debugPrint('   Tipo: ${e.runtimeType}');
      debugPrint('   Stack trace: $stackTrace');
      
      // Tratar erros de conexão especificamente
      final errorMessage = _getConnectionErrorMessage(e);
      return FailureResult<String>(Failure(errorMessage));
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
        data: {'name': name, ...?metadata},
      );

      if (response.user == null) {
        return const FailureResult<String>(
          Failure('Falha ao criar conta. Tente novamente.'),
        );
      }

      return Success<String>(response.user!.id);
    } on AuthException catch (e) {
      return FailureResult<String>(Failure(_getErrorMessage(e.message)));
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

  // Helper para tratar erros de conexão
  String _getConnectionErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || 
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated with hostname')) {
      return 'Erro de conexão com o servidor.\n\n'
          'Verifique:\n'
          '• Sua conexão com a internet\n'
          '• Se está usando emulador, verifique se tem acesso à internet\n'
          '• Se a URL do Supabase está correta\n\n'
          'Erro: Falha ao resolver o endereço do servidor';
    }
    
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Tempo de conexão esgotado.\n\n'
          'O servidor demorou muito para responder.\n'
          'Verifique sua conexão com a internet e tente novamente.';
    }
    
    if (errorString.contains('connection refused') ||
        errorString.contains('connection reset')) {
      return 'Conexão recusada pelo servidor.\n\n'
          'Verifique se o servidor Supabase está online e acessível.';
    }
    
    return 'Erro ao fazer login: ${error.toString()}';
  }
}
