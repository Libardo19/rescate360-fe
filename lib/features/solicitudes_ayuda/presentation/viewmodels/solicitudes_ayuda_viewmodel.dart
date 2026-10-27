import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/location/location_service.dart';
import '../../data/models/solicitud_ayuda_model.dart';
import '../../data/repositories/solicitudes_ayuda_repository.dart';

/// Resultado de una acción: la solicitud creada/actualizada o el mensaje de error.
typedef Resultado = ({SolicitudAyudaModel? solicitud, String? error});

/// Mis solicitudes (lista con "jalar para actualizar").
final misSolicitudesProvider = FutureProvider.autoDispose<List<SolicitudAyudaModel>>((ref) {
  return ref.watch(solicitudesAyudaRepositoryProvider).misSolicitudes();
});

/// Acciones del ciudadano: pedir ayuda, SOS y cancelar.
class SolicitudesAyudaViewModel {
  SolicitudesAyudaViewModel(this._ref);

  final Ref _ref;

  SolicitudesAyudaRepository get _repo => _ref.read(solicitudesAyudaRepositoryProvider);

  Future<Resultado> _hacer(Future<SolicitudAyudaModel> Function() accion) async {
    try {
      final solicitud = await accion();
      _ref.invalidate(misSolicitudesProvider);
      return (solicitud: solicitud, error: null);
    } on UbicacionException catch (e) {
      return (solicitud: null, error: e.mensaje);
    } catch (e) {
      return (solicitud: null, error: ApiException.desde(e).mensaje);
    }
  }

  Future<Resultado> pedirAyuda({
    required String tipo,
    required String descripcion,
    required double lat,
    required double lng,
  }) =>
      _hacer(() => _repo.crear(tipo: tipo, descripcion: descripcion, lat: lat, lng: lng));

  /// Lee el GPS en el momento y envía el SOS.
  Future<Resultado> enviarSos() => _hacer(() async {
        final posicion = await _ref.read(locationServiceProvider).ubicacionActual();
        return _repo.sos(lat: posicion.lat, lng: posicion.lng);
      });

  Future<Resultado> cancelar(String id) => _hacer(() => _repo.cancelar(id));
}

final solicitudesAyudaViewModelProvider = Provider<SolicitudesAyudaViewModel>((ref) => SolicitudesAyudaViewModel(ref));
