import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/models/contacto_emergencia_model.dart';
import '../../data/repositories/perfil_repository.dart';

/// ¿El usuario autorizó compartir su ubicación? (null = nunca lo decidió)
final autorizaUbicacionProvider = FutureProvider.autoDispose<bool?>((ref) {
  return ref.watch(perfilRepositoryProvider).autorizaUbicacion();
});

/// Acciones de "Mis datos". Devuelven el mensaje de error, o null si salió bien.
class PerfilViewModel {
  PerfilViewModel(this._ref);

  final Ref _ref;

  PerfilRepository get _repo => _ref.read(perfilRepositoryProvider);

  Future<String?> _hacer(Future<void> Function() accion) async {
    try {
      await accion();
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }

  Future<String?> guardarDatos({required String nombre, String? telefono}) => _hacer(() async {
        final usuario = await _repo.actualizar(nombre: nombre, telefono: telefono);
        _ref.read(authViewModelProvider.notifier).actualizarUsuario(usuario);
      });

  Future<String?> cambiarContrasena({required String actual, required String nueva}) =>
      _hacer(() => _repo.cambiarContrasena(actual: actual, nueva: nueva));

  Future<String?> autorizarUbicacion(bool aceptado) => _hacer(() async {
        await _repo.autorizarUbicacion(aceptado);
        _ref.invalidate(autorizaUbicacionProvider);
      });

  /// Ley 1581: borra (anonimiza) la cuenta y cierra la sesión.
  Future<String?> eliminarCuenta(String password) => _hacer(() async {
        await _repo.eliminarCuenta(password);
        await _ref.read(authViewModelProvider.notifier).cerrarSesion();
      });
}

/// Resumen de lo que RESCATE360 guarda de mí (GET /usuarios/me/datos).
final misDatosProvider = FutureProvider.autoDispose<ResumenMisDatos>((ref) {
  return ref.watch(perfilRepositoryProvider).misDatos();
});

/// Mis contactos de emergencia, desde la API.
class ContactosViewModel extends AsyncNotifier<List<ContactoEmergencia>> {
  @override
  Future<List<ContactoEmergencia>> build() => ref.read(perfilRepositoryProvider).contactos();

  Future<void> recargar() async {
    state = await AsyncValue.guard(() => ref.read(perfilRepositoryProvider).contactos());
  }

  /// Crea (id null) o edita. Devuelve el mensaje de error, o null si salió bien.
  Future<String?> guardar({String? id, required String nombre, required String telefono, String? parentesco}) async {
    try {
      final guardado = await ref
          .read(perfilRepositoryProvider)
          .guardarContacto(id: id, nombre: nombre, telefono: telefono, parentesco: parentesco);
      final actuales = state.valueOrNull ?? const <ContactoEmergencia>[];
      state = AsyncData(id == null
          ? [...actuales, guardado]
          : [for (final c in actuales) if (c.id == id) guardado else c]);
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }

  Future<String?> eliminar(String id) async {
    try {
      await ref.read(perfilRepositoryProvider).eliminarContacto(id);
      state = AsyncData([for (final c in state.valueOrNull ?? const <ContactoEmergencia>[]) if (c.id != id) c]);
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }
}

final contactosProvider =
    AsyncNotifierProvider<ContactosViewModel, List<ContactoEmergencia>>(ContactosViewModel.new);

final perfilViewModelProvider = Provider<PerfilViewModel>((ref) => PerfilViewModel(ref));
