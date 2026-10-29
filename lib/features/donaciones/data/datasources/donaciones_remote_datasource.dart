import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/donacion_model.dart';

class DonacionesRemoteDatasource {
  DonacionesRemoteDatasource(this._api);

  final ApiClient _api;

  /// Campañas vigentes (activas y sin vencer).
  Future<List<CampanaModel>> campanas() async => [
        for (final c in (await _api.get<List<dynamic>>(Endpoints.campanas)).cast<Map<String, dynamic>>())
          CampanaModel.fromJson(c)
      ];
}
