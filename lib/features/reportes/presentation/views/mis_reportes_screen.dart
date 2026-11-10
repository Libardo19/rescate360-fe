import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/curvas_de_nivel.dart';
import '../../../../shared/widgets/galeria_fotos.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/reporte_model.dart';
import '../viewmodels/reportes_viewmodel.dart';
import '../widgets/selector_tipo_incidente.dart';
import 'detalle_reporte_screen.dart';

extension EstadoReporteCiudadanoUi on EstadoReporteCiudadano {
  String get etiqueta {
    switch (this) {
      case EstadoReporteCiudadano.pendiente:
        return 'Pendiente';
      case EstadoReporteCiudadano.verificado:
        return 'Verificado';
      case EstadoReporteCiudadano.rechazado:
        return 'Rechazado';
      case EstadoReporteCiudadano.duplicado:
        return 'Duplicado';
      case EstadoReporteCiudadano.noVerificable:
        return 'No verificable';
      case EstadoReporteCiudadano.atendido:
        return 'Atendido';
    }
  }

  Color get color {
    switch (this) {
      case EstadoReporteCiudadano.pendiente:
        return const Color(0xFFD98A00);
      case EstadoReporteCiudadano.verificado:
        return AppColors.success;
      case EstadoReporteCiudadano.atendido:
        return const Color(0xFF2F63E0);
      case EstadoReporteCiudadano.rechazado:
        return AppColors.danger;
      case EstadoReporteCiudadano.duplicado:
      case EstadoReporteCiudadano.noVerificable:
        return AppColors.textMuted;
    }
  }

  IconData get icono {
    switch (this) {
      case EstadoReporteCiudadano.pendiente:
        return Icons.hourglass_top_rounded;
      case EstadoReporteCiudadano.verificado:
        return Icons.verified_rounded;
      case EstadoReporteCiudadano.atendido:
        return Icons.task_alt_rounded;
      case EstadoReporteCiudadano.rechazado:
        return Icons.cancel_outlined;
      case EstadoReporteCiudadano.duplicado:
        return Icons.copy_all_rounded;
      case EstadoReporteCiudadano.noVerificable:
        return Icons.help_outline_rounded;
    }
  }
}

/// Pestaña "Reportes": los tuyos (en cualquier estado) y los verificados de la comunidad,
/// con filtro por tipo de incidente.
class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  static const _fondo = Color(0xFFF5F7FC);

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
      // "Otro" agrupa los tipos que el ciudadano escribió y no están en la lista
      final pasaTipo = _tipoFiltro == null ||
          r.tipo == _tipoFiltro ||
          (_tipoFiltro == 'otro' && buscarTipoIncidente(r.tipo) == null);
      return pasaPestana && pasaTipo;
    }).toList();
  }

  void _reportar() => Navigator.of(context).pushNamed('/reportar-incidente');

  void _verDetalle(ReporteCiudadano r) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetalleReporteScreen(reporte: r)));
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(reportesCiudadanoProvider);
    final todos = estado.valueOrNull ?? const <ReporteCiudadano>[];
    final cantidadMios = todos.where((r) => r.esMio).length;
    final verificados = todos.where((r) => r.estado == EstadoReporteCiudadano.verificado).length;
    final lista = _filtrar(todos);

    final Widget contenido;
    if (estado.isLoading && todos.isEmpty) {
      contenido = const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    } else if (estado.hasError && todos.isEmpty) {
      contenido = const SliverFillRemaining(
        hasScrollBody: false,
        child: _Vacio(
          icono: Icons.wifi_off_rounded,
          titulo: 'No se pudieron cargar los reportes',
          texto: 'Revisa tu conexión y desliza hacia abajo para reintentar.',
        ),
      );
    } else if (lista.isEmpty) {
      final sinNada = _pestana == 1 && _tipoFiltro == null;
      contenido = SliverFillRemaining(
        hasScrollBody: false,
        child: _Vacio(
          icono: Icons.assignment_outlined,
          titulo: sinNada ? 'Aún no has reportado nada' : 'No hay reportes aquí',
          texto: sinNada
              ? 'Cuando reportes un incidente, aparecerá en esta lista.'
              : 'Prueba con otro tipo de incidente.',
          accion: sinNada ? _reportar : null,
        ),
      );
    } else {
      contenido = SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        sliver: SliverList.separated(
          itemCount: lista.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _TarjetaReporte(reporte: lista[i], onTap: () => _verDetalle(lista[i])),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _fondo,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_reportes',
        onPressed: _reportar,
        isExtended: _extendido,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Reportar incidente', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(reportesCiudadanoProvider.notifier).recargar(),
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Encabezado(
                total: todos.length,
                mios: cantidadMios,
                verificados: verificados,
                pestana: _pestana,
                onPestana: (i) => setState(() => _pestana = i),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
            ),
            contenido,
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final int total;
  final int mios;
  final int verificados;
  final int pestana;
  final ValueChanged<int> onPestana;

  const _Encabezado({
    required this.total,
    required this.mios,
    required this.verificados,
    required this.pestana,
    required this.onPestana,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF14336F), AppColors.primary, AppColors.primaryDark],
              stops: [0, 0.5, 1],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: CurvasDeNivelPainter()))),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reportes',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Lo que está pasando en tu comunidad',
                        style: TextStyle(color: Color(0xFFC3D2F2), fontSize: 13.5),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _Cifra(valor: total, etiqueta: 'En total', icono: Icons.layers_outlined)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _Cifra(valor: verificados, etiqueta: 'Verificados', icono: Icons.verified_outlined),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _Cifra(valor: mios, etiqueta: 'Tuyos', icono: Icons.person_outline_rounded)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _Segmentos(
                        etiquetas: const ['Todos', 'Mis reportes'],
                        indice: pestana,
                        onCambiar: onPestana,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cifra extends StatelessWidget {
  final int valor;
  final String etiqueta;
  final IconData icono;

  const _Cifra({required this.valor, required this.etiqueta, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icono, color: const Color(0xFF8FB8FF), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$valor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(etiqueta, style: const TextStyle(color: Color(0xFFC3D2F2), fontSize: 11.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dos pestañas sobre el encabezado azul: la activa es una píldora blanca que se desliza.
class _Segmentos extends StatelessWidget {
  final List<String> etiquetas;
  final int indice;
  final ValueChanged<int> onCambiar;

  const _Segmentos({required this.etiquetas, required this.indice, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    final duracion = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 240);
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: duracion,
            curve: Curves.easeOutCubic,
            alignment: indice == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 1 / etiquetas.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < etiquetas.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: indice == i,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (indice != i) HapticFeedback.selectionClick();
                        onCambiar(i);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: duracion,
                          style: TextStyle(
                            color: indice == i ? AppColors.primary : Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                          ),
                          child: Text(etiquetas[i]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
    return Semantics(
      button: true,
      selected: activo,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: activo ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: activo ? color : AppColors.surfaceBorder),
            boxShadow: activo
                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) ...[
                Icon(icono, size: 16, color: activo ? Colors.white : color),
                const SizedBox(width: 6),
              ],
              Text(
                etiqueta,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: activo ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaReporte extends StatefulWidget {
  final ReporteCiudadano reporte;
  final VoidCallback onTap;

  const _TarjetaReporte({required this.reporte, required this.onTap});

  @override
  State<_TarjetaReporte> createState() => _TarjetaReporteState();
}

class _TarjetaReporteState extends State<_TarjetaReporte> {
  bool _presionada = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.reporte;
    final tipo = buscarTipoIncidente(r.tipo);
    final color = tipo?.color ?? AppColors.textSecondary;
    final adjuntos = r.fotos.length + r.videos;

    return Semantics(
      button: true,
      label: '${tipo?.etiqueta ?? r.tipoEtiqueta}, ${r.estado.etiqueta}${r.esMio ? ', tuyo' : ''}. ${r.descripcion}',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _presionada = true),
        onTapCancel: () => setState(() => _presionada = false),
        onTapUp: (_) => setState(() => _presionada = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _presionada ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder.withValues(alpha: 0.7)),
              boxShadow: const [BoxShadow(color: Color(0x0D081C42), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // La primera foto si tiene; si no, el ícono del tipo
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: r.fotos.isNotEmpty
                        ? FotoRed(url: r.fotos.first)
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [color.withValues(alpha: 0.10), color.withValues(alpha: 0.22)],
                              ),
                            ),
                            child: Icon(tipo?.icono ?? Icons.report_outlined, color: color, size: 28),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tipo?.etiqueta ?? r.tipoEtiqueta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (r.esMio) ...[
                            const SizedBox(width: 6),
                            const _Insignia(texto: 'Tuyo', color: AppColors.primary),
                          ],
                          const Spacer(),
                          Text(r.haceCuanto, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.35),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _EstadoPildora(estado: r.estado),
                          const SizedBox(width: 8),
                          const Icon(Icons.place_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              r.lugar,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ),
                          if (adjuntos > 0) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.photo_library_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Text('$adjuntos', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstadoPildora extends StatelessWidget {
  final EstadoReporteCiudadano estado;

  const _EstadoPildora({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: estado.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(estado.icono, size: 13, color: estado.color),
          const SizedBox(width: 4),
          Text(estado.etiqueta, style: TextStyle(color: estado.color, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Insignia extends StatelessWidget {
  final String texto;
  final Color color;

  const _Insignia({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(texto, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }
}

class _Vacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;
  final VoidCallback? accion;

  const _Vacio({required this.icono, required this.titulo, required this.texto, this.accion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.primary.withValues(alpha: 0.16),
              ]),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          if (accion != null) ...[
            const SizedBox(height: 20),
            PrimaryButton(label: 'Reportar incidente', icon: Icons.add_alert_outlined, onPressed: accion!),
          ],
        ],
      ),
    );
  }
}
