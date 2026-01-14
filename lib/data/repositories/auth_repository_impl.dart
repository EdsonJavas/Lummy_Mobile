import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  String? _currentUserId;

  @override
  Future<Result<String>> login({
    required String email,
    required String password,
  }) async {
    // Aceitar qualquer email e senha para facilitar o teste
    // Removendo a validação que estava causando problemas
    _currentUserId = email;
    return Success<String>(_currentUserId!);
  }

  @override
  Future<void> logout() async {
    _currentUserId = null;
  }

  @override
  String? get currentUserId => _currentUserId;

  @override
  Future<Result<String>> register({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? metadata,
  }) async {
    _currentUserId = email;
    return Success<String>(_currentUserId!);
  }
}
