import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/solicitud_ayuda_model.dart';

class SolicitudesAyudaRemoteDatasource {
  SolicitudesAyudaRemoteDatasource(this._api);

  final ApiClient _api;

  Future<SolicitudAyudaModel> crear({
    required String tipo,
    required String descripcion,
    required double lat,
    required double lng,
    String? direccion,
  }) async =>
      SolicitudAyudaModel.fromJson(await _api.post<Map<String, dynamic>>(Endpoints.solicitudes, datos: {
        'tipo': tipo,
        'descripcion': descripcion,
        'ubicacion': {'lat': lat, 'lng': lng},
        if (direccion != null && direccion.isNotEmpty) 'direccion': direccion,
      }));

  /// El SOS solo manda la ubicación: el backend la crea crítica y de tipo rescate.
  Future<SolicitudAyudaModel> sos({required double lat, required double lng}) async =>
      SolicitudAyudaModel.fromJson(await _api.post<Map<String, dynamic>>(Endpoints.sos, datos: {
        'ubicacion': {'lat': lat, 'lng': lng},
      }));

  /// Para el ciudadano, GET /solicitudes-ayuda devuelve solo las suyas.
  Future<List<SolicitudAyudaModel>> misSolicitudes() async {
    final pagina = await _api.get<Map<String, dynamic>>(Endpoints.solicitudes, query: {'por_pagina': 50});
    return (pagina['items'] as List).map((e) => SolicitudAyudaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SolicitudAyudaModel> cancelar(String id) async =>
      SolicitudAyudaModel.fromJson(await _api.post<Map<String, dynamic>>(Endpoints.cancelarSolicitud(id)));
}
