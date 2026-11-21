import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/firebase_options.dart';

/// Mensagem recebida com o app fechado ou em segundo plano.
///
/// As mensagens do Lummy têm `notification`, então o próprio sistema mostra o
/// aviso; aqui só garantimos o Firebase iniciado neste isolate.
@pragma('vm:entry-point')
Future<void> lummyPushBackgroundHandler(RemoteMessage message) async {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options == null) return;
  await Firebase.initializeApp(options: options);
}

/// Notificações remotas (Firebase Cloud Messaging).
///
/// Fluxo:
/// 1. [iniciar] (depois do `Supabase.initialize`) liga o Firebase e passa a
///    ouvir o login/logout.
/// 2. Ao entrar numa conta, pede permissão, pega o token do aparelho e grava em
///    `push_tokens` pela RPC `register_push_token`.
/// 3. Ao sair, apaga o token pela RPC `unregister_push_token`: o aparelho para
///    de receber avisos da conta que saiu.
/// 4. Quem dispara os avisos é o banco: gatilhos gravam em
///    `push_notifications` e a Edge Function `send-push` envia pelo FCM
///    (ver `supabase/migrations/20261121120000_push_notifications.sql`).
///
/// Web e desktop não têm notificação remota: tudo aqui vira no-op.
abstract final class PushNotifications {
  static const _canalId = 'lummy_push';
  static const _canalNome = 'Avisos do Lummy';
  static const _canalDescricao =
      'Dinheiro recebido, pedidos, gastos, mesadas e missões';

  static final _local = FlutterLocalNotificationsPlugin();
  static bool _iniciado = false;
  static String? _tokenRegistrado;

  // Mantida viva enquanto o app roda (nunca é cancelada de propósito).
  // ignore: unused_field, cancel_subscriptions
  static StreamSubscription<AuthState>? _authSub;

  static bool get _suportado =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  /// Liga o Firebase e passa a acompanhar a sessão do Supabase.
  /// Chamar uma vez, depois do `Supabase.initialize`. Nunca lança.
  static Future<void> iniciar() async {
    if (_iniciado || !_suportado) return;
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options == null) return;
    try {
      await Firebase.initializeApp(options: options);
      FirebaseMessaging.onBackgroundMessage(lummyPushBackgroundHandler);
      await _prepararAvisoLocal();

      final messaging = FirebaseMessaging.instance;
      // iOS: com o app aberto, o próprio sistema mostra o aviso.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onMessage.listen(_mostrarComAppAberto);
      // getToken/onTokenRefresh estão marcados como obsoletos no
      // firebase_messaging 17 (em favor de register/onRegistered, que devolve o
      // ID de instalação). Seguimos com o token clássico porque é o que a API
      // HTTP v1 do FCM aceita em `message.token`, usada pela Edge Function.
      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((token) => unawaited(_registrar(token)));
      _iniciado = true;

      final auth = Supabase.instance.client.auth;
      _authSub = auth.onAuthStateChange.listen((estado) {
        switch (estado.event) {
          case AuthChangeEvent.initialSession:
          case AuthChangeEvent.signedIn:
            if (estado.session != null) unawaited(_ativarParaUsuario());
          case AuthChangeEvent.signedOut:
            unawaited(_desativarAparelho());
          default:
            break;
        }
      });
      // Sessão restaurada antes de este listener existir.
      if (auth.currentSession != null) unawaited(_ativarParaUsuario());
    } catch (e) {
      appLog('⚠️ Push: não deu para iniciar: $e');
    }
  }

  /// Pede permissão (a primeira vez) e registra o token do aparelho.
  static Future<void> _ativarParaUsuario() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final permissao = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (permissao.authorizationStatus == AuthorizationStatus.denied) {
        appLog('ℹ️ Push: permissão negada pelo usuário');
        return;
      }
      if (_ios) {
        // O token do FCM depende do token da Apple, que pode demorar.
        for (var tentativa = 0; tentativa < 5; tentativa++) {
          if (await messaging.getAPNSToken() != null) break;
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token != null) await _registrar(token);
    } catch (e) {
      appLog('⚠️ Push: não deu para registrar o aparelho: $e');
    }
  }

  static Future<void> _registrar(String token) async {
    final client = Supabase.instance.client;
    if (client.auth.currentSession == null) return;
    try {
      await client.rpc(
        'register_push_token',
        params: {'p_token': token, 'p_platform': _ios ? 'ios' : 'android'},
      );
      _tokenRegistrado = token;
    } catch (e) {
      appLog('⚠️ Push: falha ao gravar o token: $e');
    }
  }

  /// Depois do logout: o aparelho deixa de receber avisos da conta que saiu.
  static Future<void> _desativarAparelho() async {
    try {
      final token = _tokenRegistrado ??
          // ignore: deprecated_member_use
          await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await Supabase.instance.client.rpc(
        'unregister_push_token',
        params: {'p_token': token},
      );
      _tokenRegistrado = null;
    } catch (e) {
      appLog('⚠️ Push: falha ao apagar o token: $e');
    }
  }

  static Future<void> _prepararAvisoLocal() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // A permissão é pedida pelo Firebase, depois do login.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _local.initialize(settings: settings);
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _canalId,
            _canalNome,
            description: _canalDescricao,
            importance: Importance.high,
          ),
        );
  }

  /// Android não mostra sozinho a notificação com o app aberto; o iOS sim
  /// (ver `setForegroundNotificationPresentationOptions`).
  static Future<void> _mostrarComAppAberto(RemoteMessage message) async {
    if (_ios) return;
    final aviso = message.notification;
    if (aviso == null) return;
    try {
      await _local.show(
        id: message.messageId?.hashCode ?? DateTime.now().millisecond,
        title: aviso.title,
        body: aviso.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _canalId,
            _canalNome,
            channelDescription: _canalDescricao,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      appLog('⚠️ Push: falha ao mostrar aviso com o app aberto: $e');
    }
  }
}
