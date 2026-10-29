import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import 'offline_queue.dart';

/// Sube la cola cuando hay internet: los propios a /offline/sync y los ajenos (que llegaron por
/// Bluetooth) a /offline/relevo. Lo que el backend aceptó, ya tenía o rechazó se quita de la cola.
class SyncWorker {
  SyncWorker(this._api, this._cola);

  final ApiClient _api;
  final OfflineQueue _cola;

  /// Devuelve cuántos mensajes se entregaron. Si no hay red, lanza el error de la API.
  Future<int> subir() async {
    var entregados = 0;
    for (final (ruta, mensajes) in [
      (Endpoints.offlineSync, await _cola.propios()),
      (Endpoints.offlineRelevo, await _cola.ajenos()),
    ]) {
      if (mensajes.isEmpty) continue;
      final respuesta = await _api.post<Map<String, dynamic>>(ruta, datos: {
        'mensajes': [for (final m in mensajes) m.toJson()],
      });
      entregados += (respuesta['aceptados'] as int) + (respuesta['duplicados'] as int);
      // Todo lo enviado ya tuvo respuesta: aceptado, repetido o rechazado (firma, vencido…)
      await _cola.quitar({for (final m in mensajes) m.uuidOrigen});
    }
    return entregados;
  }
}

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  return SyncWorker(ref.watch(apiClientProvider), ref.watch(offlineQueueProvider));
});
