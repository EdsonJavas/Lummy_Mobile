import 'package:get_it/get_it.dart';
import 'package:lummy_login/data/repositories/supabase_auth_repository.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';
import 'package:lummy_login/domain/usecases/login_use_case.dart';
import 'package:lummy_login/application/app_facade.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lummy_login/services/family_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Limpar registros anteriores se existirem (para hot reload)
  if (locator.isRegistered<AuthRepository>()) {
    locator.reset();
  }

  // Repositories
  // Supabase.instance.client deve estar disponível pois Supabase.initialize() já foi chamado
  locator.registerLazySingleton<AuthRepository>(() => SupabaseAuthRepository());

  // Use cases
  locator.registerFactory<LoginUseCase>(() => LoginUseCase(locator()));

  // Services
  locator.registerLazySingleton<FamilyService>(() => FamilyService());

  // Biometrics
  locator.registerLazySingleton<LocalAuthentication>(
    () => LocalAuthentication(),
  );
  locator.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  locator.registerLazySingleton<BiometricAuthService>(
    () => BiometricAuthService(
      locator<LocalAuthentication>(),
      locator<FlutterSecureStorage>(),
    ),
  );

  // Facade
  locator.registerLazySingleton<AppFacade>(() => AppFacade.instance);
}
