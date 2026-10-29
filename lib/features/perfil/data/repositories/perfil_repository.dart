import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/usuario_model.dart';
import '../datasources/perfil_remote_datasource.dart';
import '../models/contacto_emergencia_model.dart';

class PerfilRepository {
  PerfilRepository(this._remoto);

  final PerfilRemoteDatasource _remoto;

  Future<UsuarioModel> actualizar({String? nombre, String? telefono}) =>
      _remoto.actualizar(nombre: nombre, telefono: telefono);

  Future<void> cambiarContrasena({required String actual, required String nueva}) =>
      _remoto.cambiarContrasena(actual: actual, nueva: nueva);

  Future<bool?> autorizaUbicacion() => _remoto.autorizaUbicacion();

  Future<void> autorizarUbicacion(bool aceptado) => _remoto.autorizarUbicacion(aceptado);

  Future<List<ContactoEmergencia>> contactos() => _remoto.contactos();

  Future<ContactoEmergencia> guardarContacto(
          {String? id, required String nombre, required String telefono, String? parentesco}) =>
      id == null
          ? _remoto.crearContacto(nombre: nombre, telefono: telefono, parentesco: parentesco)
          : _remoto.editarContacto(id, nombre: nombre, telefono: telefono, parentesco: parentesco);

  Future<void> eliminarContacto(String id) => _remoto.eliminarContacto(id);

  Future<ResumenMisDatos> misDatos() => _remoto.misDatos();

  Future<void> eliminarCuenta(String password) => _remoto.eliminarCuenta(password);
}

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  return PerfilRepository(PerfilRemoteDatasource(ref.watch(apiClientProvider)));
});
