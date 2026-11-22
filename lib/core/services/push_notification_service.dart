import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'fcm_token';

  /// Lo registra la app: qué hacer con un push de alerta (`tipo=alerta`).
  /// `urgente` = sismo muy fuerte y estoy dentro de la zona afectada (alerta SOS);
  /// `abrio` = el usuario tocó la notificación (la app estaba en segundo plano o cerrada).
  void Function({required bool urgente, required bool abrio, required String titulo, required String cuerpo})?
      alRecibirAlerta;

  void _procesar(RemoteMessage message, {required bool abrio}) {
    if (message.data['tipo'] != 'alerta') return;
    alRecibirAlerta?.call(
      urgente: message.data['urgente'] == '1',
      abrio: abrio,
      titulo: message.notification?.title ?? 'Alerta',
      cuerpo: message.notification?.body ?? '',
    );
  }

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('FCM permission: ${settings.authorizationStatus}');
    }

    String? token = await _messaging.getToken();
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
      if (kDebugMode) {
        print('FCM token: $token');
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message: ${message.notification?.title}');
      }
      _procesar(message, abrio: false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened app: ${message.notification?.title}');
      }
      _procesar(message, abrio: true);
    });

    // La app estaba cerrada y se abrió tocando la notificación
    final inicial = await _messaging.getInitialMessage();
    if (inicial != null) _procesar(inicial, abrio: true);

    _messaging.onTokenRefresh.listen((String newToken) async {
      await _storage.write(key: _tokenKey, value: newToken);
      if (kDebugMode) {
        print('FCM token refreshed');
      }
    });
  }

  Future<String?> getSavedToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
