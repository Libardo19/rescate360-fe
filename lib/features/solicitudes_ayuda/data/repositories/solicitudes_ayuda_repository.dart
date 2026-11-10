import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../datasources/solicitudes_ayuda_remote_datasource.dart';
import '../models/solicitud_ayuda_model.dart';

/// Hoy delega en la API. Aquí se sumará la cola offline (SOS sin señal) cuando exista.
class SolicitudesAyudaRepository {
  SolicitudesAyudaRepository(this._remoto);

  final SolicitudesAyudaRemoteDatasource _remoto;

  Future<SolicitudAyudaModel> crear({
    required String tipo,
    required String descripcion,
    required double lat,
    required double lng,
  }) =>
      _remoto.crear(tipo: tipo, descripcion: descripcion, lat: lat, lng: lng);

  Future<SolicitudAyudaModel> sos({required double lat, required double lng}) => _remoto.sos(lat: lat, lng: lng);

  Future<List<SolicitudAyudaModel>> misSolicitudes() => _remoto.misSolicitudes();

  Future<SolicitudAyudaModel> cancelar(String id) => _remoto.cancelar(id);
}

final solicitudesAyudaRepositoryProvider = Provider<SolicitudesAyudaRepository>((ref) {
  return SolicitudesAyudaRepository(SolicitudesAyudaRemoteDatasource(ref.watch(apiClientProvider)));
});
