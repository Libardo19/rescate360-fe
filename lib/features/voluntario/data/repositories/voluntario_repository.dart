import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../datasources/voluntario_remote_datasource.dart';
import '../models/asignacion_model.dart';

class VoluntarioRepository {
  VoluntarioRepository(this._remoto);

  final VoluntarioRemoteDatasource _remoto;

  Future<List<SolicitudAyudaModel>> casosAbiertos() => _remoto.casosAbiertos();

  /// Mis tareas con el detalle de cada solicitud o reporte. [estado] puede ser
  /// `activa`, `finalizada` o `cancelada`; null devuelve todas.
  Future<List<AsignacionModel>> misTareas({String? estado}) async {
    final asignaciones = await _remoto.misAsignaciones(estado: estado);
    return Future.wait(asignaciones.map((a) async {
      try {
        if (a.solicitudId != null) return a.conSolicitud(await _remoto.solicitud(a.solicitudId!));
        if (a.reporteId != null) return a.conSolicitud(await _remoto.reporte(a.reporteId!));
      } catch (_) {}
      return a;
    }));
  }

  Future<void> tomar(SolicitudAyudaModel caso) => _remoto.tomar(caso);

  Future<void> cerrar(String asignacionId, {required bool finalizada}) =>
      _remoto.cerrar(asignacionId, finalizada ? 'finalizada' : 'cancelada');
}

final voluntarioRepositoryProvider = Provider<VoluntarioRepository>((ref) {
  return VoluntarioRepository(
      VoluntarioRemoteDatasource(ref.watch(apiClientProvider)));
});
