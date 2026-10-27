import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../datasources/voluntario_remote_datasource.dart';
import '../models/asignacion_model.dart';

class VoluntarioRepository {
  VoluntarioRepository(this._remoto);

  final VoluntarioRemoteDatasource _remoto;

  Future<List<SolicitudAyudaModel>> casosAbiertos() => _remoto.casosAbiertos();

  /// Mis tareas activas con el detalle de cada solicitud.
  Future<List<AsignacionModel>> misTareas() async {
    final asignaciones = await _remoto.misAsignaciones();
    return Future.wait(asignaciones.map((a) async {
      if (a.solicitudId == null) return a; // reportes: solo se muestra la tarea
      try {
        return a.conSolicitud(await _remoto.solicitud(a.solicitudId!));
      } catch (_) {
        return a;
      }
    }));
  }

  Future<void> tomar(String solicitudId) => _remoto.tomar(solicitudId);

  Future<void> cerrar(String asignacionId, {required bool finalizada}) =>
      _remoto.cerrar(asignacionId, finalizada ? 'finalizada' : 'cancelada');
}

final voluntarioRepositoryProvider = Provider<VoluntarioRepository>((ref) {
  return VoluntarioRepository(VoluntarioRemoteDatasource(ref.watch(apiClientProvider)));
});
