import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../datasources/guia_emergencia_remote_datasource.dart';
import '../models/guia_model.dart';

class GuiaEmergenciaRepository {
  GuiaEmergenciaRepository(this._remoto);

  final GuiaEmergenciaRemoteDatasource _remoto;

  Future<List<GuiaModel>> listar() => _remoto.listar();
}

final guiaEmergenciaRepositoryProvider = Provider<GuiaEmergenciaRepository>((ref) {
  return GuiaEmergenciaRepository(GuiaEmergenciaRemoteDatasource(ref.watch(apiClientProvider)));
});
