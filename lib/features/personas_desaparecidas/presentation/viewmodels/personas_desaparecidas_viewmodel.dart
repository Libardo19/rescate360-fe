import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/models/persona_desaparecida.dart';
import '../../data/repositories/personas_desaparecidas_repository.dart';

/// Fichas de personas desaparecidas, desde la API (abiertas primero).
class PersonasViewModel extends AsyncNotifier<List<PersonaDesaparecida>> {
  @override
  Future<List<PersonaDesaparecida>> build() => ref.read(personasRepositoryProvider).listar();

  Future<void> recargar() async {
    state = await AsyncValue.guard(() => ref.read(personasRepositoryProvider).listar());
  }

  /// Publica la ficha. Devuelve el mensaje de error, o null si salió bien.
  Future<String?> crear({
    required String nombre,
    required int edad,
    required String sexo,
    required DateTime fechaVista,
    required String lugar,
    required String descripcion,
    required String contactoNombre,
    required String contactoTelefono,
    String? estatura,
    String? senasParticulares,
    String? vestimenta,
    Uint8List? foto,
  }) async {
    try {
      final nueva = await ref.read(personasRepositoryProvider).crear(
            nombre: nombre,
            edad: edad,
            sexo: sexo,
            fechaVista: fechaVista,
            lugar: lugar,
            descripcion: descripcion,
            contactoNombre: contactoNombre,
            contactoTelefono: contactoTelefono,
            estatura: estatura,
            senasParticulares: senasParticulares,
            vestimenta: vestimenta,
            foto: foto,
          );
      state = AsyncData([nueva, ...?state.valueOrNull]);
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }

  /// Marcar como encontrada o volver a buscando (quien la reportó o un administrador).
  Future<String?> cambiarEstado(String id, EstadoPersona estado) async {
    try {
      final actualizada = await ref.read(personasRepositoryProvider).cambiarEstado(id, estado);
      state = AsyncData([
        for (final p in state.valueOrNull ?? <PersonaDesaparecida>[])
          if (p.id == id) actualizada else p
      ]);
      ref.invalidate(personaDetalleProvider(id));
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }
}

final personasViewModelProvider =
    AsyncNotifierProvider<PersonasViewModel, List<PersonaDesaparecida>>(PersonasViewModel.new);

/// Detalle con el contacto de la familia y el aviso legal (la lista no los trae).
final personaDetalleProvider =
    FutureProvider.autoDispose.family<PersonaDesaparecida, String>((ref, id) {
  return ref.read(personasRepositoryProvider).detalle(id);
});
