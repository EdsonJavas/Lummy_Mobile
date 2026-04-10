import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    _schedulePolling();
    _check();
  }

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
    final online = await _hasConnection();
    if (online != _isOnline) {
      _isOnline = online;
      _schedulePolling();
      notifyListeners();
    }
  }

  Future<bool> _hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
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
