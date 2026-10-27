import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../../data/models/asignacion_model.dart';
import '../../data/repositories/voluntario_repository.dart';

/// Casos abiertos de la organización del voluntario.
final casosOrganizacionProvider = FutureProvider.autoDispose<List<SolicitudAyudaModel>>((ref) {
  return ref.watch(voluntarioRepositoryProvider).casosAbiertos();
});

/// Mis tareas activas (asignaciones).
final misTareasProvider = FutureProvider.autoDispose<List<AsignacionModel>>((ref) {
  return ref.watch(voluntarioRepositoryProvider).misTareas();
});

/// Acciones del voluntario. Devuelven el mensaje de error, o null si salió bien.
class VoluntarioViewModel {
  VoluntarioViewModel(this._ref);

  final Ref _ref;

  Future<String?> _hacer(Future<void> Function() accion) async {
    try {
      await accion();
      _ref.invalidate(casosOrganizacionProvider);
      _ref.invalidate(misTareasProvider);
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }

  Future<String?> tomar(String solicitudId) => _hacer(() => _ref.read(voluntarioRepositoryProvider).tomar(solicitudId));

  Future<String?> finalizar(String asignacionId) =>
      _hacer(() => _ref.read(voluntarioRepositoryProvider).cerrar(asignacionId, finalizada: true));

  Future<String?> soltar(String asignacionId) =>
      _hacer(() => _ref.read(voluntarioRepositoryProvider).cerrar(asignacionId, finalizada: false));
}

final voluntarioViewModelProvider = Provider<VoluntarioViewModel>((ref) => VoluntarioViewModel(ref));
