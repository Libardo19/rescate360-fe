import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/usuario_model.dart';

/// Estado de autenticación. Por ahora se resuelve con datos mock
/// (ver TODOs); cuando exista el backend, [AuthViewModel] pasará a llamar
/// a auth_repository.dart -> auth_remote_datasource.dart en su lugar.
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

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel() : super(const AuthState());

  /// Login mock: simula una llamada de red y autentica a cualquier
  /// correo/contraseña que cumplan las validaciones del formulario.
  /// TODO(backend): reemplazar por auth_repository.iniciarSesion(correo, password).
  Future<bool> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 700));

    final usuario = UsuarioModel.mock(
      nombre: correo.split('@').first,
      correo: correo,
    );
    state = state.copyWith(loading: false, usuario: usuario);
    return true;
  }

  /// Registro mock: valida y "crea" la cuenta localmente.
  /// TODO(backend): reemplazar por auth_repository.registrar(...).
  Future<bool> registrar({
    required String nombre,
    required String correo,
    String? telefono,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 700));

    final usuario = UsuarioModel.mock(
      nombre: nombre,
      correo: correo,
      telefono: telefono,
    );
    state = state.copyWith(loading: false, usuario: usuario);
    return true;
  }

  void cerrarSesion() {
    state = const AuthState();
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel();
});
