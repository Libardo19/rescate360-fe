import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/marcador_mapa_model.dart';

class MapaRemoteDatasource {
  MapaRemoteDatasource(this._api);

  final ApiClient _api;

  static const _capas = 'solicitudes,reportes,centros,zonas,alertas';

  /// Sin [desde]: el mapa completo alrededor de (lat, lng). Con [desde]: solo lo que cambió.
  Future<RespuestaMapa> puntos({
    required double lat,
    required double lng,
    double radioM = 10000,
    String? desde,
  }) async {
    final json = await _api.get<Map<String, dynamic>>(Endpoints.mapa, query: {
      'lat': lat,
      'lng': lng,
      'radio_m': radioM,
      'capas': _capas,
      if (desde != null) 'desde': desde,
    });
    return RespuestaMapa(
      [for (final p in (json['puntos'] as List).cast<Map<String, dynamic>>()) MarcadorMapaModel.fromJson(p)],
      json['generado_en'] as String,
    );
  }

  /// Ubicación actual del usuario (la usan las alertas por zona). El backend exige
  /// la autorización de ubicación (Ley 1581); sin ella responde CONSENTIMIENTO_UBICACION_REQUERIDO.
  Future<void> enviarMiUbicacion(double lat, double lng) =>
      _api.patch<dynamic>(Endpoints.miUbicacion, datos: {'lat': lat, 'lng': lng});
}
