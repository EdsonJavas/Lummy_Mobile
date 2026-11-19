import 'package:flutter/foundation.dart';

/// Log de desenvolvimento.
///
/// Só imprime em modo debug; no app publicado (release) não gera nenhuma saída,
/// evitando vazar dados de usuários no logcat. Ponto único para, no futuro,
/// enviar erros a um serviço de monitoramento (ex.: Sentry, Crashlytics).
void appLog(String? message) {
  if (kDebugMode) debugPrint(message);
}
