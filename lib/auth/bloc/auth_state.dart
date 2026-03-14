import 'package:equatable/equatable.dart';
import 'package:lummy_login/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthBiometricAvailable extends AuthState {
  final bool isAvailable;
  final bool isEnabled;
  final String? cachedUserId;

  const AuthBiometricAvailable({
    required this.isAvailable,
    required this.isEnabled,
    this.cachedUserId,
  });

  @override
  List<Object?> get props => [isAvailable, isEnabled, cachedUserId];
}
