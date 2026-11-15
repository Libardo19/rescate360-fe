import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/location/location_service.dart';
import '../../data/models/marcador_mapa_model.dart';
import '../../data/repositories/mapa_repository.dart';

class MapaState {
  final ({double lat, double lng})? posicion;
  final Map<String, MarcadorMapaModel> puntos;
  final bool cargando;
  final String? error;
  final bool permisoBloqueado;

  const MapaState({
    this.posicion,
    this.puntos = const {},
    this.cargando = true,
    this.error,
    this.permisoBloqueado = false,
  });

  MapaState copyWith({
    ({double lat, double lng})? posicion,
    Map<String, MarcadorMapaModel>? puntos,
    bool? cargando,
    String? error,
    bool? permisoBloqueado,
  }) =>
      MapaState(
        posicion: posicion ?? this.posicion,
        puntos: puntos ?? this.puntos,
        cargando: cargando ?? this.cargando,
        error: error,
        permisoBloqueado: permisoBloqueado ?? this.permisoBloqueado,
      );
}

/// Mapa en vivo:
/// - sigue el GPS del usuario y le envía su ubicación al backend (máx. cada 60 s o al moverse 100 m);
/// - pregunta al backend cada 15 s qué cambió (`desde`) y quita lo que se cerró.
class MapaViewModel extends StateNotifier<MapaState> {
  MapaViewModel(this._repo, this._ubicacion) : super(const MapaState());

  final MapaRepository _repo;
  final LocationService _ubicacion;

  static const intervalo = Duration(seconds: 15);
  static const _envioMinimo = Duration(seconds: 60);
  static const _distanciaEnvio = 100.0; // metros

  Timer? _timer;
  StreamSubscription<({double lat, double lng})>? _gps;
  String? _desde;
  DateTime? _ultimoEnvio;
  ({double lat, double lng})? _ultimaEnviada;
  bool _pausado = false;

  Future<void> iniciar() async {
    state = state.copyWith(cargando: true, error: null, permisoBloqueado: false);
    try {
      final posicion = await _ubicacion.ubicacionActual();
      state = state.copyWith(posicion: posicion, cargando: false);
      _enviarUbicacion(posicion);
      await _actualizar(completo: true);
      _gps?.cancel();
      _gps = _ubicacion.seguir().listen((p) {
        state = state.copyWith(posicion: p);
        _enviarUbicacion(p);
      }, onError: (_) {});
      _timer?.cancel();
      _timer = Timer.periodic(intervalo, (_) => _actualizar());
    } on UbicacionException catch (e) {
      state = state.copyWith(cargando: false, error: e.mensaje, permisoBloqueado: e.abrirAjustes);
    }
  }

  /// Para quien solo muestra el mapa (la vista previa del inicio): arranca si nadie lo ha hecho.
  /// Así el inicio y la pestaña Mapa comparten el mismo GPS y la misma consulta cada 15 s.
  Future<void> iniciarSiHaceFalta() async {
    if (_timer != null || state.posicion != null) return;
    await iniciar();
  }

  /// La app pasó a segundo plano: no se consulta para no gastar datos ni batería.
  void pausar(bool pausado) {
    _pausado = pausado;
    if (!pausado) _actualizar();
  }

  Future<void> _actualizar({bool completo = false}) async {
    final posicion = state.posicion;
    if (posicion == null || (_pausado && !completo)) return;
    try {
      final respuesta = await _repo.puntos(lat: posicion.lat, lng: posicion.lng, desde: completo ? null : _desde);
      _desde = respuesta.generadoEn;
      final puntos = completo ? <String, MarcadorMapaModel>{} : {...state.puntos};
      for (final p in respuesta.puntos) {
        if (p.activo) {
          puntos[p.id] = p;
        } else {
          puntos.remove(p.id); // se cerró: sale del mapa
        }
      }
      if (mounted) state = state.copyWith(puntos: puntos);
    } catch (e) {
      // Sin red el mapa sigue mostrando lo último que tenía; se reintenta en el siguiente ciclo
      if (completo && mounted) state = state.copyWith(error: ApiException.desde(e).mensaje);
    }
  }

  Future<void> recargar() => _actualizar(completo: true);

  void _enviarUbicacion(({double lat, double lng}) p) {
    final ahora = DateTime.now();
    final anterior = _ultimaEnviada;
    final movido = anterior == null ||
        Geolocator.distanceBetween(anterior.lat, anterior.lng, p.lat, p.lng) >= _distanciaEnvio;
    final tiempo = _ultimoEnvio == null || ahora.difference(_ultimoEnvio!) >= _envioMinimo;
    if (!movido && !tiempo) return;
    _ultimoEnvio = ahora;
    _ultimaEnviada = p;
    // Si el usuario no ha autorizado el uso de su ubicación, el backend lo rechaza y el mapa sigue igual
    _repo.enviarMiUbicacion(p.lat, p.lng).catchError((_) {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gps?.cancel();
    super.dispose();
  }
}

final mapaViewModelProvider = StateNotifierProvider.autoDispose<MapaViewModel, MapaState>((ref) {
  return MapaViewModel(ref.watch(mapaRepositoryProvider), ref.watch(locationServiceProvider));
});
