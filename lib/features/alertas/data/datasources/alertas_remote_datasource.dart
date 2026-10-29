import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/alerta_model.dart';

class AlertasRemoteDatasource {
  AlertasRemoteDatasource(this._api);

  final ApiClient _api;

  /// Activas. Con lat y lng: solo las que cubren ese punto (las de mi zona).
  Future<List<AlertaModel>> activas({double? lat, double? lng}) async {
    final pagina = await _api.get<Map<String, dynamic>>(Endpoints.alertas, query: {
      'por_pagina': 100,
      if (lat != null && lng != null) ...{'lat': lat, 'lng': lng},
    });
    return [
      for (final a in (pagina['items'] as List).cast<Map<String, dynamic>>()) AlertaModel.fromJson(a)
    ];
  }
}
