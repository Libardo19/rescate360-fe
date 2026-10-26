import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/modo_oscuro.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../../shared/widgets/pestanas_segmentadas.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/reporte_model.dart';
import '../viewmodels/reportes_viewmodel.dart';
import '../widgets/selector_tipo_incidente.dart';

extension EstadoReporteCiudadanoUi on EstadoReporteCiudadano {
  String get etiqueta {
    switch (this) {
      case EstadoReporteCiudadano.pendiente:
        return 'Pendiente';
      case EstadoReporteCiudadano.enRevision:
        return 'En revisión';
      case EstadoReporteCiudadano.atendido:
        return 'Atendido';
    }
  }

  Color get color {
    switch (this) {
      case EstadoReporteCiudadano.pendiente:
        return AppColors.warning;
      case EstadoReporteCiudadano.enRevision:
        return AppColors.info;
      case EstadoReporteCiudadano.atendido:
        return AppColors.success;
    }
  }
}

/// Pestaña "Reportes": todos los reportes de la comunidad o solo los míos,
/// con filtro por tipo de incidente.
class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  final _scroll = ScrollController();
  int _pestana = 0;
  String? _tipoFiltro;
  bool _extendido = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alDesplazar);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // El botón se encoge al bajar la lista y se expande al subir.
  void _alDesplazar() {
    if (!_scroll.hasClients) return;
    final direccion = _scroll.position.userScrollDirection;
    if (direccion == ScrollDirection.reverse && _extendido) {
      setState(() => _extendido = false);
    } else if (direccion == ScrollDirection.forward && !_extendido) {
      setState(() => _extendido = true);
    }
  }

  List<ReporteCiudadano> _filtrar(List<ReporteCiudadano> todos) {
    return todos.where((r) {
      final pasaPestana = _pestana == 0 || r.esMio;
      final pasaTipo = _tipoFiltro == null || r.tipo == _tipoFiltro;
      return pasaPestana && pasaTipo;
    }).toList();
  }

  void _reportar() {
    Navigator.of(context).pushNamed('/reportar-incidente');
  }

  void _verDetalle(ReporteCiudadano r) {
    final tipo = buscarTipoIncidente(r.tipo);
    final color = tipo?.color ?? AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(tipo?.icono ?? Icons.report_outlined,
                        color: color, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tipo?.etiqueta ?? 'Incidente',
                            style: AppTextStyles.h2),
                        const SizedBox(height: 2),
                        Text(r.haceCuanto, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  EtiquetaEstado(
                      texto: r.estado.etiqueta, color: r.estado.color),
                  if (r.esMio) ...[
                    const SizedBox(width: 8),
                    const EtiquetaEstado(
                        texto: 'Reporte tuyo', color: AppColors.primary),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Text(r.descripcion, style: AppTextStyles.body),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(r.lugar, style: AppTextStyles.bodySecondary),
                  ),
                ],
              ),
              if (r.fotos.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text('Fotos', style: AppTextStyles.body),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final foto in r.fotos)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: SinFiltroOscuro(
                            child: Image.memory(foto, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if (r.videos > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.videocam_outlined,
                        size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      r.videos == 1
                          ? '1 video adjunto'
                          : '${r.videos} videos adjuntos',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(reportesCiudadanoProvider);
    final cantidadMios = todos.where((r) => r.esMio).length;
    final lista = _filtrar(todos);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_reportes',
        onPressed: _reportar,
        isExtended: _extendido,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text(
          'Reportar incidente',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('Reportes', style: AppTextStyles.h1),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Lo que está pasando en tu comunidad',
                style: AppTextStyles.bodySecondary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: PestanasSegmentadas(
                etiquetas: [
                  'Todos (${todos.length})',
                  'Mis reportes ($cantidadMios)',
                ],
                indice: _pestana,
                onCambiar: (i) => setState(() => _pestana = i),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _ChipTipo(
                    etiqueta: 'Todos',
                    activo: _tipoFiltro == null,
                    onTap: () => setState(() => _tipoFiltro = null),
                  ),
                  for (final tipo in tiposIncidente) ...[
                    const SizedBox(width: 8),
                    _ChipTipo(
                      etiqueta: tipo.etiqueta,
                      icono: tipo.icono,
                      color: tipo.color,
                      activo: _tipoFiltro == tipo.id,
                      onTap: () => setState(() => _tipoFiltro = tipo.id),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: lista.isEmpty
                  ? _SinReportes(
                      esMisReportes: _pestana == 1,
                      hayFiltro: _tipoFiltro != null,
                      onReportar: _reportar,
                    )
                  : ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _TarjetaReporte(
                        reporte: lista[i],
                        onTap: () => _verDetalle(lista[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipTipo extends StatelessWidget {
  final String etiqueta;
  final IconData? icono;
  final Color color;
  final bool activo;
  final VoidCallback onTap;

  const _ChipTipo({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
    this.icono,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: activo ? color.withOpacity(0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activo ? color : AppColors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Icon(icono,
                  size: 16, color: activo ? color : AppColors.textMuted),
              const SizedBox(width: 6),
            ],
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: activo ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaReporte extends StatelessWidget {
  final ReporteCiudadano reporte;
  final VoidCallback onTap;

  const _TarjetaReporte({required this.reporte, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tipo = buscarTipoIncidente(reporte.tipo);
    final color = tipo?.color ?? AppColors.textSecondary;
    final adjuntos = reporte.fotos.length + reporte.videos;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(tipo?.icono ?? Icons.report_outlined,
                  color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tipo?.etiqueta ?? 'Incidente',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (reporte.esMio) ...[
                        const EtiquetaEstado(
                            texto: 'Tuyo', color: AppColors.primary),
                        const SizedBox(width: 6),
                      ],
                      EtiquetaEstado(
                        texto: reporte.estado.etiqueta,
                        color: reporte.estado.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reporte.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          reporte.lugar,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ),
                      if (adjuntos > 0) ...[
                        const Icon(Icons.attach_file,
                            size: 14, color: AppColors.textMuted),
                        Text('$adjuntos', style: AppTextStyles.caption),
                        const SizedBox(width: 8),
                      ],
                      Text(reporte.haceCuanto, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SinReportes extends StatelessWidget {
  final bool esMisReportes;
  final bool hayFiltro;
  final VoidCallback onReportar;

  const _SinReportes({
    required this.esMisReportes,
    required this.hayFiltro,
    required this.onReportar,
  });

  @override
  Widget build(BuildContext context) {
    final sinNada = esMisReportes && !hayFiltro;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined,
                  color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              sinNada ? 'Aún no has reportado nada' : 'No hay reportes aquí',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 6),
            Text(
              sinNada
                  ? 'Cuando reportes un incidente, aparecerá en esta lista.'
                  : 'Prueba con otro tipo de incidente.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            if (sinNada) ...[
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Reportar incidente',
                icon: Icons.add_alert_outlined,
                onPressed: onReportar,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
