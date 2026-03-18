import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKeyLastBalance = 'child_last_known_balance';

final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

bool _initialized = false;

Future<void> initChildMoneyNotifications() async {
  if (_initialized) return;
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestSoundPermission: true,
  );
  const settings = InitializationSettings(android: android, iOS: ios);
  await _plugin.initialize(
    settings: settings,
    onDidReceiveNotificationResponse: (_) {},
  );
  if (Platform.isAndroid) {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    // Criar canal com alta prioridade para som e vibração
    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      'recebimento_dinheiro',
      'Recebimento de dinheiro',
      description: 'Avisos quando você recebe dinheiro do responsável',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    ));
  }
  _initialized = true;
}

Future<void> checkAndNotifyBalanceIncrease(double newBalance) async {
  try {
    await initChildMoneyNotifications();
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getDouble(_prefKeyLastBalance);
    final previous = last ?? 0.0;
    // Notifica quando o saldo aumentou (inclui 1ª vez que recebe, quando previous era 0)
    if (newBalance > previous && (newBalance - previous) >= 0.01) {
      const android = AndroidNotificationDetails(
        'recebimento_dinheiro',
        'Recebimento de dinheiro',
        channelDescription: 'Avisos quando você recebe dinheiro do responsável',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      const ios = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      );
      const details = NotificationDetails(android: android, iOS: ios);
      await _plugin.show(
        id: 1,
        title: 'Você recebeu dinheiro! 💰',
        body: 'Seu responsável enviou um valor para você. Confira seu saldo.',
        notificationDetails: details,
      );
    }
    await prefs.setDouble(_prefKeyLastBalance, newBalance);
  } catch (e) {
    debugPrint('Erro ao verificar/notificar saldo: $e');
  }
}

Future<void> showChildEventNotification({
  required int id,
  required String title,
  required String body,
}) async {
  try {
    await initChildMoneyNotifications();
    const android = AndroidNotificationDetails(
      'recebimento_dinheiro',
      'Recebimento de dinheiro',
      channelDescription: 'Avisos quando você recebe dinheiro do responsável',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  } catch (e) {
    debugPrint('Erro ao exibir notificação: $e');
  }
}
