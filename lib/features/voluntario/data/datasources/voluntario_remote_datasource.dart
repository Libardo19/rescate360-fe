import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../models/asignacion_model.dart';

class VoluntarioRemoteDatasource {
  VoluntarioRemoteDatasource(this._api);

  final ApiClient _api;

  /// Para el voluntario, GET /solicitudes-ayuda devuelve las de su organización.
  Future<List<SolicitudAyudaModel>> casosAbiertos() async {
    final pagina = await _api.get<Map<String, dynamic>>(Endpoints.solicitudes,
        query: {'por_pagina': 100});
    return [
      for (final s in (pagina['items'] as List).cast<Map<String, dynamic>>())
        SolicitudAyudaModel.fromJson(s),
    ].where((s) => s.cancelable).toList();
  }

  Future<SolicitudAyudaModel> solicitud(String id) async =>
      SolicitudAyudaModel.fromJson(
          await _api.get<Map<String, dynamic>>('${Endpoints.solicitudes}/$id'));

  /// El voluntario toma el caso: la solicitud pasa a "en proceso".
  Future<void> tomar(String solicitudId) =>
      _api.post<dynamic>(Endpoints.tomarSolicitud(solicitudId));

  /// Sin [estado] el backend devuelve activas, finalizadas y canceladas.
  Future<List<AsignacionModel>> misAsignaciones({String? estado}) async {
    final pagina = await _api.get<Map<String, dynamic>>(
      Endpoints.misAsignaciones,
      query: {
        if (estado != null) 'estado': estado,
        'por_pagina': 100,
      },
    );
    return [
      for (final a in (pagina['items'] as List).cast<Map<String, dynamic>>())
        AsignacionModel.fromJson(a)
    ];
  }

  /// finalizada = la solicitud queda atendida; cancelada = la suelta (vuelve a pendiente si nadie más la tiene).
  Future<void> cerrar(String asignacionId, String estado) =>
      _api.patch<dynamic>(Endpoints.asignacion(asignacionId),
          datos: {'estado': estado});
}
