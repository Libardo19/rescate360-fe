import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permisos en tiempo de ejecución que no cubren otros paquetes. Desde Android 12, Nearby
/// necesita los de Bluetooth y "dispositivos cercanos"; la ubicación ya la pide geolocator.
class PermissionsService {
  static const _canal = MethodChannel('co.rescate360/relevo');

  /// Devuelve el requisito pendiente o null cuando Nearby puede iniciarse.
  Future<String?> prepararRelevoBluetooth() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return 'El relevo requiere un teléfono Android.';
    }
    final version = await _canal.invokeMethod<int>('versionAndroid');
    if (version == null) return 'No se pudo leer la versión de Android.';
    final permisos = [
      Permission.locationWhenInUse,
      if (version >= 31) ...[
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
      ],
      if (version >= 33) Permission.nearbyWifiDevices,
    ];
    final estados = await permisos.request();
    if (estados.values.any((e) => e.isPermanentlyDenied)) {
      return 'Abre Ajustes > Aplicaciones > Rescate360 > Permisos y permite ubicación y dispositivos cercanos.';
    }
    if (estados.values.any((e) => !e.isGranted)) {
      return 'Permite ubicación y dispositivos cercanos para activar el relevo.';
    }
    var radios = await _canal.invokeMapMethod<String, bool>('estadoRadios');
    if (radios?['bluetooth'] != true) {
      final activado = await _canal.invokeMethod<bool>('activarBluetooth');
      if (activado != true) {
        return 'Para usar el relevo, acepta encender Bluetooth al activar este modo.';
      }
      radios = await _canal.invokeMapMethod<String, bool>('estadoRadios');
      if (radios?['bluetooth'] != true) {
        return 'Bluetooth sigue apagado. Vuelve a activar el relevo.';
      }
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Enciende la ubicación/GPS para encontrar dispositivos.';
    }
    if (radios?['wifi'] != true) {
      return 'Enciende Wi-Fi. Puedes dejarlo sin conectar a una red con internet.';
    }
    return null;
  }
}

final permissionsServiceProvider =
    Provider<PermissionsService>((ref) => PermissionsService());
