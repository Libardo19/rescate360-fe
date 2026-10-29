import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../datasources/donaciones_remote_datasource.dart';
import '../models/donacion_model.dart';

class DonacionesRepository {
  DonacionesRepository(this._remoto);

  final DonacionesRemoteDatasource _remoto;

  Future<List<CampanaModel>> campanas() => _remoto.campanas();
}

final donacionesRepositoryProvider = Provider<DonacionesRepository>((ref) {
  return DonacionesRepository(DonacionesRemoteDatasource(ref.watch(apiClientProvider)));
});
