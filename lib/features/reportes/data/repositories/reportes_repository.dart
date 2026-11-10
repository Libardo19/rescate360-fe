import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../datasources/reportes_remote_datasource.dart';
import '../models/reporte_model.dart';

class ReportesRepository {
  ReportesRepository(this._remoto);

  final ReportesRemoteDatasource _remoto;

  Future<List<({String valor, String etiqueta})>> tipos() => _remoto.tipos();

  Future<ReporteCiudadano> crear({
    required String tipo,
    required String descripcion,
    required double lat,
    required double lng,
    required List<XFile> archivos,
  }) =>
      _remoto.crear(
          tipo: tipo,
          descripcion: descripcion,
          lat: lat,
          lng: lng,
          archivos: archivos);

  /// Los míos primero (con todo el detalle) y luego los verificados de la comunidad.
  Future<List<ReporteCiudadano>> todos() async {
    final resultados =
        await Future.wait([_remoto.misReportes(), _remoto.comunidad()]);
    final mios = resultados[0];
    final idsMios = {for (final r in mios) r.id};
    return [...mios, ...resultados[1].where((r) => !idsMios.contains(r.id))]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }
}

final reportesRepositoryProvider = Provider<ReportesRepository>((ref) {
  return ReportesRepository(
      ReportesRemoteDatasource(ref.watch(apiClientProvider)));
});
