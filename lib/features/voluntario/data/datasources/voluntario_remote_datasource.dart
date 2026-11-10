import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../models/asignacion_model.dart';

class VoluntarioRemoteDatasource {
  VoluntarioRemoteDatasource(this._api);

  final ApiClient _api;

  /// Casos abiertos de la organización del voluntario: solicitudes de ayuda y reportes de
  /// incidentes (para el voluntario, el backend ya filtra por su organización).
  Future<List<SolicitudAyudaModel>> casosAbiertos() async {
    final paginas = await Future.wait([
      _api.get<Map<String, dynamic>>(Endpoints.solicitudes, query: {'por_pagina': 100}),
      _api.get<Map<String, dynamic>>(Endpoints.reportes, query: {'por_pagina': 100}),
    ]);
    final casos = [
      for (final s in (paginas[0]['items'] as List).cast<Map<String, dynamic>>())
        SolicitudAyudaModel.fromJson(s),
      for (final r in (paginas[1]['items'] as List).cast<Map<String, dynamic>>())
        SolicitudAyudaModel.desdeReporte(r),
    ].where((c) => c.cancelable).toList()
      ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
    return casos;
  }

  Future<SolicitudAyudaModel> solicitud(String id) async =>
      SolicitudAyudaModel.fromJson(
          await _api.get<Map<String, dynamic>>('${Endpoints.solicitudes}/$id'));

  Future<SolicitudAyudaModel> reporte(String id) async =>
      SolicitudAyudaModel.desdeReporte(await _api.get<Map<String, dynamic>>(Endpoints.reporte(id)));

  /// El voluntario toma el caso: la solicitud pasa a "en proceso"; el reporte queda asignado a él.
  Future<void> tomar(SolicitudAyudaModel caso) => _api.post<dynamic>(
      caso.esReporte ? Endpoints.tomarReporte(caso.id) : Endpoints.tomarSolicitud(caso.id));

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
