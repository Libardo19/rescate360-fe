import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/galeria_fotos.dart';
import '../../../reportes/data/models/reporte_model.dart';
import '../../../reportes/presentation/viewmodels/reportes_viewmodel.dart';
import '../../data/models/marcador_mapa_model.dart';
import 'tipo_punto.dart';

export '../../../reportes/presentation/viewmodels/reportes_viewmodel.dart'
    show detalleReporteProvider;

/// Abre la hoja con la información completa del punto que se tocó en el mapa.
/// Si es un incidente, trae su detalle del backend con las fotos.
Future<void> mostrarDetallePunto(
  BuildContext context, {
  required MarcadorMapaModel punto,
  required String distancia,
  required VoidCallback onCentrar,
  VoidCallback? onAbrirCaso,
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
        onAbrirCaso: onAbrirCaso,
      ),
    ),
  );
}

class _Hoja extends ConsumerWidget {
  final MarcadorMapaModel punto;
  final String distancia;
  final ScrollController scroll;
  final VoidCallback onCentrar;
  final VoidCallback? onAbrirCaso;

  const _Hoja(
      {required this.punto,
      required this.distancia,
      required this.scroll,
      required this.onCentrar,
      this.onAbrirCaso});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipo = tipoDePunto(punto);
    final esReporte = tipo == TipoPunto.incidente;
    final detalle =
        esReporte ? ref.watch(detalleReporteProvider(punto.id)) : null;
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
              decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2)),
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
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 15, height: 1.45),
          ),
          if (detalle != null && detalle.hasError) ...[
            const SizedBox(height: 10),
            _AvisoError(
              mensaje: ApiException.desde(detalle.error!).mensaje,
              onReintentar: () =>
                  ref.invalidate(detalleReporteProvider(punto.id)),
            ),
          ],
          const SizedBox(height: 16),
          _Datos(
            filas: [
              (
                Icons.place_outlined,
                reporte?.lugar ??
                    (punto.aproximada
                        ? 'Ubicación aproximada'
                        : 'Ubicación exacta'),
                distancia,
              ),
              if (reporte != null)
                (
                  Icons.schedule_rounded,
                  reporte.haceCuanto,
                  _fecha(reporte.fecha)
                ),
              if (reporte != null && reporte.videos > 0)
                (
                  Icons.videocam_outlined,
                  reporte.videos == 1
                      ? '1 video adjunto'
                      : '${reporte.videos} videos adjuntos',
                  'Se pueden ver desde el panel de la organización',
                ),
            ],
          ),
          if (onAbrirCaso != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onAbrirCaso!();
              },
              icon: const Icon(Icons.assignment_ind_outlined),
              label: const Text('Gestionar este caso'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCentrar();
                  },
                  icon:
                      const Icon(Icons.center_focus_strong_outlined, size: 20),
                  label: const Text('Ver en el mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&destination=${punto.lat},${punto.lng}'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.directions_rounded, size: 20),
                  label: const Text('Cómo llegar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic'
  ];

  /// "9 nov · 3:05 p. m."
  static String _fecha(DateTime f) {
    final hora = f.hour % 12 == 0 ? 12 : f.hour % 12;
    final minutos = f.minute.toString().padLeft(2, '0');
    return '${f.day} ${_meses[f.month - 1]} · $hora:$minutos ${f.hour < 12 ? 'a. m.' : 'p. m.'}';
  }
}

/// Fotos del reporte (o su espacio mientras cargan). Al tocarlas se abren a pantalla completa.
class _Galeria extends StatelessWidget {
  final AsyncValue<ReporteCiudadano> detalle;
  final TipoPunto tipo;

  const _Galeria({required this.detalle, required this.tipo});

  @override
  Widget build(BuildContext context) {
    const alto = 210.0;
    final radio = BorderRadius.circular(20);
    final reporte = detalle.valueOrNull;

    if (reporte == null) {
      // Cargando (o sin detalle): un espacio mientras llega
      return Container(
        height: detalle.isLoading ? alto : 0,
        decoration:
            BoxDecoration(color: AppColors.surface, borderRadius: radio),
        alignment: Alignment.center,
        child: detalle.isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.5))
            : null,
      );
    }

    if (reporte.fotos.isEmpty) {
      return Container(
        height: 92,
        decoration: BoxDecoration(
            color: tipo.color.withValues(alpha: 0.07), borderRadius: radio),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hide_image_outlined,
                color: tipo.color.withValues(alpha: 0.7)),
            const SizedBox(width: 10),
            const Text('Este reporte no tiene fotos',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return GaleriaFotos(fotos: reporte.fotos, alto: alto, radio: radio);
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
        'en_proceso' || 'asignada' || 'en_atencion' => (
            'En atención',
            AppColors.info
          ),
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
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
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
            if (prioridadVisible != null)
              _Chip(texto: prioridadVisible.$1, color: prioridadVisible.$2),
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
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(texto,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
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
            if (i > 0)
              const Divider(
                  height: 1, indent: 52, color: AppColors.surfaceBorder),
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
                          Text(filas[i].$3,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
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
          const Icon(Icons.info_outline_rounded,
              color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No se pudieron cargar las fotos. $mensaje',
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
