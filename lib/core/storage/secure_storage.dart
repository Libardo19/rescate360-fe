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

  Future<void> borrarSesion() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
    await _storage.delete(key: _usuario);
  }
}
