import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  String? _currentUserId;

  @override
  Future<Result<String>> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      return FailureResult<String>(Failure('Credenciais inválidas', code: 'INVALID_CREDENTIALS'));
    }
    // Fake login; generate deterministic id
    _currentUserId = email;
    return Success<String>(_currentUserId!);
  }

  @override
  Future<void> logout() async {
    _currentUserId = null;
  }

  @override
  String? get currentUserId => _currentUserId;
}


