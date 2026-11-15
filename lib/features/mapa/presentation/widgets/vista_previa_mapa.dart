import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import '../../../../app/theme/app_colors.dart';
import '../../../../core/config/env.dart';
import '../../../../shared/widgets/curvas_de_nivel.dart';
import '../../data/models/marcador_mapa_model.dart';
import '../viewmodels/mapa_viewmodel.dart';
import 'tipo_punto.dart';

/// Vista previa del mapa para el inicio del ciudadano.
///
/// Usa el mismo estado que la pestaña Mapa (`mapaViewModelProvider`): tu ubicación y los mismos
/// puntos, que se actualizan cada 15 s. Es solo para mirar; al tocarla se abre el mapa completo.
/// El fondo es el mismo mapa de la pestaña Mapa (`Env.mapTileUrl`).
class VistaPreviaMapa extends ConsumerStatefulWidget {
  final VoidCallback onAbrir;

  const VistaPreviaMapa({super.key, required this.onAbrir});

  static const alto = 180.0;
  // Cuántos puntos caben sin que la vista previa se vea amontonada
  static const _maximoPuntos = 12;

  @override
  ConsumerState<VistaPreviaMapa> createState() => _VistaPreviaMapaState();
}

class _VistaPreviaMapaState extends ConsumerState<VistaPreviaMapa> with SingleTickerProviderStateMixin {
  // Ondas de radar alrededor de tu ubicación
  late final _radar = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(mapaViewModelProvider.notifier).iniciarSiHaceFalta());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _radar.value = 0.35;
      _radar.stop();
    } else if (!_radar.isAnimating) {
      _radar.repeat();
    }
  }

  @override
  void dispose() {
    _radar.dispose();
    super.dispose();
  }

  void _abrir() {
    HapticFeedback.selectionClick();
    widget.onAbrir();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(mapaViewModelProvider);
    final posicion = estado.posicion;

    final Widget contenido;
    if (posicion != null) {
      contenido = _Mapa(
        yo: LatLng(posicion.lat, posicion.lng),
        puntos: _cercanos(estado.puntos.values, posicion),
        radar: _radar,
      );
    } else if (estado.cargando) {
      contenido = const _Aviso(icono: null, texto: 'Buscando tu ubicación…');
    } else {
      contenido = _Aviso(
        icono: Icons.location_off_outlined,
        texto: estado.error ?? 'Activa tu ubicación para ver lo que pasa cerca.',
        accion: estado.permisoBloqueado ? 'Abrir ajustes' : 'Reintentar',
        onAccion: estado.permisoBloqueado
            ? Geolocator.openAppSettings
            : () => ref.read(mapaViewModelProvider.notifier).iniciar(),
      );
    }

    final incidentes = estado.puntos.values.where((p) => tipoDePunto(p) == TipoPunto.incidente).length;
    final alertas = estado.puntos.values.where((p) => tipoDePunto(p) == TipoPunto.alerta).length;

    return Semantics(
      button: true,
      label: 'Mapa de incidentes cercanos. Toca para abrir el mapa.',
      child: Container(
        height: VistaPreviaMapa.alto,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.28),
              blurRadius: 24,
              spreadRadius: -8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Material(
            color: AppColors.primaryDark,
            child: InkWell(
              onTap: _abrir,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  contenido,
                  // Degradado para que el texto de abajo se lea sobre el mapa
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00081C42), Color(0x33081C42), Color(0xE6081C42)],
                          stops: [0, 0.45, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _Pie(incidentes: incidentes, alertas: alertas, hayUbicacion: posicion != null),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Los más cercanos primero, para que la vista previa muestre lo que importa.
  List<MarcadorMapaModel> _cercanos(Iterable<MarcadorMapaModel> puntos, ({double lat, double lng}) yo) {
    final lista = puntos.toList()
      ..sort((a, b) => Geolocator.distanceBetween(yo.lat, yo.lng, a.lat, a.lng)
          .compareTo(Geolocator.distanceBetween(yo.lat, yo.lng, b.lat, b.lng)));
    return lista.take(VistaPreviaMapa._maximoPuntos).toList();
  }
}

class _Mapa extends StatelessWidget {
  final LatLng yo;
  final List<MarcadorMapaModel> puntos;
  final Animation<double> radar;

  const _Mapa({required this.yo, required this.puntos, required this.radar});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            // Al moverte unos 100 m la vista previa se vuelve a centrar en ti
            key: ValueKey('${yo.latitude.toStringAsFixed(3)},${yo.longitude.toStringAsFixed(3)}'),
            options: MapOptions(
              initialCenter: yo,
              initialZoom: 14.6,
              // Mientras cargan las teselas (o sin red) se ve azul marino, no gris
              backgroundColor: AppColors.primaryDark,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              // El mismo mapa que la pestaña Mapa
              TileLayer(urlTemplate: Env.mapTileUrl, userAgentPackageName: 'co.rescate360.app'),
              MarkerLayer(
                markers: [
                  for (final p in puntos)
                    Marker(
                      point: LatLng(p.lat, p.lng),
                      width: 30,
                      height: 37,
                      alignment: Alignment.topCenter,
                      child: _Pin(tipo: tipoDePunto(p), tenue: p.aproximada),
                    ),
                ],
              ),
            ],
          ),
          // Tu ubicación queda en el centro del mapa
          Center(
            child: RepaintBoundary(
              child: CustomPaint(size: const Size(130, 130), painter: _RadarPainter(radar)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pin redondo con el ícono del tipo de punto, como en el mapa.
class _Pin extends StatelessWidget {
  final TipoPunto tipo;
  final bool tenue;

  const _Pin({required this.tipo, required this.tenue});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: tenue ? 0.75 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tipo.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: tipo.color.withValues(alpha: 0.5), blurRadius: 10)],
            ),
            child: Icon(tipo.icono, color: Colors.white, size: 15),
          ),
          CustomPaint(size: const Size(10, 8), painter: _PuntaPin(tipo.color)),
        ],
      ),
    );
  }
}

class _PuntaPin extends CustomPainter {
  final Color color;

  const _PuntaPin(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final punta = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(punta, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PuntaPin old) => old.color != color;
}

/// Tu ubicación: punto azul con ondas de radar que salen de él.
class _RadarPainter extends CustomPainter {
  final Animation<double> radar;

  _RadarPainter(this.radar) : super(repaint: radar);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maximo = size.shortestSide / 2;
    canvas.drawCircle(c, maximo * 0.55, Paint()..color = AppColors.info.withValues(alpha: 0.12));
    for (final desfase in const [0.0, 0.5]) {
      final t = (radar.value + desfase) % 1;
      canvas.drawCircle(
        c,
        10 + (maximo - 10) * t,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = AppColors.info.withValues(alpha: 0.55 * math.pow(1 - t, 1.5)),
      );
    }
    canvas.drawCircle(c, 13, Paint()..color = AppColors.info.withValues(alpha: 0.35));
    canvas.drawCircle(c, 9, Paint()..color = Colors.white);
    canvas.drawCircle(c, 6.5, Paint()..color = AppColors.info);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => false;
}

/// Mientras no hay ubicación: fondo topográfico con un mensaje.
class _Aviso extends StatelessWidget {
  final IconData? icono;
  final String texto;
  final String? accion;
  final VoidCallback? onAccion;

  const _Aviso({required this.icono, required this.texto, this.accion, this.onAccion});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
        ),
        const RepaintBoundary(child: CustomPaint(painter: CurvasDeNivelPainter())),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icono == null)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                  )
                else
                  Icon(icono, color: Colors.white70, size: 22),
                const SizedBox(height: 4),
                Text(
                  texto,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (accion != null) ...[
                  const SizedBox(height: 0),
                  TextButton(
                    onPressed: onAccion,
                    style: TextButton.styleFrom(foregroundColor: Colors.white, minimumSize: const Size(44, 36)),
                    child: Text(accion!, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Pie extends StatelessWidget {
  final int incidentes;
  final int alertas;
  final bool hayUbicacion;

  const _Pie({required this.incidentes, required this.alertas, required this.hayUbicacion});

  String get _resumen {
    if (!hayUbicacion) return 'Explora los reportes en tu zona';
    if (incidentes == 0 && alertas == 0) return 'Todo tranquilo cerca de ti';
    final partes = [
      if (incidentes > 0) '$incidentes ${incidentes == 1 ? 'incidente' : 'incidentes'}',
      if (alertas > 0) '$alertas ${alertas == 1 ? 'alerta' : 'alertas'}',
    ];
    return '${partes.join(' · ')} cerca de ti';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Icon(Icons.map_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mapa de incidentes cercanos',
                  maxLines: 1,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _resumen,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFC3D2F2), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 46,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Color(0xFF4C8DFF), Color(0xFF2F63E0)]),
            boxShadow: [BoxShadow(color: AppColors.info.withValues(alpha: 0.45), blurRadius: 12)],
          ),
          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
