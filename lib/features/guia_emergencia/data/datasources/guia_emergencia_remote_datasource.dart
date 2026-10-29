import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/guia_model.dart';

class GuiaEmergenciaRemoteDatasource {
  GuiaEmergenciaRemoteDatasource(this._api);

  final ApiClient _api;

  Future<List<GuiaModel>> listar() async => [
        for (final g in (await _api.get<List<dynamic>>(Endpoints.guia)).cast<Map<String, dynamic>>())
          GuiaModel.fromJson(g)
      ];
}
