import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../shared/models/usuario_model.dart';
import '../models/contacto_emergencia_model.dart';

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

  // --- Contactos de emergencia (máximo 5; reciben el SMS del SOS) ---

  Future<List<ContactoEmergencia>> contactos() async => [
        for (final c in (await _api.get<List<dynamic>>(Endpoints.misContactos)).cast<Map<String, dynamic>>())
          ContactoEmergencia.fromJson(c)
      ];

  Future<ContactoEmergencia> crearContacto({required String nombre, required String telefono, String? parentesco}) async =>
      ContactoEmergencia.fromJson(await _api.post<Map<String, dynamic>>(Endpoints.misContactos,
          datos: {'nombre': nombre, 'telefono': telefono, 'parentesco': parentesco}));

  Future<ContactoEmergencia> editarContacto(String id,
          {required String nombre, required String telefono, String? parentesco}) async =>
      ContactoEmergencia.fromJson(await _api.patch<Map<String, dynamic>>(Endpoints.miContacto(id),
          datos: {'nombre': nombre, 'telefono': telefono, 'parentesco': parentesco}));

  Future<void> eliminarContacto(String id) => _api.delete<dynamic>(Endpoints.miContacto(id));

  // --- Ley 1581 ---

  Future<ResumenMisDatos> misDatos() async =>
      ResumenMisDatos.fromJson(await _api.get<Map<String, dynamic>>(Endpoints.misDatos));

  /// Anonimiza la cuenta y la bloquea. Pide la contraseña.
  Future<void> eliminarCuenta(String password) => _api.delete<dynamic>(Endpoints.yo, datos: {'password': password});
}
