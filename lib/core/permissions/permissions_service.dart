import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permisos en tiempo de ejecución que no cubren otros paquetes. Desde Android 12, Nearby
/// necesita los de Bluetooth y "dispositivos cercanos"; la ubicación ya la pide geolocator.
class PermissionsService {
  static const _relevo = [
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.nearbyWifiDevices,
    Permission.locationWhenInUse,
  ];

  /// true si el usuario dio todos los permisos del relevo Bluetooth.
  Future<bool> pedirRelevoBluetooth() async {
    final estados = await _relevo.request();
    // En versiones de Android que no tienen alguno, queda "granted" o "restricted": no bloquea
    return estados.values.every((e) => e.isGranted || e.isLimited || e.isRestricted);
  }
}

final permissionsServiceProvider = Provider<PermissionsService>((ref) => PermissionsService());
