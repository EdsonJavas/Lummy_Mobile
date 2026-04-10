import 'package:flutter/foundation.dart';

/// Heurística para falhas típicas de rede (DNS, socket, timeout).
bool isNetworkFailure(Object error) {
  final s = error.toString().toLowerCase();
  return s.contains('socketexception') ||
      s.contains('failed host lookup') ||
      s.contains('clientexception') ||
      s.contains('connection refused') ||
      s.contains('connection reset') ||
      s.contains('network is unreachable') ||
      s.contains('timed out') ||
      s.contains('timeout') ||
      s.contains('host lookup') ||
      s.contains('no address associated');
}

/// Log curto em debug: offline não spamma stack nem URL inteira.
void debugLogDataLoad(String context, Object error, [StackTrace? stackTrace]) {
  if (!kDebugMode) return;
  if (isNetworkFailure(error)) {
    debugPrint('📴 $context (sem rede)');
  } else {
    debugPrint('⚠️ $context: $error');
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }
}

/// Erros nos testes Supabase em debug.
void debugLogSupabaseCheck(String operation, Object error) {
  if (!kDebugMode) return;
  if (isNetworkFailure(error)) {
    debugPrint('📴 $operation indisponível (sem rede)');
  } else {
    debugPrint('❌ $operation: $error');
  }
}
