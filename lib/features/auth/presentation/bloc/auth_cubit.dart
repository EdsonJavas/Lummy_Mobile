import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/user_entity.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // Login com email e senha
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      // TODO: Implementar com backend (Supabase no futuro)
      await Future.delayed(const Duration(seconds: 1));

      // Mock user para teste
      final user = ChildEntity(
        id: '1',
        email: email,
        name: 'Edson Jr',
        parentId: 'parent_1',
        age: 12,
        gender: Gender.male,
        cpf: '12345678901',
        createdAt: DateTime.now(),
        balance: 127.50,
        allowance: 50.0,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Login com biometria
  Future<void> loginWithBiometrics(String userId) async {
    emit(AuthLoading());

    try {
      // TODO: Implementar com backend
      await Future.delayed(const Duration(milliseconds: 500));

      final user = ChildEntity(
        id: userId,
        email: 'user@example.com',
        name: 'Edson Jr',
        parentId: 'parent_1',
        age: 12,
        gender: Gender.male,
        cpf: '12345678901',
        createdAt: DateTime.now(),
        balance: 127.50,
        allowance: 50.0,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
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
      // TODO: Implementar com backend
      await Future.delayed(const Duration(seconds: 1));

      if (role == UserRole.child) {
        final user = ChildEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: name,
          parentId: additionalData['parentId'],
          age: additionalData['age'],
          gender: additionalData['gender'],
          cpf: additionalData['cpf'],
          createdAt: DateTime.now(),
        );
        emit(AuthAuthenticated(user));
      } else {
        final user = ParentEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          name: name,
          cpf: additionalData['cpf'],
          createdAt: DateTime.now(),
        );
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }

  // Verificar status de biometria
  Future<void> checkBiometricStatus() async {
    // TODO: Implementar verificação real
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
}
