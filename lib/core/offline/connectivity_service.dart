import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ¿Hay red (Wi-Fi o datos)? Tener red no garantiza llegar al backend: el que decide al final
/// es el intento de subida (sync_worker).
class ConnectivityService {
  final _connectivity = Connectivity();

  static bool _conRed(List<ConnectivityResult> resultados) =>
      resultados.any((r) => r != ConnectivityResult.none && r != ConnectivityResult.bluetooth);

  Future<bool> hayRed() async => _conRed(await _connectivity.checkConnectivity());

  /// Emite true cuando vuelve la red y false cuando se va.
  Stream<bool> cambios() => _connectivity.onConnectivityChanged.map(_conRed).distinct();
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());
