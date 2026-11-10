import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../shared/models/usuario_model.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/sesion_model.dart';

/// Une la API de auth con el almacenamiento seguro: cada sesión nueva queda guardada
/// en el dispositivo y se recupera al abrir la app.
class AuthRepository {
  AuthRepository(this._remoto, this._storage);

  final AuthRemoteDatasource _remoto;
  final SecureStorage _storage;

  Future<UsuarioModel> _guardar(SesionModel sesion) async {
    await _storage.guardarSesion(
      accessToken: sesion.accessToken,
      refreshToken: sesion.refreshToken,
      usuarioJson: jsonEncode(sesion.usuario.toJson()),
    );
    return sesion.usuario;
  }

  Future<UsuarioModel> iniciarSesion(String email, String password) async =>
      _guardar(await _remoto.login(email, password));

  Future<UsuarioModel> registrar({
    required String nombre,
    required String email,
    String? telefono,
    required String password,
  }) async =>
      _guardar(await _remoto.registrar(nombre: nombre, email: email, telefono: telefono, password: password));

  Future<UsuarioModel> activar({required String email, required String codigo, required String password}) async =>
      _guardar(await _remoto.activar(email: email, codigo: codigo, password: password));

  Future<String> pedirCodigoRecuperacion({required String email, required String canal}) =>
      _remoto.recuperar(email: email, canal: canal);

  Future<UsuarioModel> restablecer({required String email, required String codigo, required String password}) async =>
      _guardar(await _remoto.restablecer(email: email, codigo: codigo, password: password));

  /// Al abrir la app: si hay sesión guardada, se valida con GET /usuarios/me (el interceptor
  /// renueva el token si venció). Sin red, se usa el usuario guardado para no sacarlo de la app.
  Future<UsuarioModel?> restaurarSesion() async {
    final guardado = await _storage.usuarioJson();
    if (guardado == null || await _storage.accessToken() == null) return null;
    try {
      final usuario = await _remoto.yo();
      await _storage.guardarSesion(
        accessToken: (await _storage.accessToken())!,
        refreshToken: (await _storage.refreshToken()) ?? '',
        usuarioJson: jsonEncode(usuario.toJson()),
      );
      return usuario;
    } on ApiException catch (e) {
      if (e.codigo == 'SIN_CONEXION') {
        return UsuarioModel.fromJson(jsonDecode(guardado) as Map<String, dynamic>);
      }
      await _storage.borrarSesion();
      return null;
    }
  }

  /// JWT: el backend no guarda sesiones, cerrar sesión es borrar los tokens del dispositivo.
  Future<void> cerrarSesion() => _storage.borrarSesion();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    AuthRemoteDatasource(ref.watch(apiClientProvider)),
    ref.watch(secureStorageProvider),
  );
});
