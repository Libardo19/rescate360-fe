import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
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
}

final perfilViewModelProvider = Provider<PerfilViewModel>((ref) => PerfilViewModel(ref));
