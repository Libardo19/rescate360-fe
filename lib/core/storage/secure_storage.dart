import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tokens de la sesión y el usuario, cifrados en el dispositivo
/// (Keystore en Android, Keychain en iOS). Nunca en SharedPreferences.
class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';
  static const _usuario = 'usuario';
  // Llave HMAC para firmar los mensajes sin conexión (GET /usuarios/me/llave-offline)
  static const _llaveOffline = 'llave_offline';

  Future<void> guardarSesion({
    required String accessToken,
    required String refreshToken,
    required String usuarioJson,
  }) async {
    await _storage.write(key: _access, value: accessToken);
    await _storage.write(key: _refresh, value: refreshToken);
    await _storage.write(key: _usuario, value: usuarioJson);
  }

  Future<void> guardarTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _access, value: accessToken);
    await _storage.write(key: _refresh, value: refreshToken);
  }

  Future<String?> accessToken() => _storage.read(key: _access);
  Future<String?> refreshToken() => _storage.read(key: _refresh);
  Future<String?> usuarioJson() => _storage.read(key: _usuario);

  Future<String?> llaveOffline() => _storage.read(key: _llaveOffline);
  Future<void> guardarLlaveOffline(String llave) => _storage.write(key: _llaveOffline, value: llave);

  Future<void> borrarSesion() async {
    await _storage.delete(key: _llaveOffline);
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
    await _storage.delete(key: _usuario);
  }
}
