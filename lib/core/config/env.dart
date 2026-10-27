import 'package:flutter/foundation.dart';

/// Variables de entorno de la app.
/// Se inyectan al compilar: `flutter run --dart-define-from-file=.env`
/// (ver `.env.example`). Si no se pasan, se usan los valores por defecto de desarrollo.
class Env {
  Env._();

  static const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// URL de la API. Si no se pasa API_BASE_URL, depende de dónde corre la app:
  /// - Chrome (`flutter run -d chrome`), Windows o simulador iOS: http://localhost:8000
  /// - Emulador Android: http://10.0.2.2:8000 (así ve el emulador el localhost de tu PC)
  /// - Teléfono real: pasar la IP de la PC, p. ej.
  ///   `flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000`
  static String get apiBaseUrl {
    if (_apiBaseUrl.isNotEmpty) return _apiBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  /// Plantilla de teselas del mapa (flutter_map).
  static const mapTileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const emergencyLine = String.fromEnvironment(
    'EMERGENCY_LINE',
    defaultValue: '123',
  );
}
