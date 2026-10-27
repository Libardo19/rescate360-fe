import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../shared/models/usuario_model.dart';
import '../models/sesion_model.dart';

/// Llamadas HTTP de autenticación. Sin lógica: solo arma el cuerpo y lee la respuesta.
class AuthRemoteDatasource {
  AuthRemoteDatasource(this._api);

  final ApiClient _api;

  Future<SesionModel> login(String email, String password) async => SesionModel.fromJson(
        await _api.post<Map<String, dynamic>>(Endpoints.login, datos: {'email': email, 'password': password}),
      );

  /// Autorregistro: siempre crea un ciudadano. El consentimiento es obligatorio (Ley 1581).
  Future<SesionModel> registrar({
    required String nombre,
    required String email,
    String? telefono,
    required String password,
  }) async =>
      SesionModel.fromJson(await _api.post<Map<String, dynamic>>(Endpoints.registro, datos: {
        'nombre': nombre,
        'email': email,
        if (telefono != null) 'telefono': telefono,
        'password': password,
        'acepta_tratamiento_datos': true,
      }));

  /// Voluntario o administrador invitado: canjea el código que le dio su administrador.
  Future<SesionModel> activar({required String email, required String codigo, required String password}) async =>
      SesionModel.fromJson(await _api.post<Map<String, dynamic>>(Endpoints.activar, datos: {
        'email': email,
        'codigo': codigo,
        'password': password,
        'acepta_tratamiento_datos': true,
      }));

  /// Siempre responde lo mismo (no revela si el correo existe).
  Future<String> recuperar({required String email, required String canal}) async {
    final r = await _api.post<Map<String, dynamic>>(Endpoints.recuperar, datos: {'email': email, 'canal': canal});
    return r['detalle'] as String;
  }

  Future<SesionModel> restablecer({required String email, required String codigo, required String password}) async =>
      SesionModel.fromJson(await _api.post<Map<String, dynamic>>(
        Endpoints.restablecer,
        datos: {'email': email, 'codigo': codigo, 'password': password},
      ));

  Future<UsuarioModel> yo() async => UsuarioModel.fromJson(await _api.get<Map<String, dynamic>>(Endpoints.yo));
}
