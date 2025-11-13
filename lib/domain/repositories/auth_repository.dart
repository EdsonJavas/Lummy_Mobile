import 'package:lummy_login/core/result.dart';

abstract class AuthRepository {
  Future<Result<String>> login({required String email, required String password});
  Future<void> logout();
  String? get currentUserId;
  
  // Método opcional para registro (pode ser sobrescrito)
  Future<Result<String>> register({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? metadata,
  }) async {
    throw UnimplementedError('Register method not implemented');
  }
}


