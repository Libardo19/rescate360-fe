import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/config/env.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../../data/models/asignacion_model.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../viewmodels/voluntario_viewmodel.dart';
import '../widgets/voluntario_ui.dart';
import 'detalle_incidente_screen.dart';
import 'incidente_en_curso_screen.dart';

/// Mapa del voluntario (mockup 7): incidentes de su organización, sus
/// asignaciones y su ubicación actual.
class MapaVoluntarioScreen extends ConsumerStatefulWidget {
  const MapaVoluntarioScreen({super.key});

  @override
  ConsumerState<MapaVoluntarioScreen> createState() =>
      _MapaVoluntarioScreenState();
}

class _MapaVoluntarioScreenState extends ConsumerState<MapaVoluntarioScreen> {
  final _busquedaCtrl = TextEditingController();
  final _mapa = MapController();
  String _consulta = '';
  bool _mapaListo = false;
  bool _centradoEnMi = false;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    _mapa.dispose();
    super.dispose();
  }

  void _centrar(Position? posicion) {
    if (posicion == null || !_mapaListo) return;
    _mapa.move(LatLng(posicion.latitude, posicion.longitude), 15);
  }

  void _zoom(double delta) {
    if (!_mapaListo) return;
    final camara = _mapa.camera;
    _mapa.move(
        camara.center, (camara.zoom + delta).clamp(3.0, 19.0).toDouble());
  }

  AsignacionModel? _asignacionDe(String solicitudId) {
    final tareas = ref.read(misTareasProvider).valueOrNull;
    if (tareas == null) return null;
    for (final a in tareas) {
      if (a.solicitudId == solicitudId) return a;
    }
    return null;
  }

  Future<void> _refrescar() async {
    ref.invalidate(miUbicacionProvider);
    try {
      await Future.wait([
        ref.refresh(casosOrganizacionProvider.future),
        ref.refresh(misTareasProvider.future),
      ]);
    } catch (_) {
      // El mapa sigue mostrando lo último que se pudo cargar.
    }
  }

  void _verDetalle(
    SolicitudAyudaModel solicitud,
    AsignacionModel? asignacion,
    Position? posicion,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                      color: solicitud.colorTipo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(solicitud.icono,
                        color: solicitud.colorTipo, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(solicitud.titulo, style: AppTextStyles.h2),
                  ),
                  if (asignacion != null)
                    const EtiquetaEstado(
                      texto: 'En curso',
                      color: AppColors.warning,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  EtiquetaEstado(
                    texto: solicitud.nivel.textoCompleto,
                    color: solicitud.nivel.color,
                  ),
                  EtiquetaEstado(
                    texto: solicitud.estadoEtiqueta,
                    color: AppColors.info,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                solicitud.descripcion,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 8),
              Text(solicitud.ubicacionTexto, style: AppTextStyles.caption),
              if (textoDistancia(solicitud.distanciaKm(posicion)) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    textoDistancia(solicitud.distanciaKm(posicion))!,
                    style: AppTextStyles.caption,
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => asignacion?.estado == 'activa'
                            ? IncidenteEnCursoScreen(asignacion: asignacion!)
                            : DetalleIncidenteScreen(
                                solicitud: solicitud,
                                asignacion: asignacion,
                              ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Ver detalle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Marker _marcador(
    SolicitudAyudaModel solicitud, {
    required bool asignada,
    required Position? posicion,
  }) {
    final color = asignada ? AppColors.primary : AppColors.danger;
    return Marker(
      point: LatLng(solicitud.lat, solicitud.lng),
      width: 42,
      height: 42,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => _verDetalle(
          solicitud,
          asignada ? _asignacionDe(solicitud.id) : null,
          posicion,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 5),
            ],
          ),
          child: Icon(
            asignada ? Icons.assignment : Icons.warning_amber_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final casosAsync = ref.watch(casosOrganizacionProvider);
    final tareasAsync = ref.watch(misTareasProvider);
    final ocultos = ref.watch(casosOcultosProvider);
    final posicion = ref.watch(miUbicacionProvider).valueOrNull;

    final tareas = tareasAsync.valueOrNull ?? const <AsignacionModel>[];
    final porSolicitud = <String, AsignacionModel>{
      for (final a in tareas)
        if (a.solicitudId != null) a.solicitudId!: a,
    };

    // Casos abiertos de la organización + mis asignaciones activas.
    final casos = <SolicitudAyudaModel>[
      for (final s in casosAsync.valueOrNull ?? const <SolicitudAyudaModel>[])
        if (!ocultos.contains(s.id) &&
            (s.estado == 'pendiente' || porSolicitud.containsKey(s.id)))
          s,
    ];
    final idsCasos = {for (final s in casos) s.id};
    for (final a in tareas) {
      final s = a.solicitud;
      if (s != null && !idsCasos.contains(s.id)) casos.add(s);
    }

    final consulta = _consulta.trim().toLowerCase();
    final visibles = consulta.isEmpty
        ? casos
        : casos.where((s) {
            return s.titulo.toLowerCase().contains(consulta) ||
                s.descripcion.toLowerCase().contains(consulta) ||
                (s.direccion?.toLowerCase().contains(consulta) ?? false);
          }).toList();

    final centro = posicion != null
        ? LatLng(posicion.latitude, posicion.longitude)
        : casos.isNotEmpty
            ? LatLng(casos.first.lat, casos.first.lng)
            : const LatLng(4.7110, -74.0721); // Bogotá por defecto.

    // Cuando el GPS responde después del primer build, se centra una vez.
    if (posicion != null && !_centradoEnMi) {
      _centradoEnMi = true;
      if (_mapaListo) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _mapaListo) {
            _mapa.move(
              LatLng(posicion.latitude, posicion.longitude),
              15,
            );
          }
        });
      }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapa,
          options: MapOptions(
            initialCenter: centro,
            initialZoom: 15,
            onMapReady: () => _mapaListo = true,
          ),
          children: [
            TileLayer(
              urlTemplate: Env.mapTileUrl,
              userAgentPackageName: 'co.rescate360.app',
            ),
            MarkerLayer(
              markers: [
                for (final s in visibles)
                  _marcador(
                    s,
                    asignada: porSolicitud.containsKey(s.id),
                    posicion: posicion,
                  ),
                if (posicion != null)
                  Marker(
                    point: LatLng(posicion.latitude, posicion.longitude),
                    width: 26,
                    height: 26,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x553E7BFA),
                            blurRadius: 10,
                            spreadRadius: 4,
                          ),
                        ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
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
                      onSubmitted: (_) {
                        if (visibles.isEmpty || !_mapaListo) return;
                        _mapa.move(
                          LatLng(visibles.first.lat, visibles.first.lng),
                          17,
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar en el mapa',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textMuted, size: 22),
                        suffixIcon: _consulta.isEmpty
                            ? IconButton(
                                icon: const Icon(Icons.refresh,
                                    color: AppColors.textMuted, size: 20),
                                tooltip: 'Actualizar',
                                onPressed: _refrescar,
                              )
                            : IconButton(
                                icon: const Icon(Icons.close,
                                    color: AppColors.textMuted, size: 20),
                                onPressed: () {
                                  _busquedaCtrl.clear();
                                  setState(() => _consulta = '');
                                },
                              ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                  if (posicion == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Material(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.location_off_outlined,
                                  size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Sin tu ubicación: activa el GPS para verte '
                                  'en el mapa.',
                                  style: AppTextStyles.caption,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    ref.invalidate(miUbicacionProvider),
                                child: const Text('Activar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (consulta.isNotEmpty && visibles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Sin resultados para tu búsqueda.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Leyenda
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Leyenda(
                  icono: Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  texto: 'Incidente',
                ),
                SizedBox(height: 6),
                _Leyenda(
                  icono: Icons.assignment,
                  color: AppColors.primary,
                  texto: 'Asignación',
                ),
                SizedBox(height: 6),
                _Leyenda(
                  icono: Icons.circle,
                  color: AppColors.info,
                  texto: 'Mi ubicación',
                  tamanoIcono: 12,
                ),
              ],
            ),
          ),
        ),
        // Controles del mapa
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              _BotonMapa(
                icono: Icons.add,
                tooltip: 'Acercar',
                onTap: () => _zoom(1),
              ),
              const SizedBox(height: 8),
              _BotonMapa(
                icono: Icons.remove,
                tooltip: 'Alejar',
                onTap: () => _zoom(-1),
              ),
              const SizedBox(height: 8),
              _BotonMapa(
                icono: Icons.my_location,
                tooltip: 'Mi ubicación',
                onTap: () => _centrar(posicion),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Leyenda extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  final double tamanoIcono;

  const _Leyenda({
    required this.icono,
    required this.color,
    required this.texto,
    this.tamanoIcono = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: color, size: tamanoIcono),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BotonMapa extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final VoidCallback onTap;

  const _BotonMapa({
    required this.icono,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icono, color: AppColors.primary, size: 22),
      ),
    );
  }
}
