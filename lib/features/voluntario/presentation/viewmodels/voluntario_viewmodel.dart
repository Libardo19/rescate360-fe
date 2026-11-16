import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../../data/models/asignacion_model.dart';
import '../../data/repositories/voluntario_repository.dart';
import 'voluntario_local_viewmodel.dart';

/// Casos abiertos de la organización del voluntario.
final casosOrganizacionProvider =
    FutureProvider.autoDispose<List<SolicitudAyudaModel>>((ref) {
  return ref.watch(voluntarioRepositoryProvider).casosAbiertos();
});

/// Mis tareas activas (asignaciones).
final misTareasProvider =
    FutureProvider.autoDispose<List<AsignacionModel>>((ref) {
  return ref.watch(voluntarioRepositoryProvider).misTareas(estado: 'activa');
});

/// Asignaciones cerradas: finalizadas y canceladas ("Historial").
final historialTareasProvider =
    FutureProvider.autoDispose<List<AsignacionModel>>((ref) async {
  final todas = await ref.watch(voluntarioRepositoryProvider).misTareas();
  final cerradas = todas.where((a) => a.estado != 'activa').toList()
    ..sort((a, b) => b.asignadoEn.compareTo(a.asignadoEn));
  return cerradas;
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
      _ref.invalidate(historialTareasProvider);
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }

  Future<String?> tomar(SolicitudAyudaModel caso) async {
    final error = await _hacer(() => _ref.read(voluntarioRepositoryProvider).tomar(caso));
    if (error == null) {
      _ref.read(disponibilidadProvider.notifier).cambiar(EstadoDisponibilidad.ocupado);
    }
    return error;
  }

  Future<String?> finalizar(String asignacionId) async {
    final quedanOtras = _hayOtrasAsignacionesActivas(asignacionId);
    final error = await _hacer(() => _ref
        .read(voluntarioRepositoryProvider)
        .cerrar(asignacionId, finalizada: true));
    if (error == null && !quedanOtras) {
      _ref.read(disponibilidadProvider.notifier).cambiar(EstadoDisponibilidad.disponible);
    }
    return error;
  }

  Future<String?> soltar(String asignacionId) async {
    final quedanOtras = _hayOtrasAsignacionesActivas(asignacionId);
    final error = await _hacer(() => _ref
        .read(voluntarioRepositoryProvider)
        .cerrar(asignacionId, finalizada: false));
    if (error == null && !quedanOtras) {
      _ref.read(disponibilidadProvider.notifier).cambiar(EstadoDisponibilidad.disponible);
    }
    return error;
  }

  bool _hayOtrasAsignacionesActivas(String asignacionId) =>
      (_ref.read(misTareasProvider).valueOrNull ?? const <AsignacionModel>[])
          .any((a) => a.id != asignacionId && a.estado == 'activa');
}

final voluntarioViewModelProvider =
    Provider<VoluntarioViewModel>((ref) => VoluntarioViewModel(ref));
