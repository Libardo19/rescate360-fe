/// Variables de entorno de la app.
/// Se inyectan al compilar: `flutter run --dart-define-from-file=.env`
/// (ver `.env.example`). Si no se pasan, se usan los valores por defecto de desarrollo.
class Env {
  Env._();

  /// URL de la API. En el emulador Android, 10.0.2.2 es el localhost de tu PC.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

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
