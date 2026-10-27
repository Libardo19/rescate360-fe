import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../shared/models/usuario_model.dart';

class PerfilRemoteDatasource {
  PerfilRemoteDatasource(this._api);

  final ApiClient _api;

  Future<UsuarioModel> actualizar({String? nombre, String? telefono}) async =>
      UsuarioModel.fromJson(await _api.patch<Map<String, dynamic>>(Endpoints.yo, datos: {
        if (nombre != null) 'nombre': nombre,
        if (telefono != null) 'telefono': telefono,
      }));

  Future<void> cambiarContrasena({required String actual, required String nueva}) =>
      _api.patch<dynamic>(Endpoints.miPassword, datos: {'password_actual': actual, 'password_nueva': nueva});

  /// Última decisión del usuario sobre compartir su ubicación (Ley 1581): true, false o null si nunca decidió.
  Future<bool?> autorizaUbicacion() async {
    final historial = (await _api.get<List<dynamic>>(Endpoints.misConsentimientos)).cast<Map<String, dynamic>>();
    final deUbicacion = historial.where((c) => c['tipo'] == 'ubicacion').toList()
      ..sort((a, b) => (b['creado_en'] as String).compareTo(a['creado_en'] as String));
    return deUbicacion.isEmpty ? null : deUbicacion.first['aceptado'] as bool;
  }

  /// Dar o retirar la autorización. Al retirarla, el backend borra la ubicación guardada.
  Future<void> autorizarUbicacion(bool aceptado) =>
      _api.post<dynamic>(Endpoints.misConsentimientos, datos: {'tipo': 'ubicacion', 'aceptado': aceptado});
}
