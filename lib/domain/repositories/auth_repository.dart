import 'package:lummy_login/core/result.dart';

abstract class AuthRepository {
  Future<Result<String>> login({required String email, required String password});
  Future<void> logout();
  String? get currentUserId;
}


