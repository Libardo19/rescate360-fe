import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/check_in_model.dart';

class CheckInRemoteDatasource {
  CheckInRemoteDatasource(this._api);

  final ApiClient _api;

  Future<CheckInModel?> pendiente() async {
    final json = await _api.get<Map<String, dynamic>?>(Endpoints.checkInPendiente);
    return json == null ? null : CheckInModel.fromJson(json);
  }

  /// "Modo emergencia": que me pregunten si estoy bien en unos minutos.
  Future<CheckInModel> activar({double? lat, double? lng}) async => CheckInModel.fromJson(
      await _api.post<Map<String, dynamic>>(Endpoints.checkIns, datos: {
        if (lat != null && lng != null) 'ubicacion': {'lat': lat, 'lng': lng},
      }));

  Future<CheckInModel> responder(String id, {required bool aSalvo, double? lat, double? lng}) async =>
      CheckInModel.fromJson(await _api.post<Map<String, dynamic>>(Endpoints.responderCheckIn(id), datos: {
        'estado': aSalvo ? 'a_salvo' : 'necesito_ayuda',
        if (lat != null && lng != null) 'ubicacion': {'lat': lat, 'lng': lng},
      }));
}
