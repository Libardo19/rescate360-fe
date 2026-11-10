import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../reportes/data/models/reporte_model.dart';
import '../../../reportes/data/repositories/reportes_repository.dart';
import '../../data/models/marcador_mapa_model.dart';
import 'tipo_punto.dart';

/// Detalle completo de un reporte (con sus fotos), para la hoja del mapa.
final detalleReporteProvider = FutureProvider.autoDispose.family<ReporteCiudadano, String>(
  (ref, id) => ref.watch(reportesRepositoryProvider).detalle(id),
);

/// Abre la hoja con la información completa del punto que se tocó en el mapa.
/// Si es un incidente, trae su detalle del backend con las fotos.
Future<void> mostrarDetallePunto(
  BuildContext context, {
  required MarcadorMapaModel punto,
  required String distancia,
  required VoidCallback onCentrar,
}) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: tipoDePunto(punto) == TipoPunto.incidente ? 0.72 : 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scroll) => _Hoja(
        punto: punto,
        distancia: distancia,
        scroll: scroll,
        onCentrar: onCentrar,
      ),
    ),
  );
}

class _Hoja extends ConsumerWidget {
  final MarcadorMapaModel punto;
  final String distancia;
  final ScrollController scroll;
  final VoidCallback onCentrar;

  const _Hoja({required this.punto, required this.distancia, required this.scroll, required this.onCentrar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipo = tipoDePunto(punto);
    final esReporte = tipo == TipoPunto.incidente;
    final detalle = esReporte ? ref.watch(detalleReporteProvider(punto.id)) : null;
    final reporte = detalle?.valueOrNull;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.surfaceBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          if (esReporte) ...[
            _Galeria(detalle: detalle!, tipo: tipo),
            const SizedBox(height: 16),
          ],
          _Cabecera(
            tipo: tipo,
            titulo: reporte?.tipoEtiqueta ?? punto.titulo,
            estado: reporte?.estado.valor ?? punto.estado,
            prioridad: punto.prioridad,
            propio: punto.propio,
          ),
          const SizedBox(height: 14),
          Text(
            reporte?.descripcion ?? punto.detalle,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.45),
          ),
          if (detalle != null && detalle.hasError) ...[
            const SizedBox(height: 10),
            _AvisoError(
              mensaje: ApiException.desde(detalle.error!).mensaje,
              onReintentar: () => ref.invalidate(detalleReporteProvider(punto.id)),
            ),
          ],
          const SizedBox(height: 16),
          _Datos(
            filas: [
              (
                Icons.place_outlined,
                reporte?.lugar ?? (punto.aproximada ? 'Ubicación aproximada' : 'Ubicación exacta'),
                distancia,
              ),
              if (reporte != null) (Icons.schedule_rounded, reporte.haceCuanto, _fecha(reporte.fecha)),
              if (reporte != null && reporte.videos > 0)
                (
                  Icons.videocam_outlined,
                  reporte.videos == 1 ? '1 video adjunto' : '${reporte.videos} videos adjuntos',
                  'Se pueden ver desde el panel de la organización',
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCentrar();
                  },
                  icon: const Icon(Icons.center_focus_strong_outlined, size: 20),
                  label: const Text('Ver en el mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${punto.lat},${punto.lng}'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.directions_rounded, size: 20),
                  label: const Text('Cómo llegar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

  /// "9 nov · 3:05 p. m."
  static String _fecha(DateTime f) {
    final hora = f.hour % 12 == 0 ? 12 : f.hour % 12;
    final minutos = f.minute.toString().padLeft(2, '0');
    return '${f.day} ${_meses[f.month - 1]} · $hora:$minutos ${f.hour < 12 ? 'a. m.' : 'p. m.'}';
  }
}

/// Fotos del reporte en un carrusel; al tocarlas se abren a pantalla completa.
class _Galeria extends StatefulWidget {
  final AsyncValue<ReporteCiudadano> detalle;
  final TipoPunto tipo;

  const _Galeria({required this.detalle, required this.tipo});

  @override
  State<_Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<_Galeria> {
  final _paginas = PageController();
  int _actual = 0;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const alto = 210.0;
    final radio = BorderRadius.circular(20);
    final reporte = widget.detalle.valueOrNull;

    if (reporte == null) {
      // Cargando (o sin detalle): un espacio con el color del tipo mientras llega
      return Container(
        height: widget.detalle.isLoading ? alto : 0,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: radio),
        alignment: Alignment.center,
        child: widget.detalle.isLoading
            ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5))
            : null,
      );
    }

    final fotos = reporte.fotos;
    if (fotos.isEmpty) {
      return Container(
        height: 92,
        decoration: BoxDecoration(color: widget.tipo.color.withValues(alpha: 0.07), borderRadius: radio),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hide_image_outlined, color: widget.tipo.color.withValues(alpha: 0.7)),
            const SizedBox(width: 10),
            const Text('Este reporte no tiene fotos', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return SizedBox(
      height: alto,
      child: ClipRRect(
        borderRadius: radio,
        child: Stack(
          children: [
            PageView.builder(
              controller: _paginas,
              itemCount: fotos.length,
              onPageChanged: (i) => setState(() => _actual = i),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _abrirVisor(context, fotos, i),
                child: Hero(
                  tag: fotos[i],
                  child: _Foto(url: fotos[i], ajuste: BoxFit.cover),
                ),
              ),
            ),
            // Cuántas hay y en cuál vas
            if (fotos.length > 1) ...[
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_actual + 1}/${fotos.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < fotos.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _actual ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: i == _actual ? 1 : 0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_out_map_rounded, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text('Toca para ampliar', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirVisor(BuildContext context, List<String> fotos, int inicial) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, animacion, __) => FadeTransition(
        opacity: animacion,
        child: _VisorFotos(fotos: fotos, inicial: inicial),
      ),
    ));
  }
}

/// Fotos a pantalla completa: se pasan de lado y se amplían con dos dedos.
class _VisorFotos extends StatefulWidget {
  final List<String> fotos;
  final int inicial;

  const _VisorFotos({required this.fotos, required this.inicial});

  @override
  State<_VisorFotos> createState() => _VisorFotosState();
}

class _VisorFotosState extends State<_VisorFotos> {
  late final _paginas = PageController(initialPage: widget.inicial);
  late int _actual = widget.inicial;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _paginas,
              itemCount: widget.fotos.length,
              onPageChanged: (i) => setState(() => _actual = i),
              itemBuilder: (context, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Hero(tag: widget.fotos[i], child: _Foto(url: widget.fotos[i], ajuste: BoxFit.contain)),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.15)),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                    const Spacer(),
                    if (widget.fotos.length > 1)
                      Text(
                        '${_actual + 1} de ${widget.fotos.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Foto extends StatelessWidget {
  final String url;
  final BoxFit ajuste;

  const _Foto({required this.url, required this.ajuste});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      urlArchivo(url),
      fit: ajuste,
      width: double.infinity,
      height: ajuste == BoxFit.cover ? double.infinity : null,
      semanticLabel: 'Foto del reporte',
      loadingBuilder: (context, hijo, progreso) => progreso == null
          ? hijo
          : const ColoredBox(
              color: AppColors.surface,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            ),
      errorBuilder: (context, _, __) => const ColoredBox(
        color: AppColors.surface,
        child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 36)),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final TipoPunto tipo;
  final String titulo;
  final String estado;
  final String? prioridad;
  final bool propio;

  const _Cabecera({
    required this.tipo,
    required this.titulo,
    required this.estado,
    required this.prioridad,
    required this.propio,
  });

  static (String, Color) _estado(String valor) => switch (valor) {
        'verificado' => ('Verificado', AppColors.success),
        'atendido' => ('Atendido', AppColors.info),
        'en_proceso' || 'asignada' || 'en_atencion' => ('En atención', AppColors.info),
        'pendiente' => ('Pendiente de verificación', AppColors.warning),
        'activa' => ('Activa', AppColors.danger),
        'activo' => ('Activo', AppColors.success),
        _ when valor.isEmpty => ('Sin estado', AppColors.textSecondary),
        _ => (
            '${valor[0].toUpperCase()}${valor.substring(1).replaceAll('_', ' ')}',
            AppColors.textSecondary,
          ),
      };

  static (String, Color)? _prioridad(String? valor) => switch (valor) {
        'critica' => ('Crítica', const Color(0xFFB42318)),
        'alta' => ('Prioridad alta', AppColors.danger),
        'media' => ('Prioridad media', AppColors.warning),
        'baja' => ('Prioridad baja', AppColors.success),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final (textoEstado, colorEstado) = _estado(estado);
    final prioridadVisible = _prioridad(prioridad);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tipo.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(tipo.icono, color: tipo.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo.etiqueta.toUpperCase(),
                    style: TextStyle(
                      color: tipo.color,
                      fontSize: 11,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titulo,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Chip(texto: textoEstado, color: colorEstado),
            if (prioridadVisible != null) _Chip(texto: prioridadVisible.$1, color: prioridadVisible.$2),
            if (propio) const _Chip(texto: 'Tuyo', color: AppColors.primary),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final Color color;

  const _Chip({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(texto, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Filas de información: ícono, dato principal y uno secundario.
class _Datos extends StatelessWidget {
  final List<(IconData, String, String)> filas;

  const _Datos({required this.filas});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < filas.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 52, color: AppColors.surfaceBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(filas[i].$1, color: AppColors.textSecondary, size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filas[i].$2,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (filas[i].$3.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(filas[i].$3, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvisoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _AvisoError({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No se pudieron cargar las fotos. $mensaje',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
