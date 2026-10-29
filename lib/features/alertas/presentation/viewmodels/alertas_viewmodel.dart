import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/location/location_service.dart';
import '../../data/models/alerta_model.dart';
import '../../data/repositories/alertas_repository.dart';

/// Alertas activas en mi zona (las que cubren mi ubicación) y todas las activas.
/// Sin permiso de ubicación, "en mi zona" queda en null y la pantalla lo explica.
class AlertasData {
  final List<AlertaModel>? enMiZona;
  final List<AlertaModel> todas;

  const AlertasData({required this.enMiZona, required this.todas});
}

final alertasProvider = FutureProvider.autoDispose<AlertasData>((ref) async {
  final repo = ref.watch(alertasRepositoryProvider);
  ({double lat, double lng})? posicion;
  try {
    posicion = await ref.read(locationServiceProvider).ubicacionActual();
  } on UbicacionException {
    posicion = null;
  }
  final resultados = await Future.wait([
    repo.activas(),
    if (posicion != null) repo.activas(lat: posicion.lat, lng: posicion.lng),
  ]);
  return AlertasData(todas: resultados[0], enMiZona: posicion == null ? null : resultados[1]);
});
