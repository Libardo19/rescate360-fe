import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/guia_model.dart';
import '../../data/repositories/guia_emergencia_repository.dart';

/// Guía desde el API. Si no hay red o el API falla, devuelve null y la pantalla usa la guía
/// que viene dentro de la app: en una emergencia tiene que leerse sin conexión.
final guiaEmergenciaProvider = FutureProvider.autoDispose<List<GuiaModel>?>((ref) async {
  try {
    final guias = await ref.watch(guiaEmergenciaRepositoryProvider).listar();
    return guias.isEmpty ? null : guias;
  } catch (_) {
    return null;
  }
});
