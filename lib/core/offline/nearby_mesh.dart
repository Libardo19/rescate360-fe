import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'mensaje_offline.dart';
import 'offline_queue.dart';

/// Relevo por Bluetooth con Google Nearby (prueba de concepto, solo Android).
///
/// Cada teléfono en modo sin conexión anuncia y busca a la vez (estrategia P2P_CLUSTER). Al
/// conectarse dos, cada uno le manda al otro los mensajes que lleva (propios y ajenos); el que
/// recibe guarda los que no conocía con un salto más. El primero que tenga internet los sube.
/// Mientras sigan conectados, lo nuevo (un reporte recién hecho o lo que llegó de un tercero)
/// también se les manda, sin esperar a reconectarse.
class NearbyMesh {
  NearbyMesh(this._cola);

  static const _servicio = 'co.rescate360.mesh';
  final OfflineQueue _cola;
  final _nearby = Nearby();
  final _recibidos = StreamController<int>.broadcast();
  final _conectados = <String>{};
  String? _miUsuarioId;
  bool _activo = false;

  /// Emite cuántos mensajes nuevos llegaron en cada intercambio.
  Stream<int> get recibidos => _recibidos.stream;

  bool get activo => _activo;

  Future<bool> iniciar(
      {required String miUsuarioId, required String nombre}) async {
    if (_activo) return true;
    _miUsuarioId = miUsuarioId;
    final anuncia = await _nearby.startAdvertising(
      nombre,
      Strategy.P2P_CLUSTER,
      serviceId: _servicio,
      onConnectionInitiated: _aceptar,
      onConnectionResult: _alConectar,
      onDisconnected: _conectados.remove,
    );
    final busca = await _nearby.startDiscovery(
      nombre,
      Strategy.P2P_CLUSTER,
      serviceId: _servicio,
      onEndpointFound: (id, _, __) => _nearby.requestConnection(
        nombre,
        id,
        onConnectionInitiated: _aceptar,
        onConnectionResult: _alConectar,
        onDisconnected: _conectados.remove,
      ),
      onEndpointLost: (_) {},
    );
    _activo = anuncia || busca;
    return _activo;
  }

  Future<void> detener() async {
    _activo = false;
    _conectados.clear();
    await _nearby.stopAdvertising();
    await _nearby.stopDiscovery();
    await _nearby.stopAllEndpoints();
  }

  void _aceptar(String endpointId, ConnectionInfo _) {
    _nearby.acceptConnection(endpointId, onPayLoadRecieved: _alRecibir);
  }

  Future<void> _alConectar(String endpointId, Status estado) async {
    if (estado != Status.CONNECTED) return;
    _conectados.add(endpointId);
    await _enviarCola(endpointId);
  }

  /// Manda la cola a los teléfonos que ya están conectados (p. ej. tras encolar un mensaje nuevo).
  /// El que recibe descarta lo que ya conocía.
  Future<void> compartir({String? excepto}) async {
    for (final endpointId in _conectados.toList()) {
      if (endpointId != excepto) await _enviarCola(endpointId);
    }
  }

  Future<void> _enviarCola(String endpointId) async {
    final mensajes = (await _cola.todos()).where((m) => m.relevable).toList();
    if (mensajes.isEmpty) return;
    final bytes =
        utf8.encode(jsonEncode([for (final m in mensajes) m.toJson()]));
    try {
      await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(bytes));
    } catch (_) {
      // Se desconectó mientras tanto: recibirá la cola al volver a conectarse
      _conectados.remove(endpointId);
    }
  }

  Future<void> _alRecibir(String endpointId, Payload payload) async {
    final bytes = payload.bytes;
    if (payload.type != PayloadType.BYTES ||
        bytes == null ||
        _miUsuarioId == null) {
      return;
    }
    try {
      final lista = MensajeOffline.desdeLoteBytes(bytes);
      final nuevos =
          await _cola.agregarAjenos(lista, miUsuarioId: _miUsuarioId!);
      if (nuevos > 0) {
        _recibidos.add(nuevos);
        // Los pasa a los demás conectados, para que sigan saltando hacia alguien con internet
        await compartir(excepto: endpointId);
      }
    } catch (_) {
      // Datos que no son de RESCATE360 o llegaron incompletos: se ignoran
    }
  }
}

final nearbyMeshProvider =
    Provider<NearbyMesh>((ref) => NearbyMesh(ref.watch(offlineQueueProvider)));
