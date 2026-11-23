import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'fcm_token';

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String? token = await _messaging.getToken();
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
    }

    FirebaseMessaging.onMessage.listen((_) {});

    FirebaseMessaging.onMessageOpenedApp.listen((_) {});

    _messaging.onTokenRefresh.listen((String newToken) async {
      await _storage.write(key: _tokenKey, value: newToken);
    });
  }

  Future<String?> getSavedToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
