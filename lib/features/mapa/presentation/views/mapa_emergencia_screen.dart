import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';

enum TipoPunto { incidente, alerta, centro }

enum FiltroMapa { todos, incidentes, alertas, centros }

extension on TipoPunto {
  String get etiqueta {
    switch (this) {
      case TipoPunto.incidente:
        return 'Incidente';
      case TipoPunto.alerta:
        return 'Alerta';
      case TipoPunto.centro:
        return 'Centro de ayuda';
    }
  }

  Color get color {
    switch (this) {
      case TipoPunto.incidente:
        return AppColors.danger;
      case TipoPunto.alerta:
        return AppColors.warning;
      case TipoPunto.centro:
        return AppColors.info;
    }
  }

  double get matiz {
    switch (this) {
      case TipoPunto.incidente:
        return BitmapDescriptor.hueRed;
      case TipoPunto.alerta:
        return BitmapDescriptor.hueOrange;
      case TipoPunto.centro:
        return BitmapDescriptor.hueAzure;
    }
  }

  IconData get icono {
    switch (this) {
      case TipoPunto.incidente:
        return Icons.report_gmailerrorred_outlined;
      case TipoPunto.alerta:
        return Icons.warning_amber_rounded;
      case TipoPunto.centro:
        return Icons.local_hospital_outlined;
    }
  }
}

/// Punto del mapa. Mientras no haya API, la posición se define como un
/// desplazamiento (en grados) respecto a la ubicación del usuario.
class PuntoMapa {
  final String id;
  final TipoPunto tipo;
  final String titulo;
  final String detalle;
  final double dLat;
  final double dLng;

  const PuntoMapa({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.detalle,
    required this.dLat,
    required this.dLng,
  });
}

// Datos de ejemplo hasta conectar la API: se ubican alrededor de la
// posición del usuario para que siempre haya marcadores cerca.
const List<PuntoMapa> _puntosEjemplo = [
  PuntoMapa(
    id: 'i1',
    tipo: TipoPunto.incidente,
    titulo: 'Accidente de tránsito',
    detalle: 'Vía principal · Hace 30 min',
    dLat: 0.0030,
    dLng: -0.0020,
  ),
  PuntoMapa(
    id: 'i2',
    tipo: TipoPunto.incidente,
    titulo: 'Robo reportado',
    detalle: 'Sector comercial · Hace 2 h',
    dLat: -0.0025,
    dLng: 0.0035,
  ),
  PuntoMapa(
    id: 'i3',
    tipo: TipoPunto.incidente,
    titulo: 'Incendio',
    detalle: 'Zona residencial · Hace 4 h',
    dLat: 0.0060,
    dLng: 0.0040,
  ),
  PuntoMapa(
    id: 'a1',
    tipo: TipoPunto.alerta,
    titulo: 'Alerta de inundación',
    detalle: 'Zona baja cerca al río · Hace 1 h',
    dLat: -0.0050,
    dLng: -0.0030,
  ),
  PuntoMapa(
    id: 'a2',
    tipo: TipoPunto.alerta,
    titulo: 'Alerta de deslizamiento',
    detalle: 'Ladera norte · Hace 3 h',
    dLat: 0.0080,
    dLng: -0.0060,
  ),
  PuntoMapa(
    id: 'c1',
    tipo: TipoPunto.centro,
    titulo: 'Centro de acopio',
    detalle: 'Recibe ayuda humanitaria',
    dLat: 0.0015,
    dLng: 0.0045,
  ),
  PuntoMapa(
    id: 'c2',
    tipo: TipoPunto.centro,
    titulo: 'Albergue municipal',
    detalle: 'Refugio temporal',
    dLat: -0.0040,
    dLng: 0.0010,
  ),
  PuntoMapa(
    id: 'c3',
    tipo: TipoPunto.centro,
    titulo: 'Puesto de salud',
    detalle: 'Atención médica de emergencia',
    dLat: 0.0045,
    dLng: -0.0045,
  ),
];

/// Mapa con la ubicación actual, búsqueda y filtros (mockup 5).
class MapaEmergenciaScreen extends StatefulWidget {
  const MapaEmergenciaScreen({super.key});

  @override
  State<MapaEmergenciaScreen> createState() => _MapaEmergenciaScreenState();
}

class _MapaEmergenciaScreenState extends State<MapaEmergenciaScreen> {
  final _busquedaCtrl = TextEditingController();

  GoogleMapController? _controlador;
  LatLng? _posicion;
  String? _error;
  bool _cargando = true;
  bool _permisoBloqueado = false;
  FiltroMapa _filtro = FiltroMapa.todos;
  String _consulta = '';

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    _controlador?.dispose();
    super.dispose();
  }

  void _fallar(String mensaje) {
    if (!mounted) return;
    setState(() {
      _error = mensaje;
      _cargando = false;
    });
  }

  Future<void> _obtenerUbicacion() async {
    setState(() {
      _cargando = true;
      _error = null;
      _permisoBloqueado = false;
    });

    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        _fallar('El GPS está desactivado. Actívalo para ver tu ubicación.');
        return;
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied) {
        _fallar(
            'Necesitamos el permiso de ubicación para mostrarte en el mapa.');
        return;
      }
      if (permiso == LocationPermission.deniedForever) {
        _permisoBloqueado = true;
        _fallar('El permiso de ubicación está bloqueado. '
            'Habilítalo en los ajustes del teléfono.');
        return;
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() {
        _posicion = LatLng(posicion.latitude, posicion.longitude);
        _cargando = false;
      });
      _centrar();
    } catch (_) {
      _fallar('No pudimos obtener tu ubicación. Intenta de nuevo.');
    }
  }

  void _centrar() {
    final posicion = _posicion;
    if (posicion == null) return;
    _controlador?.animateCamera(CameraUpdate.newLatLngZoom(posicion, 16));
  }

  LatLng _coordenadas(PuntoMapa p) => LatLng(
        _posicion!.latitude + p.dLat,
        _posicion!.longitude + p.dLng,
      );

  List<PuntoMapa> get _visibles {
    final q = _consulta.trim().toLowerCase();
    return _puntosEjemplo.where((p) {
      final pasaFiltro = switch (_filtro) {
        FiltroMapa.todos => true,
        FiltroMapa.incidentes => p.tipo == TipoPunto.incidente,
        FiltroMapa.alertas => p.tipo == TipoPunto.alerta,
        FiltroMapa.centros => p.tipo == TipoPunto.centro,
      };
      final pasaBusqueda = q.isEmpty ||
          p.titulo.toLowerCase().contains(q) ||
          p.detalle.toLowerCase().contains(q);
      return pasaFiltro && pasaBusqueda;
    }).toList();
  }

  Set<Marker> _construirMarcadores() {
    return _visibles.map((p) {
      return Marker(
        markerId: MarkerId(p.id),
        position: _coordenadas(p),
        icon: BitmapDescriptor.defaultMarkerWithHue(p.tipo.matiz),
        onTap: () => _verDetalle(p),
      );
    }).toSet();
  }

  String _distanciaA(PuntoMapa p) {
    final destino = _coordenadas(p);
    final metros = Geolocator.distanceBetween(
      _posicion!.latitude,
      _posicion!.longitude,
      destino.latitude,
      destino.longitude,
    );
    if (metros < 1000) return 'A ${metros.round()} m de ti';
    return 'A ${(metros / 1000).toStringAsFixed(1)} km de ti';
  }

  void _verDetalle(PuntoMapa p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: p.tipo.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p.tipo.icono, color: p.tipo.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(p.titulo, style: AppTextStyles.h2)),
              ],
            ),
            const SizedBox(height: 14),
            EtiquetaEstado(texto: p.tipo.etiqueta, color: p.tipo.color),
            const SizedBox(height: 12),
            Text(p.detalle, style: AppTextStyles.body),
            const SizedBox(height: 6),
            Text(_distanciaA(p), style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  void _irAlPrimerResultado() {
    final visibles = _visibles;
    if (visibles.isEmpty) return;
    _controlador?.animateCamera(
      CameraUpdate.newLatLngZoom(_coordenadas(visibles.first), 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null || _posicion == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_outlined,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 14),
                Text(
                  _error ?? 'No pudimos obtener tu ubicación.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _obtenerUbicacion,
                  child: const Text('Reintentar'),
                ),
                if (_permisoBloqueado) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: Geolocator.openAppSettings,
                    child: const Text('Abrir ajustes'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _posicion!, zoom: 16),
          onMapCreated: (c) => _controlador = c,
          markers: _construirMarcadores(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          padding: const EdgeInsets.only(bottom: 70),
        ),
        // Buscador
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _busquedaCtrl,
                  style: AppTextStyles.body,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _consulta = v),
                  onSubmitted: (_) => _irAlPrimerResultado(),
                  decoration: InputDecoration(
                    hintText: 'Buscar en el mapa',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textMuted, size: 22),
                    suffixIcon: _consulta.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textMuted, size: 20),
                            onPressed: () {
                              _busquedaCtrl.clear();
                              setState(() => _consulta = '');
                            },
                          ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Botón para volver a mi ubicación
        Positioned(
          right: 16,
          bottom: 72,
          child: FloatingActionButton.small(
            heroTag: 'centrar_mapa',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            onPressed: _centrar,
            child: const Icon(Icons.my_location),
          ),
        ),
        // Filtros
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _ChipFiltro(
                  etiqueta: 'Todos',
                  activo: _filtro == FiltroMapa.todos,
                  onTap: () => setState(() => _filtro = FiltroMapa.todos),
                ),
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Incidentes',
                  color: AppColors.danger,
                  activo: _filtro == FiltroMapa.incidentes,
                  onTap: () => setState(() => _filtro = FiltroMapa.incidentes),
                ),
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Alertas',
                  color: AppColors.warning,
                  activo: _filtro == FiltroMapa.alertas,
                  onTap: () => setState(() => _filtro = FiltroMapa.alertas),
                ),
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Centros',
                  color: AppColors.info,
                  activo: _filtro == FiltroMapa.centros,
                  onTap: () => setState(() => _filtro = FiltroMapa.centros),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final String etiqueta;
  final Color? color;
  final bool activo;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: activo ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activo ? AppColors.primary : AppColors.surfaceBorder,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: activo ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
