import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/rol.dart';
import '../../../../shared/models/usuario_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Estado de autenticación de la app.
class AuthState {
  final bool loading;
  final String? error;
  final UsuarioModel? usuario;

  const AuthState({this.loading = false, this.error, this.usuario});

  AuthState copyWith({bool? loading, String? error, UsuarioModel? usuario}) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error,
      usuario: usuario ?? this.usuario,
    );
  }

  bool get autenticado => usuario != null;
}

/// Ruta de inicio según el rol: el ciudadano va a su app y el voluntario a sus casos y tareas.
String rutaInicio(Rol rol) => rol == Rol.voluntario ? '/voluntario' : '/home';

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  static const _soloPanel =
      'Tu cuenta es de administrador: entra desde el panel web de RESCATE360.';

  /// Ejecuta una acción de auth y deja el usuario o el error en el estado.
  Future<bool> _autenticar(Future<UsuarioModel> Function() accion) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final usuario = await accion();
      if (usuario.rol.usaPanelWeb) {
        await _repo.cerrarSesion();
        state = const AuthState(error: _soloPanel);
        return false;
      }
      state = AuthState(usuario: usuario);
      return true;
    } catch (e) {
      state = AuthState(error: ApiException.desde(e).mensaje);
      return false;
    }
  }

  Future<bool> iniciarSesion({required String correo, required String password}) =>
      _autenticar(() => _repo.iniciarSesion(correo.toLowerCase(), password));

  Future<bool> registrar({
    required String nombre,
    required String correo,
    String? telefono,
    required String password,
  }) =>
      _autenticar(() => _repo.registrar(
            nombre: nombre,
            email: correo.toLowerCase(),
            telefono: telefono,
            password: password,
          ));

  /// Voluntario invitado: correo + código que le entregó su administrador + contraseña nueva.
  Future<bool> activar({required String correo, required String codigo, required String password}) =>
      _autenticar(() => _repo.activar(email: correo.toLowerCase(), codigo: codigo, password: password));

  Future<bool> restablecer({required String correo, required String codigo, required String password}) =>
      _autenticar(() => _repo.restablecer(email: correo.toLowerCase(), codigo: codigo, password: password));

  /// Devuelve el mensaje del backend (es el mismo exista o no la cuenta).
  Future<String?> pedirCodigoRecuperacion({required String correo, required String canal}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final mensaje = await _repo.pedirCodigoRecuperacion(email: correo.toLowerCase(), canal: canal);
      state = state.copyWith(loading: false);
      return mensaje;
    } catch (e) {
      state = state.copyWith(loading: false, error: ApiException.desde(e).mensaje);
      return null;
    }
  }

  /// Al abrir la app: true si había una sesión válida guardada.
  Future<bool> restaurarSesion() async {
    final usuario = await _repo.restaurarSesion();
    if (usuario == null || usuario.rol.usaPanelWeb) return false;
    state = AuthState(usuario: usuario);
    return true;
  }

  Future<void> cerrarSesion() async {
    await _repo.cerrarSesion();
    state = const AuthState();
  }

  void limpiarError() => state = state.copyWith(error: null);
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final viewModel = AuthViewModel(ref.watch(authRepositoryProvider));
  // Si el token venció y no se pudo renovar, el estado vuelve a "sin sesión"
  ref.listen<int>(sesionExpiradaProvider, (_, __) => viewModel.cerrarSesion());
  return viewModel;
});
