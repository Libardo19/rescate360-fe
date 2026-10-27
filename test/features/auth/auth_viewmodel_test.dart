import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/core/errors/exceptions.dart';
import 'package:rescate360/features/auth/data/repositories/auth_repository.dart';
import 'package:rescate360/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:rescate360/shared/models/rol.dart';
import 'package:rescate360/shared/models/usuario_model.dart';

/// Repositorio falso: responde lo que la prueba le diga, sin red ni almacenamiento.
class _RepoFalso implements AuthRepository {
  _RepoFalso({this.usuario, this.error});

  final UsuarioModel? usuario;
  final ApiException? error;
  bool cerroSesion = false;

  Future<UsuarioModel> _responder() async {
    if (error != null) throw error!;
    return usuario!;
  }

  @override
  Future<UsuarioModel> iniciarSesion(String email, String password) => _responder();

  @override
  Future<UsuarioModel> registrar({required String nombre, required String email, String? telefono, required String password}) =>
      _responder();

  @override
  Future<UsuarioModel> activar({required String email, required String codigo, required String password}) => _responder();

  @override
  Future<UsuarioModel> restablecer({required String email, required String codigo, required String password}) => _responder();

  @override
  Future<String> pedirCodigoRecuperacion({required String email, required String canal}) async => 'Te enviamos un código.';

  @override
  Future<UsuarioModel?> restaurarSesion() async => usuario;

  @override
  Future<void> cerrarSesion() async => cerroSesion = true;
}

UsuarioModel _usuario(Rol rol) => UsuarioModel(id: 'u1', nombre: 'Ana Pérez', correo: 'ana@demo.co', rol: rol);

void main() {
  test('login de un ciudadano deja la sesión abierta', () async {
    final vm = AuthViewModel(_RepoFalso(usuario: _usuario(Rol.ciudadano)));
    expect(await vm.iniciarSesion(correo: 'Ana@Demo.co', password: 'clave-123'), isTrue);
    expect(vm.state.usuario?.nombre, 'Ana Pérez');
    expect(rutaInicio(vm.state.usuario!.rol), '/home');
  });

  test('el voluntario entra a su propio inicio', () async {
    final vm = AuthViewModel(_RepoFalso(usuario: _usuario(Rol.voluntario)));
    await vm.activar(correo: 'ana@demo.co', codigo: 'ABCD-EFGH', password: 'clave-123');
    expect(rutaInicio(vm.state.usuario!.rol), '/voluntario');
  });

  test('un administrador no entra a la app: se le manda al panel web', () async {
    final repo = _RepoFalso(usuario: _usuario(Rol.administrador));
    final vm = AuthViewModel(repo);
    expect(await vm.iniciarSesion(correo: 'admin@demo.co', password: 'clave-123'), isFalse);
    expect(vm.state.autenticado, isFalse);
    expect(vm.state.error, contains('panel web'));
    expect(repo.cerroSesion, isTrue);
  });

  test('el error del backend se muestra tal cual', () async {
    final vm = AuthViewModel(_RepoFalso(
      error: const ApiException(codigo: 'CUENTA_BLOQUEADA', detalle: 'Tu cuenta está bloqueada'),
    ));
    expect(await vm.iniciarSesion(correo: 'ana@demo.co', password: 'x'), isFalse);
    expect(vm.state.error, 'Tu cuenta está bloqueada');
  });

  test('cerrar sesión limpia el estado', () async {
    final repo = _RepoFalso(usuario: _usuario(Rol.ciudadano));
    final vm = AuthViewModel(repo);
    await vm.restaurarSesion();
    expect(vm.state.autenticado, isTrue);
    await vm.cerrarSesion();
    expect(vm.state.autenticado, isFalse);
    expect(repo.cerroSesion, isTrue);
  });
}
