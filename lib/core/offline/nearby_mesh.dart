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
class NearbyMesh {
  NearbyMesh(this._cola);

  static const _servicio = 'co.rescate360.mesh';
  final OfflineQueue _cola;
  final _nearby = Nearby();
  final _recibidos = StreamController<int>.broadcast();
  String? _miUsuarioId;
  bool _activo = false;

  /// Emite cuántos mensajes nuevos llegaron en cada intercambio.
  Stream<int> get recibidos => _recibidos.stream;

  bool get activo => _activo;

  Future<bool> iniciar({required String miUsuarioId, required String nombre}) async {
    if (_activo) return true;
    _miUsuarioId = miUsuarioId;
    final anuncia = await _nearby.startAdvertising(
      nombre,
      Strategy.P2P_CLUSTER,
      serviceId: _servicio,
      onConnectionInitiated: _aceptar,
      onConnectionResult: _alConectar,
      onDisconnected: (_) {},
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
        onDisconnected: (_) {},
      ),
      onEndpointLost: (_) {},
    );
    _activo = anuncia || busca;
    return _activo;
  }

  Future<void> detener() async {
    _activo = false;
    await _nearby.stopAdvertising();
    await _nearby.stopDiscovery();
    await _nearby.stopAllEndpoints();
  }

  void _aceptar(String endpointId, ConnectionInfo _) {
    _nearby.acceptConnection(endpointId, onPayLoadRecieved: _alRecibir);
  }

  Future<void> _alConectar(String endpointId, Status estado) async {
    if (estado != Status.CONNECTED) return;
    final mensajes = (await _cola.todos()).where((m) => m.relevable).toList();
    if (mensajes.isEmpty) return;
    final bytes = utf8.encode(jsonEncode([for (final m in mensajes) m.toJson()]));
    await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(bytes));
  }

  Future<void> _alRecibir(String endpointId, Payload payload) async {
    final bytes = payload.bytes;
    if (payload.type != PayloadType.BYTES || bytes == null || _miUsuarioId == null) return;
    try {
      final lista = (jsonDecode(utf8.decode(bytes)) as List).cast<Map<String, dynamic>>();
      final nuevos = await _cola.agregarAjenos(lista.map(MensajeOffline.fromJson), miUsuarioId: _miUsuarioId!);
      if (nuevos > 0) _recibidos.add(nuevos);
    } catch (_) {
      // Datos que no son de RESCATE360 o llegaron incompletos: se ignoran
    }
  }
}

final nearbyMeshProvider = Provider<NearbyMesh>((ref) => NearbyMesh(ref.watch(offlineQueueProvider)));
