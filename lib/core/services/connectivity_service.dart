import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lummy/core/config/supabase_config.dart';

/// Função que responde se há conexão. Injetável para testes.
typedef ConnectionProbe = Future<bool> Function();

class ConnectivityService extends ChangeNotifier {
  ConnectivityService({ConnectionProbe? probe})
      : _probe = probe ?? _probeBackend {
    _schedulePolling();
    _check();
  }

  final ConnectionProbe _probe;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _timer;

  /// Offline: verifica com mais frequência para voltar rápido. Online: intervalo maior.
  void _schedulePolling() {
    _timer?.cancel();
    final interval =
        _isOnline ? const Duration(seconds: 12) : const Duration(seconds: 3);
    _timer = Timer.periodic(interval, (_) => _check());
  }

  Future<void> _check() async {
    final online = await _probe();
    if (online != _isOnline) {
      _isOnline = online;
      _schedulePolling();
      notifyListeners();
    }
  }

  /// Testa a conexão chamando o próprio backend (Supabase).
  ///
  /// Qualquer resposta HTTP — inclusive 401 — prova que há conexão; só erro
  /// de rede ou timeout contam como offline. Funciona em Android, iOS e Web
  /// (o antigo `InternetAddress.lookup` do dart:io não existe no navegador e
  /// deixava o app sempre "offline" no Web).
  static Future<bool> _probeBackend() async {
    try {
      await http
          .head(Uri.parse('${SupabaseConfig.url}/auth/v1/health'))
          .timeout(const Duration(seconds: 4));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Força nova verificação (ex.: botão no banner ou após falha de rede).
  Future<void> recheck() => _check();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
