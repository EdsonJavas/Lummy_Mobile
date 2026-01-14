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

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
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
      print('Iniciando autenticação biométrica...');

      // Verificar se o dispositivo suporta biometria
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        print('Dispositivo não suporta biometria');
        return false;
      }

      // Verificar se há biometrias disponíveis
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      print('Biometrias disponíveis: $availableBiometrics');

      if (availableBiometrics.isEmpty) {
        print('Nenhuma biometria cadastrada');
        return false;
      }

      // Tentar autenticação
      final didAuth = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );

      print('Resultado da autenticação: $didAuth');
      return didAuth;
    } catch (e) {
      print('Erro na autenticação biométrica: $e');
      return false;
    }
  }
}

/// Application Facade to expose use cases to UI without coupling to implementations.
class AppFacade {
  AppFacade._();

  static final AppFacade instance = AppFacade._();

  // Usar lazy getters para evitar acesso ao locator antes da inicialização
  LoginUseCase get _login => locator<LoginUseCase>();
  AddTransactionUseCase get _addTransaction => locator<AddTransactionUseCase>();
  SetGoalUseCase get _setGoal => locator<SetGoalUseCase>();
  GetFinancialDataUseCase get _getFinancial =>
      locator<GetFinancialDataUseCase>();

  Future<Result<String>> login(String email, String password) {
    return _login(email: email, password: password);
  }

  Future<Result<String>> loginWithBiometrics(String userId) {
    // Para login com biometria, o userId (email) é usado para identificar o usuário.
    // A senha não é necessária, mas o LoginUseCase espera ambos. Pode ser necessário ajustar o LoginUseCase
    // ou passar uma senha placeholder se o backend exigir.
    return _login(
      email: userId,
      password: '',
    ); // Passando uma string vazia para a senha por enquanto
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
    return _setGoal(userId: userId, name: name, emoji: emoji, amount: amount);
  }
}
