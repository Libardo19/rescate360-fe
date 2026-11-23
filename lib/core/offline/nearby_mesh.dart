import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:uuid/uuid.dart';
import 'mensaje_offline.dart';
import 'offline_queue.dart';

class EstadoRelevo {
  const EstadoRelevo(
      {this.encontrados = 0,
      this.conectados = 0,
      this.recibidos = 0,
      this.mensaje = 'Relevo desactivado.'});
  final int encontrados, conectados, recibidos;
  final String mensaje;
}

/// Intercambia colas por Nearby y expone el estado de cada etapa.
class NearbyMesh {
  NearbyMesh(this._cola);
  static const _servicio = 'co.rescate360.mesh';
  final OfflineQueue _cola;
  final _nearby = Nearby();
  final _recibidos = StreamController<int>.broadcast();
  final _cambios = StreamController<EstadoRelevo>.broadcast();
  final _conectados = <String>{};
  final _encontrados = <String, String>{};
  final _pendientes = <String, DateTime>{};
  String? _miUsuarioId;
  String _nombreSesion = '';
  bool _activo = false;
  int _totalRecibidos = 0;
  Timer? _reintento;
  Future<bool>? _inicio;
  Future<void> _recepcion = Future.value();
  EstadoRelevo _estado = const EstadoRelevo();

  Stream<int> get recibidos => _recibidos.stream;
  Stream<EstadoRelevo> get cambios => _cambios.stream;
  EstadoRelevo get estado => _estado;
  bool get activo => _activo;

  void _informar(String mensaje) {
    _estado = EstadoRelevo(
        encontrados: _encontrados.length,
        conectados: _conectados.length,
        recibidos: _totalRecibidos,
        mensaje: mensaje);
    _cambios.add(_estado);
  }

  String _error(Object error) =>
      error is PlatformException ? ' (${error.code})' : '';

  Future<bool> iniciar(
      {required String miUsuarioId, required String nombre}) async {
    if (_inicio != null) return _inicio!;
    if (_activo) return true;
    final inicio = _iniciar(miUsuarioId, nombre);
    _inicio = inicio;
    try {
      return await inicio;
    } finally {
      _inicio = null;
    }
  }

  Future<bool> _iniciar(String usuarioId, String nombre) async {
    _miUsuarioId = usuarioId;
    _nombreSesion = '$nombre#${const Uuid().v4()}';
    _activo = true;
    try {
      final anuncia = await _nearby.startAdvertising(
          _nombreSesion, Strategy.P2P_CLUSTER,
          serviceId: _servicio,
          onConnectionInitiated: _aceptar,
          onConnectionResult: _alConectar,
          onDisconnected: _desconectado);
      final busca = await _nearby.startDiscovery(
          _nombreSesion, Strategy.P2P_CLUSTER, serviceId: _servicio,
          onEndpointFound: (id, nombre, _) {
        _encontrados[id] = nombre;
        _informar('Teléfono encontrado. Preparando el enlace.');
        unawaited(_solicitar(id));
      }, onEndpointLost: (id) {
        _encontrados.remove(id);
        _informar('Buscando teléfonos con el relevo activo.');
      });
      _activo = anuncia && busca;
      if (!_activo) {
        await detener();
        _informar(
            'Nearby no pudo activar búsqueda y anuncio. Vuelve a activar el relevo.');
        return false;
      }
      _informar('Buscando teléfonos con el relevo activo.');
      for (final id in _encontrados.keys.toList()) {
        unawaited(_solicitar(id));
      }
      _reintento = Timer.periodic(const Duration(seconds: 10), (_) {
        for (final id in _encontrados.keys.toList()) {
          unawaited(_solicitar(id));
        }
      });
      return true;
    } catch (error) {
      await detener();
      _informar(
          'No se pudo iniciar Nearby${_error(error)}. Revisa permisos y servicios de Google Play.');
      rethrow;
    }
  }

  Future<void> _solicitar(String id) async {
    final remoto = _encontrados[id];
    if (!_activo || remoto == null || _conectados.contains(id)) return;
    // Solo un lado solicita el enlace para evitar solicitudes cruzadas.
    if (_nombreSesion.compareTo(remoto) >= 0) return;
    final desde = _pendientes[id];
    if (desde != null && DateTime.now().difference(desde).inSeconds < 25) {
      return;
    }
    _pendientes[id] = DateTime.now();
    try {
      final solicitado = await _nearby.requestConnection(_nombreSesion, id,
          onConnectionInitiated: _aceptar,
          onConnectionResult: _alConectar,
          onDisconnected: _desconectado);
      if (!solicitado) {
        _pendientes.remove(id);
        _informar('No se pudo solicitar el enlace. Reintentando.');
      }
    } catch (error) {
      _pendientes.remove(id);
      _informar('Falló la solicitud Nearby${_error(error)}. Reintentando.');
    }
  }

  Future<void> detener() async {
    _activo = false;
    _reintento?.cancel();
    _reintento = null;
    _conectados.clear();
    _pendientes.clear();
    _encontrados.clear();
    for (final parar in [
      _nearby.stopAdvertising,
      _nearby.stopDiscovery,
      _nearby.stopAllEndpoints
    ]) {
      try {
        await parar();
      } catch (_) {/* Continúa la limpieza de las otras operaciones. */}
    }
    _informar('Relevo desactivado.');
  }

  void _desconectado(String id) {
    _conectados.remove(id);
    _pendientes.remove(id);
    _informar('Se desconectó un teléfono. Buscando de nuevo.');
  }

  Future<void> _aceptar(String id, ConnectionInfo _) async {
    if (!_activo) return;
    try {
      final aceptado =
          await _nearby.acceptConnection(id, onPayLoadRecieved: _alRecibir);
      if (!aceptado) _informar('No se pudo aceptar el enlace Nearby.');
    } catch (error) {
      _pendientes.remove(id);
      _informar('No se pudo aceptar el enlace${_error(error)}.');
    }
  }

  Future<void> _alConectar(String id, Status estado) async {
    _pendientes.remove(id);
    if (!_activo) return;
    if (estado != Status.CONNECTED) {
      _informar(
          'Nearby terminó el enlace con estado ${estado.name}. Reintentando.');
      return;
    }
    _conectados.add(id);
    _informar('Teléfono conectado. Intercambiando mensajes.');
    await _enviarCola(id);
  }

  Future<void> compartir({String? excepto}) async {
    for (final id in _conectados.toList()) {
      if (id != excepto) await _enviarCola(id);
    }
  }

  Future<void> _enviarCola(String id) async {
    try {
      final mensajes = (await _cola.todos()).where((m) => m.relevable);
      var lote = <Map<String, dynamic>>[];
      for (final mensaje in mensajes) {
        final json = mensaje.toJson();
        final candidato = [...lote, json];
        if (candidato.length > MensajeOffline.maximoMensajesLote ||
            utf8.encode(jsonEncode(candidato)).length >
                MensajeOffline.maximoBytesLote) {
          if (lote.isNotEmpty) {
            await _enviarLote(id, lote);
          }
          lote = [];
        }
        if (utf8.encode(jsonEncode([json])).length >
            MensajeOffline.maximoBytesLote) {
          _informar('Un mensaje supera el tamaño permitido y sigue guardado.');
          continue;
        }
        lote.add(json);
      }
      if (lote.isNotEmpty) {
        await _enviarLote(id, lote);
      }
    } catch (error) {
      _informar(
          'Falló el envío al teléfono${_error(error)}. Los mensajes siguen guardados.');
    }
  }

  Future<void> _enviarLote(String id, List<Map<String, dynamic>> lote) =>
      _nearby.sendBytesPayload(
          id, Uint8List.fromList(utf8.encode(jsonEncode(lote))));

  void _alRecibir(String id, Payload payload) {
    final bytes = payload.bytes;
    if (payload.type != PayloadType.BYTES ||
        bytes == null ||
        _miUsuarioId == null) {
      return;
    }
    // Serializa los lotes entrantes para conservar lo recibido por varios pares.
    _recepcion = _recepcion.then((_) async {
      try {
        final lista = MensajeOffline.desdeLoteBytes(bytes);
        final nuevos =
            await _cola.agregarAjenos(lista, miUsuarioId: _miUsuarioId!);
        _totalRecibidos += nuevos;
        final mismaCuenta =
            lista.isNotEmpty && lista.every((m) => m.usuarioId == _miUsuarioId);
        _informar(nuevos > 0
            ? 'Se recibieron $nuevos mensajes por Nearby.'
            : mismaCuenta
                ? 'Lote recibido de tu misma cuenta. Usa cuentas distintas para probar el relevo.'
                : 'Lote recibido sin mensajes nuevos. Puede ser repetido o vencido.');
        if (nuevos > 0) {
          _recibidos.add(nuevos);
          await compartir(excepto: id);
        }
      } on FormatException {
        _informar('Se rechazó un lote recibido por formato o tamaño inválido.');
      } catch (error) {
        _informar('No se pudo guardar el lote recibido${_error(error)}.');
      }
    });
  }
}

final nearbyMeshProvider =
    Provider<NearbyMesh>((ref) => NearbyMesh(ref.watch(offlineQueueProvider)));
