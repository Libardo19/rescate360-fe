import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/usuario_model.dart';
import '../datasources/perfil_remote_datasource.dart';

class PerfilRepository {
  PerfilRepository(this._remoto);

  final PerfilRemoteDatasource _remoto;

  Future<UsuarioModel> actualizar({String? nombre, String? telefono}) =>
      _remoto.actualizar(nombre: nombre, telefono: telefono);

  Future<void> cambiarContrasena({required String actual, required String nueva}) =>
      _remoto.cambiarContrasena(actual: actual, nueva: nueva);

  Future<bool?> autorizaUbicacion() => _remoto.autorizaUbicacion();

  Future<void> autorizarUbicacion(bool aceptado) => _remoto.autorizarUbicacion(aceptado);
}

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  return PerfilRepository(PerfilRemoteDatasource(ref.watch(apiClientProvider)));
});
