import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../datasources/alertas_remote_datasource.dart';
import '../models/alerta_model.dart';

class AlertasRepository {
  AlertasRepository(this._remoto);

  final AlertasRemoteDatasource _remoto;

  Future<List<AlertaModel>> activas({double? lat, double? lng}) => _remoto.activas(lat: lat, lng: lng);
}

final alertasRepositoryProvider = Provider<AlertasRepository>((ref) {
  return AlertasRepository(AlertasRemoteDatasource(ref.watch(apiClientProvider)));
});
