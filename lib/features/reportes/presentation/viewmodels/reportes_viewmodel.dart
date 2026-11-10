import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/models/reporte_model.dart';
import '../../data/repositories/reportes_repository.dart';

/// Reportes del ciudadano + verificados de la comunidad, desde la API.
class ReportesCiudadanoViewModel extends AsyncNotifier<List<ReporteCiudadano>> {
  @override
  Future<List<ReporteCiudadano>> build() =>
      ref.read(reportesRepositoryProvider).todos();

  Future<void> recargar() async {
    state = await AsyncValue.guard(
        () => ref.read(reportesRepositoryProvider).todos());
  }

  /// Envía el reporte con sus archivos. Devuelve el mensaje de error, o null si salió bien.
  Future<String?> crear({
    required String tipo,
    required String descripcion,
    required double lat,
    required double lng,
    required List<XFile> archivos,
  }) async {
    try {
      final nuevo = await ref.read(reportesRepositoryProvider).crear(
          tipo: tipo,
          descripcion: descripcion,
          lat: lat,
          lng: lng,
          archivos: archivos);
      state = AsyncData([nuevo, ...?state.valueOrNull]);
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }
}

final reportesCiudadanoProvider =
    AsyncNotifierProvider<ReportesCiudadanoViewModel, List<ReporteCiudadano>>(
        ReportesCiudadanoViewModel.new);

/// Lista sugerida de tipos (GET /reportes/tipos). Si falla, el formulario usa la lista local.
final tiposReporteProvider =
    FutureProvider<List<({String valor, String etiqueta})>>((ref) {
  return ref.read(reportesRepositoryProvider).tipos();
});

/// Detalle completo de un reporte con sus fotos (GET /reportes/{id}). Lo usan el detalle de la
/// pestaña Reportes y la hoja del mapa. El backend lo da si es tuyo o si ya está verificado.
final detalleReporteProvider = FutureProvider.autoDispose.family<ReporteCiudadano, String>(
  (ref, id) => ref.watch(reportesRepositoryProvider).detalle(id),
);
