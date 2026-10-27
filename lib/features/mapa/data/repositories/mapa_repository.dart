import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../datasources/mapa_remote_datasource.dart';
import '../models/marcador_mapa_model.dart';

class MapaRepository {
  MapaRepository(this._remoto);

  final MapaRemoteDatasource _remoto;

  Future<RespuestaMapa> puntos({required double lat, required double lng, String? desde}) =>
      _remoto.puntos(lat: lat, lng: lng, desde: desde);

  Future<void> enviarMiUbicacion(double lat, double lng) => _remoto.enviarMiUbicacion(lat, lng);
}

final mapaRepositoryProvider = Provider<MapaRepository>((ref) {
  return MapaRepository(MapaRemoteDatasource(ref.watch(apiClientProvider)));
});
