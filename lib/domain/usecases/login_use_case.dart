import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;
  const LoginUseCase(this.authRepository);

  Future<Result<String>> call({required String email, required String password}) {
    return authRepository.login(email: email, password: password);
  }
}


