import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    _startMonitoring();
  }

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _timer;

  void _startMonitoring() {
    _check();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _check());
  }

  Future<void> _check() async {
    final online = await _hasConnection();
    if (online != _isOnline) {
      _isOnline = online;
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

  /// Force an immediate connectivity re-check (e.g. after a failed request).
  Future<void> recheck() => _check();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
