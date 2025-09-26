import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/domain/usecases/add_transaction_use_case.dart';
import 'package:lummy_login/domain/usecases/get_financial_data_use_case.dart';
import 'package:lummy_login/domain/usecases/login_use_case.dart';
import 'package:lummy_login/domain/usecases/set_goal_use_case.dart';
import 'package:lummy_login/models/financial_data.dart';
import 'package:lummy_login/models/goal.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _cachedUserIdKey = 'cached_user_id';

  BiometricAuthService(this._localAuth, this._secureStorage);

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final available = await _localAuth.getAvailableBiometrics();
      return canCheck && available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    final v = await _secureStorage.read(key: _biometricEnabledKey);
    return v == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<void> cacheUserId(String userId) async {
    await _secureStorage.write(key: _cachedUserIdKey, value: userId);
  }

  Future<String?> readCachedUserId() async {
    return _secureStorage.read(key: _cachedUserIdKey);
  }

  Future<void> clearCachedUser() async {
    await _secureStorage.delete(key: _cachedUserIdKey);
  }

  Future<bool> authenticate({String reason = 'Confirmar para entrar'}) async {
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return didAuth;
    } catch (_) {
      return false;
    }
  }
}

/// Application Facade to expose use cases to UI without coupling to implementations.
class AppFacade {
  AppFacade._();

  static final AppFacade instance = AppFacade._();

  final LoginUseCase _login = locator<LoginUseCase>();
  final AddTransactionUseCase _addTransaction = locator<AddTransactionUseCase>();
  final SetGoalUseCase _setGoal = locator<SetGoalUseCase>();
  final GetFinancialDataUseCase _getFinancial = locator<GetFinancialDataUseCase>();

  Future<Result<String>> login(String email, String password) {
    return _login(email: email, password: password);
  }

  Future<Result<FinancialData>> getFinancialData(String userId) {
    return _getFinancial(userId);
  }

  Future<Result<FinancialData>> addTransaction({
    required String userId,
    required String description,
    required double amount,
    required String type,
    required String category,
  }) {
    return _addTransaction(
      userId: userId,
      description: description,
      amount: amount,
      type: type,
      category: category,
    );
  }

  Future<Result<Goal>> setGoal({
    required String userId,
    required String name,
    required String emoji,
    required double amount,
  }) {
    return _setGoal(
      userId: userId,
      name: name,
      emoji: emoji,
      amount: amount,
    );
  }
}


