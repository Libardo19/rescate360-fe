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
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened app: ${message.notification?.title}');
      }
    });

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
