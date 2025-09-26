import 'package:get_it/get_it.dart';
import 'package:lummy_login/data/datasources/in_memory_data_source.dart';
import 'package:lummy_login/data/repositories/auth_repository_impl.dart';
import 'package:lummy_login/data/repositories/finance_repository_impl.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';
import 'package:lummy_login/domain/repositories/finance_repository.dart';
import 'package:lummy_login/domain/usecases/add_transaction_use_case.dart';
import 'package:lummy_login/domain/usecases/get_financial_data_use_case.dart';
import 'package:lummy_login/domain/usecases/login_use_case.dart';
import 'package:lummy_login/domain/usecases/set_goal_use_case.dart';
import 'package:lummy_login/application/app_facade.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Data sources
  locator.registerLazySingleton<InMemoryDataSource>(() => InMemoryDataSource());

  // Repositories
  locator.registerLazySingleton<AuthRepository>(() => InMemoryAuthRepository());
  locator.registerLazySingleton<FinanceRepository>(() => InMemoryFinanceRepository(locator()));

  // Use cases
  locator.registerFactory<LoginUseCase>(() => LoginUseCase(locator()));
  locator.registerFactory<AddTransactionUseCase>(() => AddTransactionUseCase(locator()));
  locator.registerFactory<SetGoalUseCase>(() => SetGoalUseCase(locator()));
  locator.registerFactory<GetFinancialDataUseCase>(() => GetFinancialDataUseCase(locator()));

  // Biometrics
  locator.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  locator.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  locator.registerLazySingleton<BiometricAuthService>(() => BiometricAuthService(
        locator<LocalAuthentication>(),
        locator<FlutterSecureStorage>(),
      ));
}


