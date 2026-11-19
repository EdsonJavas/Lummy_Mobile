import 'package:flutter_test/flutter_test.dart';
import 'package:lummy_login/core/services/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    test('fica offline quando a sonda falha e volta a online quando ela passa',
        () async {
      var reachable = false;
      final service = ConnectivityService(probe: () async => reachable);
      addTearDown(service.dispose);

      await service.recheck();
      expect(service.isOnline, isFalse);

      reachable = true;
      await service.recheck();
      expect(service.isOnline, isTrue);
    });

    test('notifica ouvintes só quando o estado muda', () async {
      final service = ConnectivityService(probe: () async => true);
      addTearDown(service.dispose);
      var notifications = 0;
      service.addListener(() => notifications++);

      await service.recheck();
      await service.recheck();
      expect(notifications, 0); // já começa online; nada mudou
    });

    // Reproduz o bug do login no navegador: rode com
    //   flutter test --platform chrome test/core/services/connectivity_service_test.dart
    // A sonda padrão precisa funcionar também no Web (sem dart:io).
    test('sonda padrão detecta conexão real (inclusive no Web)', () async {
      final service = ConnectivityService();
      addTearDown(service.dispose);

      await service.recheck();
      expect(service.isOnline, isTrue);
    }, tags: 'network');
  });
}
