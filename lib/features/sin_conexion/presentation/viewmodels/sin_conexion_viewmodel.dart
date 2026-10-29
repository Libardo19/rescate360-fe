import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  const SinConexionState({this.relevoActivo = false, this.enCola = 0, this.aviso});

  SinConexionState copyWith({bool? relevoActivo, int? enCola, String? aviso}) => SinConexionState(
        relevoActivo: relevoActivo ?? this.relevoActivo,
        enCola: enCola ?? this.enCola,
        aviso: aviso,
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

  @override
  SinConexionState build() {
    ref.onDispose(() {
      _red?.cancel();
      _relevados?.cancel();
    });
    return const SinConexionState();
  }

  Future<void> iniciar() async {
    _red ??= ref.read(connectivityServiceProvider).cambios().listen((hayRed) {
      if (hayRed) sincronizar();
    });
    _relevados ??= ref.read(nearbyMeshProvider).recibidos.listen((_) async {
      await _contar();
      sincronizar();
    });
    await _asegurarLlave();
    await sincronizar();
  }

  Future<void> _contar() async {
    state = state.copyWith(enCola: (await ref.read(offlineQueueProvider).todos()).length);
  }

  Future<String?> _asegurarLlave() async {
    final storage = ref.read(secureStorageProvider);
    final guardada = await storage.llaveOffline();
    if (guardada != null) return guardada;
    try {
      final json = await ref.read(apiClientProvider).get<Map<String, dynamic>>(Endpoints.llaveOffline);
      final llave = json['llave'] as String;
      await storage.guardarLlaveOffline(llave);
      return llave;
    } catch (_) {
      return null; // sin red: se intenta en la próxima conexión
    }
  }

  Future<void> sincronizar() async {
    try {
      final entregados = await ref.read(syncWorkerProvider).subir();
      if (entregados > 0) state = state.copyWith(aviso: 'Se entregaron $entregados mensajes guardados sin conexión.');
    } catch (_) {
      // Sigue sin llegar al backend: se reintenta cuando cambie la red
    }
    await _contar();
  }

  /// Firma y encola un mensaje propio, y prende el relevo para que salga por Bluetooth.
  /// Devuelve null si quedó en la cola, o el motivo por el que no se pudo.
  Future<String?> encolar(String tipo) async {
    final usuario = ref.read(authViewModelProvider).usuario;
    final llave = await ref.read(secureStorageProvider).llaveOffline();
    if (usuario == null || llave == null) {
      return 'Este teléfono todavía no tiene la llave para mensajes sin conexión: '
          'abre la app una vez con internet.';
    }
    ({double lat, double lng}) posicion;
    try {
      posicion = await ref.read(locationServiceProvider).ubicacionActual();
    } on UbicacionException catch (e) {
      return e.mensaje;
    }
    await ref.read(offlineQueueProvider).agregarPropio(MensajeOffline.firmado(
          llave: llave,
          uuidOrigen: _uuid.v4(),
          usuarioId: usuario.id,
          tipo: tipo,
          lat: posicion.lat,
          lng: posicion.lng,
        ));
    await _contar();
    await activarRelevo();
    return null;
  }

  /// Anuncia y busca teléfonos cercanos. Devuelve el error para mostrar, o null.
  Future<String?> activarRelevo() async {
    final usuario = ref.read(authViewModelProvider).usuario;
    if (usuario == null) return 'Inicia sesión para usar el relevo.';
    if (!await ref.read(permissionsServiceProvider).pedirRelevoBluetooth()) {
      return 'Sin los permisos de Bluetooth y dispositivos cercanos no se puede pasar el mensaje.';
    }
    try {
      final activo = await ref.read(nearbyMeshProvider).iniciar(miUsuarioId: usuario.id, nombre: usuario.primerNombre);
      state = state.copyWith(relevoActivo: activo);
      return activo ? null : 'No se pudo activar el Bluetooth.';
    } catch (_) {
      // Web, iOS o un Android sin Google Play services: el relevo no está disponible
      return 'El relevo por Bluetooth solo funciona en Android.';
    }
  }

  Future<void> desactivarRelevo() async {
    try {
      await ref.read(nearbyMeshProvider).detener();
    } catch (_) {}
    state = state.copyWith(relevoActivo: false);
  }
}

final sinConexionProvider = NotifierProvider<SinConexionViewModel, SinConexionState>(SinConexionViewModel.new);
