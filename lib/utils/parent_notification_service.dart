import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

bool _initialized = false;

const _channelId = 'parent_alerts';
const _channelName = 'Alertas do responsável';
const _channelDesc = 'Pedidos, aprovações, metas e mesadas';

Future<void> initParentNotifications() async {
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
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }
  _initialized = true;
}

Future<void> showParentNotification({
  required int id,
  required String title,
  required String body,
}) async {
  try {
    await initParentNotifications();
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
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
    debugPrint('Erro ao exibir notificação parent: $e');
  }
}

/// Convenience methods for common parent events.
Future<void> notifyNewChildRequest(String childName, double amount) =>
    showParentNotification(
      id: 100,
      title: 'Pedido de $childName',
      body:
          '$childName fez um pedido de R\$ ${amount.toStringAsFixed(2)}. Aprove ou rejeite.',
    );

Future<void> notifyGoalReached(String childName, String goalName) =>
    showParentNotification(
      id: 101,
      title: '$childName atingiu uma meta!',
      body: 'A meta "$goalName" foi alcançada. Parabéns!',
    );

Future<void> notifyAllowanceReminder(int childCount) =>
    showParentNotification(
      id: 102,
      title: 'Lembrete de mesada',
      body: 'Você tem $childCount filho(s). Envie a mesada pelo app.',
    );
