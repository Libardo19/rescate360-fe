import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/curvas_de_nivel.dart';
import '../../../../shared/widgets/galeria_fotos.dart';
import '../../data/models/reporte_model.dart';
import '../viewmodels/reportes_viewmodel.dart';
import '../widgets/selector_tipo_incidente.dart';
import 'mis_reportes_screen.dart' show EstadoReporteCiudadanoUi;

/// Detalle de un reporte: sus fotos arriba, la descripción completa, el seguimiento
/// (reportado → verificado → atendido) y dónde fue. Muestra de una vez lo que trae la lista y
/// completa con GET /reportes/{id} (fotos, dirección, fecha de verificación).
/// De otros ciudadanos no se muestra quién reportó: el backend lo protege (Ley 1581).
class DetalleReporteScreen extends ConsumerWidget {
  final ReporteCiudadano reporte;

  const DetalleReporteScreen({super.key, required this.reporte});

  static const _fondo = Color(0xFFF5F7FC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalle = ref.watch(detalleReporteProvider(reporte.id));
    // Lo de la lista mientras llega el detalle; quién es el dueño lo sabe la lista
    final r = detalle.valueOrNull ?? reporte;
    final tipo = buscarTipoIncidente(r.tipo);
    final color = tipo?.color ?? AppColors.primary;
    final hayFotos = r.fotos.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _fondo,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: hayFotos ? 300 : 200,
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton.filled(
                  tooltip: 'Volver',
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.3)),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: hayFotos
                    ? GaleriaFotos(fotos: r.fotos, alto: 300, radio: BorderRadius.zero)
                    : _PortadaSinFotos(icono: tipo?.icono ?? Icons.report_outlined, color: color),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'INCIDENTE · ${r.haceCuanto.toUpperCase()}',
                      style: TextStyle(color: color, fontSize: 11.5, letterSpacing: 0.6, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tipo?.etiqueta ?? r.tipoEtiqueta,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Pildora(texto: r.estado.etiqueta, icono: r.estado.icono, color: r.estado.color),
                        if (reporte.esMio)
                          const _Pildora(texto: 'Tu reporte', icono: Icons.person_rounded, color: AppColors.primary),
                        if (r.videos > 0)
                          _Pildora(
                            texto: r.videos == 1 ? '1 video' : '${r.videos} videos',
                            icono: Icons.videocam_outlined,
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),
                    if (detalle.isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(minHeight: 2, color: AppColors.primary),
                    ],
                    const SizedBox(height: 16),
                    _Tarjeta(
                      titulo: 'Qué está pasando',
                      child: Text(
                        r.descripcion,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Tarjeta(titulo: 'Seguimiento', child: _Seguimiento(reporte: r)),
                    const SizedBox(height: 12),
                    _Tarjeta(
                      titulo: 'Detalles',
                      child: Column(
                        children: [
                          _Fila(icono: Icons.place_outlined, titulo: r.lugar, subtitulo: 'Ubicación del incidente'),
                          const Divider(height: 20, color: AppColors.surfaceBorder),
                          _Fila(
                            icono: Icons.schedule_rounded,
                            titulo: _fecha(r.fecha),
                            subtitulo: 'Fecha del reporte',
                          ),
                          const Divider(height: 20, color: AppColors.surfaceBorder),
                          _Fila(
                            icono: reporte.esMio ? Icons.person_outline_rounded : Icons.shield_outlined,
                            titulo: reporte.esMio ? 'Reportado por ti' : 'Reportado por un ciudadano',
                            subtitulo: reporte.esMio
                                ? 'Solo tú y la organización ven tus datos'
                                : 'Por su seguridad, su identidad no se muestra',
                          ),
                        ],
                      ),
                    ),
                    if (r.lat != null && r.lng != null) ...[
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${r.lat},${r.lng}'),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.directions_rounded, size: 20),
                        label: const Text('Cómo llegar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(50),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
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

const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// "9 nov 2026 · 3:05 p. m."
String _fecha(DateTime f) {
  final hora = f.hour % 12 == 0 ? 12 : f.hour % 12;
  final minutos = f.minute.toString().padLeft(2, '0');
  return '${f.day} ${_meses[f.month - 1]} ${f.year} · $hora:$minutos ${f.hour < 12 ? 'a. m.' : 'p. m.'}';
}

/// Sin fotos: degradado azul con el ícono del tipo y curvas de nivel.
class _PortadaSinFotos extends StatelessWidget {
  final IconData icono;
  final Color color;

  const _PortadaSinFotos({required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14336F), AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: CustomPaint(painter: CurvasDeNivelPainter())),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 2)],
                ),
                child: Icon(icono, color: color, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final String titulo;
  final Widget child;

  const _Tarjeta({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0D081C42), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Pildora extends StatelessWidget {
  final String texto;
  final IconData icono;
  final Color color;

  const _Pildora({required this.texto, required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: color),
          const SizedBox(width: 5),
          Text(texto, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;

  const _Fila({required this.icono, required this.titulo, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Icon(icono, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 1),
              Text(subtitulo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Línea de tiempo: Reportado → Verificado → Atendido. Si se rechazó o se marcó como duplicado,
/// ese paso queda en rojo o gris con el motivo.
class _Seguimiento extends StatelessWidget {
  final ReporteCiudadano reporte;

  const _Seguimiento({required this.reporte});

  @override
  Widget build(BuildContext context) {
    final e = reporte.estado;
    final cerradoSinVerificar = e == EstadoReporteCiudadano.rechazado ||
        e == EstadoReporteCiudadano.duplicado ||
        e == EstadoReporteCiudadano.noVerificable;
    final verificado = e == EstadoReporteCiudadano.verificado || e == EstadoReporteCiudadano.atendido;

    final pasos = <_Paso>[
      _Paso(
        titulo: 'Reportado',
        detalle: _fecha(reporte.fecha),
        hecho: true,
        color: AppColors.primary,
        icono: Icons.campaign_rounded,
      ),
      if (cerradoSinVerificar)
        _Paso(
          titulo: e.etiqueta,
          detalle: reporte.motivoRechazo ??
              (e == EstadoReporteCiudadano.noVerificable
                  ? 'Nadie pudo confirmarlo a tiempo'
                  : 'La organización lo revisó y lo cerró'),
          hecho: true,
          color: e.color,
          icono: e.icono,
        )
      else
        _Paso(
          titulo: verificado ? 'Verificado por la organización' : 'En revisión',
          detalle: verificado
              ? (reporte.verificadoEn != null ? _fecha(reporte.verificadoEn!) : 'Confirmado por un administrador')
              : 'Un administrador lo está revisando',
          hecho: verificado,
          color: AppColors.success,
          icono: verificado ? Icons.verified_rounded : Icons.hourglass_top_rounded,
        ),
      if (!cerradoSinVerificar)
        _Paso(
          titulo: e == EstadoReporteCiudadano.atendido ? 'Atendido' : 'Atención en camino',
          detalle: e == EstadoReporteCiudadano.atendido
              ? 'Un voluntario lo atendió y lo cerró'
              : 'Cuando un voluntario lo atienda aparecerá aquí',
          hecho: e == EstadoReporteCiudadano.atendido,
          color: const Color(0xFF2F63E0),
          icono: Icons.task_alt_rounded,
        ),
    ];

    return Column(
      children: [
        for (var i = 0; i < pasos.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: pasos[i].hecho ? pasos[i].color : AppColors.surface,
                          shape: BoxShape.circle,
                          border: pasos[i].hecho ? null : Border.all(color: AppColors.surfaceBorder, width: 1.5),
                        ),
                        child: Icon(
                          pasos[i].icono,
                          size: 17,
                          color: pasos[i].hecho ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                      if (i < pasos.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            color: pasos[i + 1].hecho ? pasos[i + 1].color.withValues(alpha: 0.5) : AppColors.surfaceBorder,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: i < pasos.length - 1 ? 16 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pasos[i].titulo,
                          style: TextStyle(
                            color: pasos[i].hecho ? AppColors.textPrimary : AppColors.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pasos[i].detalle,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Paso {
  final String titulo;
  final String detalle;
  final bool hecho;
  final Color color;
  final IconData icono;

  const _Paso({
    required this.titulo,
    required this.detalle,
    required this.hecho,
    required this.color,
    required this.icono,
  });
}
