import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/router.dart';
import '../../../../core/config/env.dart';
import '../../../sismos/data/models/sismo_model.dart';
import '../../data/models/marcador_mapa_model.dart';
import '../viewmodels/mapa_viewmodel.dart';
import '../widgets/detalle_punto_sheet.dart';
import '../widgets/tipo_punto.dart';

enum FiltroMapa { todos, incidentes, solicitudes, alertas, centros, sismos }

const _tipoDe = tipoDePunto;

/// Mapa en vivo (mockup 5): tu ubicación y lo que pasa alrededor (GET /mapa cada 15 s),
/// con búsqueda y filtros. Mapa de OpenStreetMap con flutter_map (no requiere API key).
class MapaEmergenciaScreen extends ConsumerStatefulWidget {
  const MapaEmergenciaScreen({super.key});

  @override
  ConsumerState<MapaEmergenciaScreen> createState() => _MapaEmergenciaScreenState();
}

class _MapaEmergenciaScreenState extends ConsumerState<MapaEmergenciaScreen> with WidgetsBindingObserver {
  final _busquedaCtrl = TextEditingController();
  final _mapa = MapController();
  FiltroMapa _filtro = FiltroMapa.todos;
  String _consulta = '';
  bool _mapaListo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Si la vista previa del inicio ya lo arrancó, se reutiliza
    Future.microtask(() => ref.read(mapaViewModelProvider.notifier).iniciarSiHaceFalta());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    ref.read(mapaViewModelProvider.notifier).pausar(estado != AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _busquedaCtrl.dispose();
    _mapa.dispose();
    super.dispose();
  }

  void _centrar() {
    final posicion = ref.read(mapaViewModelProvider).posicion;
    if (posicion == null || !_mapaListo) return;
    _mapa.move(LatLng(posicion.lat, posicion.lng), 16);
  }

  List<MarcadorMapaModel> _visibles(Iterable<MarcadorMapaModel> puntos) {
    final q = _consulta.trim().toLowerCase();
    return puntos.where((p) {
      final tipo = _tipoDe(p);
      final pasaFiltro = switch (_filtro) {
        FiltroMapa.todos => true,
        FiltroMapa.incidentes => tipo == TipoPunto.incidente,
        FiltroMapa.solicitudes => tipo == TipoPunto.solicitud,
        FiltroMapa.alertas => tipo == TipoPunto.alerta,
        FiltroMapa.centros => tipo == TipoPunto.centro,
        FiltroMapa.sismos => tipo == TipoPunto.sismo,
      };
      final pasaBusqueda = q.isEmpty || p.titulo.toLowerCase().contains(q) || p.detalle.toLowerCase().contains(q);
      return pasaFiltro && pasaBusqueda;
    }).toList();
  }

  String _distanciaA(MarcadorMapaModel p) {
    final posicion = ref.read(mapaViewModelProvider).posicion;
    if (posicion == null) return '';
    final metros = Geolocator.distanceBetween(posicion.lat, posicion.lng, p.lat, p.lng);
    final texto = metros < 1000 ? '${metros.round()} m' : '${(metros / 1000).toStringAsFixed(1)} km';
    return p.aproximada ? 'A unos $texto de ti (ubicación aproximada)' : 'A $texto de ti';
  }

  /// Información completa del punto; los incidentes traen sus fotos del backend.
  void _verDetalle(MarcadorMapaModel p) {
    mostrarDetallePunto(
      context,
      punto: p,
      distancia: _distanciaA(p),
      onCentrar: () {
        if (_mapaListo) _mapa.move(LatLng(p.lat, p.lng), 17);
      },
    );
  }

  void _irAlPrimerResultado(List<MarcadorMapaModel> visibles) {
    if (visibles.isEmpty || !_mapaListo) return;
    _mapa.move(LatLng(visibles.first.lat, visibles.first.lng), 17);
  }

  /// Los sismos son de todo el mundo: al elegir el filtro se aleja el mapa a la vista mundial.
  void _verSismos() {
    setState(() => _filtro = FiltroMapa.sismos);
    if (_mapaListo) _mapa.move(const LatLng(10, -40), 2);
  }

  /// Sismo: un círculo del color y el tamaño de su magnitud.
  Marker _marcadorSismo(MarcadorMapaModel p) {
    final m = p.magnitud ?? 0;
    final lado = tamanoMagnitud(m);
    return Marker(
      point: LatLng(p.lat, p.lng),
      width: lado,
      height: lado,
      child: GestureDetector(
        onTap: () => _verDetalle(p),
        child: Container(
          decoration: BoxDecoration(
            color: colorMagnitud(m).withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  Marker _marcador(MarcadorMapaModel p) {
    if (p.capa == 'sismo') return _marcadorSismo(p);
    final tipo = _tipoDe(p);
    final critico = p.prioridad == 'critica';
    return Marker(
      point: LatLng(p.lat, p.lng),
      width: critico ? 46 : 40,
      height: critico ? 46 : 40,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => _verDetalle(p),
        child: Icon(
          Icons.location_on,
          size: critico ? 46 : 40,
          // Lo ajeno (posición aproximada) se ve más tenue
          color: p.aproximada ? tipo.color.withValues(alpha: 0.55) : tipo.color,
          shadows: const [Shadow(color: Color(0x55000000), blurRadius: 4)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(mapaViewModelProvider);

    if (estado.cargando) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (estado.posicion == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_outlined, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 14),
                Text(
                  estado.error ?? 'No pudimos obtener tu ubicación.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ref.read(mapaViewModelProvider.notifier).iniciar(),
                  child: const Text('Reintentar'),
                ),
                if (estado.permisoBloqueado) ...[
                  const SizedBox(height: 12),
                  const OutlinedButton(
                    onPressed: Geolocator.openAppSettings,
                    child: Text('Abrir ajustes'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    final yo = LatLng(estado.posicion!.lat, estado.posicion!.lng);
    final visibles = _visibles(estado.puntos.values);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapa,
          options: MapOptions(
            initialCenter: yo,
            initialZoom: 15,
            onMapReady: () => _mapaListo = true,
          ),
          children: [
            TileLayer(urlTemplate: Env.mapTileUrl, userAgentPackageName: 'co.rescate360.app'),
            // Zonas y alertas con radio real en metros
            CircleLayer(
              circles: [
                for (final p in visibles)
                  if (p.radioM != null)
                    CircleMarker(
                      point: LatLng(p.lat, p.lng),
                      radius: p.radioM!,
                      useRadiusInMeter: true,
                      color: _tipoDe(p).color.withValues(alpha: 0.18),
                      borderColor: _tipoDe(p).color,
                      borderStrokeWidth: 2,
                    ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (final p in visibles) _marcador(p),
                // Mi ubicación
                Marker(
                  point: yo,
                  width: 22,
                  height: 22,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(color: Color(0x553E7BFA), blurRadius: 10, spreadRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
            const RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [TextSourceAttribution('© OpenStreetMap')],
            ),
          ],
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
                    BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: TextField(
                  controller: _busquedaCtrl,
                  style: AppTextStyles.body,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _consulta = v),
                  onSubmitted: (_) => _irAlPrimerResultado(visibles),
                  decoration: InputDecoration(
                    hintText: 'Buscar en el mapa',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 22),
                    suffixIcon: _consulta.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
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
        // Lista de sismos recientes (de todo el mundo)
        Positioned(
          right: 16,
          bottom: 124,
          child: FloatingActionButton.small(
            heroTag: 'lista_sismos',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFEA580C),
            tooltip: 'Sismos recientes',
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.sismos),
            child: const Icon(Icons.vibration),
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
                  etiqueta: 'Solicitudes',
                  color: AppColors.primary,
                  activo: _filtro == FiltroMapa.solicitudes,
                  onTap: () => setState(() => _filtro = FiltroMapa.solicitudes),
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
                const SizedBox(width: 8),
                _ChipFiltro(
                  etiqueta: 'Sismos',
                  color: const Color(0xFFEA580C),
                  activo: _filtro == FiltroMapa.sismos,
                  onTap: _verSismos,
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
            BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
