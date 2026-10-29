import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../datasources/check_in_remote_datasource.dart';
import '../models/check_in_model.dart';

class CheckInRepository {
  CheckInRepository(this._remoto);

  final CheckInRemoteDatasource _remoto;

  Future<CheckInModel?> pendiente() => _remoto.pendiente();

  Future<CheckInModel> activar({double? lat, double? lng}) => _remoto.activar(lat: lat, lng: lng);

  Future<CheckInModel> responder(String id, {required bool aSalvo, double? lat, double? lng}) =>
      _remoto.responder(id, aSalvo: aSalvo, lat: lat, lng: lng);
}

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return CheckInRepository(CheckInRemoteDatasource(ref.watch(apiClientProvider)));
});
