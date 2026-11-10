import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// No se pudo leer el GPS: [mensaje] se muestra tal cual al usuario.
class UbicacionException implements Exception {
  final String mensaje;
  final bool abrirAjustes; // el permiso quedó negado para siempre
  const UbicacionException(this.mensaje, {this.abrirAjustes = false});
}

/// Lectura del GPS con sus permisos. La usan los formularios (ayuda, SOS, reportes) y el mapa.
class LocationService {
  Future<void> _asegurarPermiso() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const UbicacionException('Activa la ubicación (GPS) del teléfono.');
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) {
      throw const UbicacionException('Necesitamos tu ubicación para saber dónde enviar la ayuda.');
    }
    if (permiso == LocationPermission.deniedForever) {
      throw const UbicacionException(
        'El permiso de ubicación está bloqueado. Actívalo en los ajustes de la app.',
        abrirAjustes: true,
      );
    }
  }

  /// Posición actual. Si el GPS tarda, usa la última conocida.
  Future<({double lat, double lng})> ubicacionActual() async {
    await _asegurarPermiso();
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 12)),
      );
      return (lat: p.latitude, lng: p.longitude);
    } catch (_) {
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima == null) throw const UbicacionException('No pudimos leer tu ubicación. Intenta de nuevo.');
      return (lat: ultima.latitude, lng: ultima.longitude);
    }
  }

  /// Posiciones a medida que el usuario se mueve (cada [metros] como mínimo). Para el mapa en vivo.
  Stream<({double lat, double lng})> seguir({int metros = 25}) async* {
    await _asegurarPermiso();
    yield* Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: metros),
    ).map((p) => (lat: p.latitude, lng: p.longitude));
  }

  Future<bool> abrirAjustes() => Geolocator.openAppSettings();
}

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
