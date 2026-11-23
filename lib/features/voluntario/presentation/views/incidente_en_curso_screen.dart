import 'dart:async';
import '../../../../shared/widgets/galeria_fotos.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/config/env.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../data/models/asignacion_model.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../viewmodels/voluntario_viewmodel.dart';
import '../widgets/voluntario_ui.dart';
import 'actualizar_estado_screen.dart';

/// Incidente en curso (mockup 11): resumen, mapa, tiempo transcurrido y
/// acceso a actualizar el estado o finalizar el caso.
class IncidenteEnCursoScreen extends ConsumerStatefulWidget {
  final AsignacionModel asignacion;

  const IncidenteEnCursoScreen({super.key, required this.asignacion});

  @override
  ConsumerState<IncidenteEnCursoScreen> createState() =>
      _IncidenteEnCursoScreenState();
}

class _IncidenteEnCursoScreenState
    extends ConsumerState<IncidenteEnCursoScreen> {
  Future<void> _actualizarEstado() async {
    final paso = await Navigator.of(context).push<PasoAtencion>(
      MaterialPageRoute(
        builder: (_) => ActualizarEstadoScreen(asignacion: widget.asignacion),
      ),
    );
    if (!mounted || paso == null) return;
    if (paso == PasoAtencion.finalizado) {
      await _finalizar(confirmar: false);
    }
  }

  Future<void> _finalizar({bool confirmar = true}) async {
    if (confirmar) {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Finalizar incidente'),
          content: const Text(
            '¿Confirmas que el incidente ya fue atendido? Esta acción no se '
            'puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sí, atendido'),
            ),
          ],
        ),
      );
      if (confirmado != true || !mounted) return;
    }

    final mensajero = ScaffoldMessenger.of(context);
    final error = await ref
        .read(voluntarioViewModelProvider)
        .finalizar(widget.asignacion.id);
    if (!mounted) return;

    if (error != null) {
      mensajero.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ref.read(atencionProvider.notifier).limpiar(widget.asignacion.id);
    Navigator.of(context).pop(true);
    mensajero.showSnackBar(
      const SnackBar(content: Text('Caso marcado como atendido.')),
    );
  }

  Future<void> _soltar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Soltar caso'),
        content: const Text(
          'El caso volverá a la lista de incidentes disponibles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Soltar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final mensajero = ScaffoldMessenger.of(context);
    final error = await ref
        .read(voluntarioViewModelProvider)
        .soltar(widget.asignacion.id);
    if (!mounted) return;

    if (error != null) {
      mensajero.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ref.read(atencionProvider.notifier).limpiar(widget.asignacion.id);
    Navigator.of(context).pop(true);
    mensajero.showSnackBar(
      const SnackBar(content: Text('Soltaste el caso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final solicitud = widget.asignacion.solicitud;
    if (solicitud == null) {
      // No debería abrirse para tareas de reportes (no tienen ubicación).
      return Scaffold(
        appBar: AppBar(title: const Text('En atención')),
        body: const Center(
          child: Text('Esta asignación no tiene un incidente asociado.'),
        ),
      );
    }

    final atencion = ref.watch(atencionProvider)[widget.asignacion.id] ??
        const AtencionEstado();
    final posicion = ref.watch(miUbicacionProvider).valueOrNull;
    final enSitio = atencion.fechas[PasoAtencion.enSitio];
    final inicio = enSitio ?? widget.asignacion.asignadoEn;
    final distancia = textoDistancia(solicitud.distanciaKm(posicion));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('En atención', style: AppTextStyles.h2),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (valor) {
              if (valor == 'soltar') _soltar();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'soltar', child: Text('Soltar caso')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (solicitud.evidenciaImagenes.isNotEmpty) ...[
              GaleriaFotos(fotos: solicitud.evidenciaImagenes, alto: 230),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: solicitud.colorTipo.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: solicitud.colorTipo.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: solicitud.colorTipo.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(solicitud.icono,
                        color: solicitud.colorTipo, size: 27),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solicitud.titulo,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            solicitud.nivel.textoCompleto,
                            if (distancia != null) distancia,
                          ].join(' · '),
                          style: AppTextStyles.bodySecondary,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            EtiquetaEstado(
                              texto: atencion.paso.etiqueta,
                              color: atencion.paso.color,
                            ),
                            EtiquetaEstado(
                              texto: solicitud.estadoEtiqueta,
                              color: AppColors.info,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 190,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(solicitud.lat, solicitud.lng),
                    initialZoom: 15.5,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: Env.mapTileUrl,
                      userAgentPackageName: 'co.rescate360.app',
                    ),
                    if (posicion != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(posicion.latitude, posicion.longitude),
                              LatLng(solicitud.lat, solicitud.lng),
                            ],
                            strokeWidth: 4,
                            color: AppColors.info,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(solicitud.lat, solicitud.lng),
                          width: 42,
                          height: 42,
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: solicitud.colorTipo,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(solicitud.icono,
                                color: Colors.white, size: 21),
                          ),
                        ),
                        if (posicion != null)
                          Marker(
                            point:
                                LatLng(posicion.latitude, posicion.longitude),
                            width: 22,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x553E7BFA),
                                    blurRadius: 8,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _Cronometro(
              inicio: inicio,
              titulo: enSitio != null
                  ? 'Tiempo en sitio'
                  : 'Tiempo desde la asignación',
              color: atencion.paso.color,
              icono: atencion.paso.icono,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined,
                    size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    solicitud.direccion ??
                        '${solicitud.lat.toStringAsFixed(5)}, '
                            '${solicitud.lng.toStringAsFixed(5)}',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ],
            ),
            if (atencion.notas.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notas', style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(atencion.notas, style: AppTextStyles.body),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Los pasos de la atención se guardan solo en este celular.',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _actualizarEstado,
                  icon: const Icon(Icons.timeline, size: 18),
                  label: const Text('Actualizar estado'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _finalizar(),
                  child: const Text('Finalizar incidente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cronómetro aislado: solo se reconstruye este widget cada segundo, no el
/// mapa ni el resto de la pantalla.
class _Cronometro extends StatefulWidget {
  final DateTime inicio;
  final String titulo;
  final Color color;
  final IconData icono;

  const _Cronometro({
    required this.inicio,
    required this.titulo,
    required this.color,
    required this.icono,
  });

  @override
  State<_Cronometro> createState() => _CronometroState();
}

class _CronometroState extends State<_Cronometro> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _texto {
    final d = DateTime.now().difference(widget.inicio);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icono, color: widget.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.titulo, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  _texto,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
