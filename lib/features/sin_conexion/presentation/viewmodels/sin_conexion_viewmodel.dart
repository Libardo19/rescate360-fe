import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/offline/connectivity_service.dart';
import '../../../../core/offline/mensaje_offline.dart';
import '../../../../core/offline/nearby_mesh.dart';
import '../../../../core/offline/offline_queue.dart';
import '../../../../core/offline/sync_worker.dart';
import '../../../../core/permissions/permissions_service.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class SinConexionState {
  // El teléfono está anunciando y buscando por Bluetooth para pasar mensajes
  final bool relevoActivo;
  // Mensajes en la cola (propios y de otras personas) esperando internet
  final int enCola;
  final String? aviso;
  final EstadoRelevo enlace;

  const SinConexionState(
      {this.relevoActivo = false,
      this.enCola = 0,
      this.aviso,
      this.enlace = const EstadoRelevo()});

  SinConexionState copyWith(
          {bool? relevoActivo,
          int? enCola,
          String? aviso,
          EstadoRelevo? enlace}) =>
      SinConexionState(
        relevoActivo: relevoActivo ?? this.relevoActivo,
        enCola: enCola ?? this.enCola,
        aviso: aviso,
        enlace: enlace ?? this.enlace,
      );
}

/// Modo sin conexión (prueba de concepto, solo Android):
/// - guarda la llave offline del usuario cuando hay red;
/// - si un SOS o un "¿Estás bien?" no sale por falta de red, lo firma y lo encola;
/// - el relevo Bluetooth pasa la cola a los teléfonos cercanos con RESCATE360;
/// - al volver la red, sube lo propio y lo ajeno (sync_worker).
class SinConexionViewModel extends Notifier<SinConexionState> {
  final _uuid = const Uuid();
  StreamSubscription<bool>? _red;
  StreamSubscription<int>? _relevados;
  StreamSubscription<EstadoRelevo>? _enlaces;
  Future<String>? _sincronizacion;

  @override
  SinConexionState build() {
    ref.onDispose(() {
      _red?.cancel();
      _relevados?.cancel();
      _enlaces?.cancel();
    });
    return const SinConexionState();
  }

  Future<void> iniciar() async {
    _escucharRelevo();
    _red ??= ref.read(connectivityServiceProvider).cambios().listen((hayRed) {
      if (hayRed) {
        _asegurarLlave();
        sincronizar();
      }
    });
    _relevados ??= ref.read(nearbyMeshProvider).recibidos.listen((_) async {
      await _contar();
      sincronizar();
    });
    await _asegurarLlave();
    await sincronizar();
  }

  void _escucharRelevo() {
    _enlaces ??= ref.read(nearbyMeshProvider).cambios.listen((enlace) {
      state = state.copyWith(enlace: enlace, aviso: state.aviso);
    });
  }

  Future<void> _contar() async {
    state = state.copyWith(
        enCola: (await ref.read(offlineQueueProvider).todos()).length);
  }

  Future<String?> _asegurarLlave() async {
    final storage = ref.read(secureStorageProvider);
    final guardada = await storage.llaveOffline();
    if (guardada != null) return guardada;
    try {
      final json = await ref
          .read(apiClientProvider)
          .get<Map<String, dynamic>>(Endpoints.llaveOffline);
      final llave = json['llave'] as String;
      await storage.guardarLlaveOffline(llave);
      return llave;
    } catch (_) {
      return null; // sin red: se intenta en la próxima conexión
    }
  }

  /// Sube la cola al backend. Devuelve qué pasó, para mostrarlo cuando la persona lo pide.
  Future<String> sincronizar() async {
    final pendiente = _sincronizacion;
    if (pendiente != null) return pendiente;
    final operacion = _sincronizar();
    _sincronizacion = operacion;
    try {
      return await operacion;
    } finally {
      _sincronizacion = null;
    }
  }

  Future<String> _sincronizar() async {
    String resultado;
    try {
      final entregados = await ref.read(syncWorkerProvider).subir();
      resultado = entregados > 0
          ? 'Se entregaron $entregados mensajes guardados sin conexión.'
          : 'No hay mensajes pendientes por entregar.';
      if (entregados > 0) state = state.copyWith(aviso: resultado);
    } catch (_) {
      // Sigue sin llegar al backend: se reintenta cuando cambie la red, y mientras tanto
      // se le pasa la cola a los teléfonos cercanos ya conectados
      try {
        await ref.read(nearbyMeshProvider).compartir();
      } catch (_) {}
      resultado = state.relevoActivo
          ? 'Sin internet: los mensajes siguen guardados y se pasan por Bluetooth a teléfonos cercanos.'
          : 'Sin internet: los mensajes siguen guardados. Activa el relevo para pasarlos por Bluetooth.';
    }
    await _contar();
    state = state.copyWith(aviso: resultado);
    return resultado;
  }

  /// Firma y encola un mensaje propio, y prende el relevo para que salga por Bluetooth.
  /// Un `reporte` ya trae la ubicación del formulario (`lat`/`lng`); los demás usan el GPS.
  /// Devuelve null si quedó en la cola, o el motivo por el que no se pudo.
  Future<String?> encolar(String tipo,
      {ReporteOffline? reporte, double? lat, double? lng}) async {
    final usuario = ref.read(authViewModelProvider).usuario;
    final llave = await ref.read(secureStorageProvider).llaveOffline();
    if (usuario == null || llave == null) {
      return 'Este teléfono todavía no tiene la llave para mensajes sin conexión: '
          'abre la app una vez con internet.';
    }
    ({double lat, double lng}) posicion;
    if (lat != null && lng != null) {
      posicion = (lat: lat, lng: lng);
    } else {
      try {
        posicion = await ref.read(locationServiceProvider).ubicacionActual();
      } on UbicacionException catch (e) {
        return e.mensaje;
      }
    }
    await ref.read(offlineQueueProvider).agregarPropio(MensajeOffline.firmado(
          llave: llave,
          uuidOrigen: _uuid.v4(),
          usuarioId: usuario.id,
          tipo: tipo,
          lat: posicion.lat,
          lng: posicion.lng,
          reporte: reporte,
        ));
    await _contar();
    final errorRelevo = await activarRelevo();
    if (errorRelevo != null) {
      state = state.copyWith(aviso: 'El mensaje quedó guardado. $errorRelevo');
    }
    // Si ya había teléfonos conectados, el mensaje nuevo sale de una vez
    try {
      await ref.read(nearbyMeshProvider).compartir();
    } catch (_) {}
    return null;
  }

  /// Anuncia y busca teléfonos cercanos. Devuelve el error para mostrar, o null.
  Future<String?> activarRelevo() async {
    final usuario = ref.read(authViewModelProvider).usuario;
    if (usuario == null) return 'Inicia sesión para usar el relevo.';
    try {
      _escucharRelevo();
      final requisito =
          await ref.read(permissionsServiceProvider).prepararRelevoBluetooth();
      if (requisito != null) {
        state = state.copyWith(aviso: requisito);
        return requisito;
      }
      final activo = await ref
          .read(nearbyMeshProvider)
          .iniciar(miUsuarioId: usuario.id, nombre: usuario.primerNombre);
      final enlace = ref.read(nearbyMeshProvider).estado;
      state = state.copyWith(
          relevoActivo: activo,
          enlace: enlace,
          aviso: activo ? null : enlace.mensaje);
      return activo ? null : enlace.mensaje;
    } on PlatformException catch (error) {
      final mensaje =
          'No se pudo iniciar Nearby (${error.code}). Revisa permisos y servicios de Google Play.';
      state = state.copyWith(relevoActivo: false, aviso: mensaje);
      return mensaje;
    } catch (_) {
      const mensaje =
          'No se pudo activar el relevo. Reinicia la app y revisa los permisos.';
      state = state.copyWith(relevoActivo: false, aviso: mensaje);
      return mensaje;
    }
  }

  Future<void> desactivarRelevo() async {
    try {
      await ref.read(nearbyMeshProvider).detener();
    } catch (_) {}
    state = state.copyWith(relevoActivo: false);
  }
}

final sinConexionProvider =
    NotifierProvider<SinConexionViewModel, SinConexionState>(
        SinConexionViewModel.new);
