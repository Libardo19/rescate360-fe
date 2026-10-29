import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/location/location_service.dart';
import '../../data/models/check_in_model.dart';
import '../../data/repositories/check_in_repository.dart';
import '../../../sin_conexion/presentation/viewmodels/sin_conexion_viewmodel.dart';

/// Vigila si hay un "¿Estás bien?" pendiente. Todavía no hay push (Firebase es la última
/// tarea), así que la app pregunta al abrir y cada minuto mientras está abierta.
class CheckInViewModel extends Notifier<CheckInModel?> {
  static const intervalo = Duration(seconds: 60);
  Timer? _timer;

  @override
  CheckInModel? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void iniciar() {
    _timer?.cancel();
    consultar();
    _timer = Timer.periodic(intervalo, (_) => consultar());
  }

  void detener() => _timer?.cancel();

  Future<void> consultar() async {
    try {
      state = await ref.read(checkInRepositoryProvider).pendiente();
    } catch (_) {
      // Sin red o sin sesión: se vuelve a intentar en el siguiente ciclo
    }
  }

  Future<({double lat, double lng})?> _posicion() async {
    try {
      return await ref.read(locationServiceProvider).ubicacionActual();
    } on UbicacionException {
      return null;
    }
  }

  /// Responde el pendiente. Devuelve el mensaje de error, o null si salió bien.
  Future<String?> responder({required bool aSalvo}) async {
    final actual = state;
    if (actual == null) return null;
    try {
      final posicion = await _posicion();
      await ref.read(checkInRepositoryProvider).responder(
            actual.id,
            aSalvo: aSalvo,
            lat: posicion?.lat,
            lng: posicion?.lng,
          );
      state = null;
      return null;
    } catch (e) {
      final error = ApiException.desde(e);
      if (!error.esSinConexion) return error.mensaje;
      // Sin internet: la respuesta sale firmada por Bluetooth y se entrega cuando alguien tenga red
      final problema = await ref.read(sinConexionProvider.notifier).encolar(aSalvo ? 'a_salvo' : 'necesito_ayuda');
      if (problema != null) return problema;
      state = null;
      return null;
    }
  }

  /// Modo emergencia: abre un "¿Estás bien?" que avisa a los contactos si no respondo.
  Future<String?> activarModoEmergencia() async {
    try {
      final posicion = await _posicion();
      state = await ref.read(checkInRepositoryProvider).activar(lat: posicion?.lat, lng: posicion?.lng);
      return null;
    } catch (e) {
      return ApiException.desde(e).mensaje;
    }
  }
}

final checkInProvider = NotifierProvider<CheckInViewModel, CheckInModel?>(CheckInViewModel.new);
