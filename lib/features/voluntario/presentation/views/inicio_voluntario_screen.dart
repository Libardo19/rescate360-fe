import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/curvas_de_nivel.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../viewmodels/voluntario_viewmodel.dart';
import '../widgets/inicio_ilustraciones.dart';
import '../widgets/voluntario_ui.dart';
import 'estado_disponibilidad_screen.dart';

/// Inicio (dashboard) del voluntario, con los números reales del backend.
/// [onIrAPestana] cambia la pestaña de la barra inferior:
/// 1 Incidentes, 2 Mapa, 3 Asignaciones.
class InicioVoluntarioScreen extends ConsumerWidget {
  final ValueChanged<int> onIrAPestana;

  const InicioVoluntarioScreen({super.key, required this.onIrAPestana});

  Future<void> _refrescar(WidgetRef ref) async {
    ref.invalidate(casosOrganizacionProvider);
    ref.invalidate(misTareasProvider);
    try {
      await ref.read(casosOrganizacionProvider.future);
    } catch (_) {
      // Si falla, las tarjetas muestran "—" y se puede reintentar.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casos = ref.watch(casosOrganizacionProvider);
    final tareas = ref.watch(misTareasProvider);
    final ocultos = ref.watch(casosOcultosProvider);
    final disponibilidad = ref.watch(disponibilidadProvider);
    final nombre = ref.watch(authViewModelProvider).usuario?.primerNombre ?? '';

    final totalCasos = casos.whenData((lista) => lista.where((c) => !ocultos.contains(c.id)).length);
    final totalTareas = tareas.whenData((lista) => lista.where((a) => a.estado == 'activa').length);

    final tarjetas = <Widget>[
      _TarjetaEstado(
        disponibilidad: disponibilidad,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EstadoDisponibilidadScreen()),
        ),
      ),
      _FilaTarjetas(
        izquierda: _TarjetaAcceso(
          tono: _Tono.incidentes,
          icono: Icons.warning_amber_rounded,
          titulo: 'Incidentes cercanos',
          subtitulo: 'En tu zona de cobertura',
          conteo: totalCasos,
          ilustracion: const ZonaIncidentesPainter(_Tono.rojo),
          onTap: () => onIrAPestana(1),
        ),
        derecha: _TarjetaAcceso(
          tono: _Tono.asignaciones,
          icono: Icons.assignment_ind_rounded,
          titulo: 'Mis asignaciones',
          subtitulo: 'Tareas asignadas',
          conteo: totalTareas,
          ilustracion: const HojaConRenglonesPainter(_Tono.azul),
          onTap: () => onIrAPestana(3),
        ),
      ),
      _FilaTarjetas(
        izquierda: _TarjetaAcceso(
          tono: _Tono.mapa,
          icono: Icons.map_outlined,
          titulo: 'Mapa',
          subtitulo: 'Explora tu área',
          ilustracion: const PlanoCallesPainter(_Tono.verde),
          accion: (etiqueta: 'Ver en mapa', icono: Icons.map_outlined),
          onTap: () => onIrAPestana(2),
        ),
        derecha: _TarjetaAcceso(
          tono: _Tono.notificaciones,
          icono: Icons.notifications_none_rounded,
          titulo: 'Notificaciones',
          subtitulo: 'Mantente al día',
          ilustracion: const HojaConRenglonesPainter(_Tono.ambar, conPuntos: true),
          accion: (etiqueta: 'Ver todas', icono: Icons.notifications_none_rounded),
          onTap: () => Navigator.of(context).pushNamed(AppRouter.notificaciones),
        ),
      ),
    ];

    final sinMovimiento = MediaQuery.disableAnimationsOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Íconos claros en la barra de estado, sobre el encabezado azul.
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: _Tono.fondo,
        child: Column(
          children: [
            _Encabezado(
              nombre: nombre,
              disponibilidad: disponibilidad,
              onNotificaciones: () => Navigator.of(context).pushNamed(AppRouter.notificaciones),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _refrescar(ref),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Abajo deja espacio al botón del mapa, que sobresale de la barra.
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: tarjetas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => sinMovimiento
                      ? tarjetas[i]
                      // Entrada corta y escalonada, solo al montar la pestaña.
                      : tarjetas[i]
                          .animate(delay: (40 * i).ms)
                          .fadeIn(duration: 240.ms, curve: Curves.easeOutCubic)
                          .slideY(begin: 0.06, end: 0, duration: 240.ms, curve: Curves.easeOutCubic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paleta del inicio. Los tonos de los botones (verde y ámbar oscuro) se eligieron
/// para que su texto pase el contraste AA (4.5:1).
abstract final class _Tono {
  static const fondo = Color(0xFFF3F6FB);
  static const rojo = AppColors.danger;
  static const azul = Color(0xFF2F5BD3);
  static const verde = Color(0xFF0E7A57);
  static const ambar = Color(0xFFF2A51F);
  static const teal = Color(0xFF34C3A8);

  static const incidentes = (color: rojo, fondo: Color(0xFFFDEEEC), texto: Color(0xFFC0362F));
  static const asignaciones = (color: azul, fondo: Color(0xFFE8EEFC), texto: Color(0xFF1F45AE));
  static const mapa = (color: verde, fondo: Color(0xFFE3F4EC), texto: Colors.white);
  static const notificaciones = (color: ambar, fondo: Color(0xFFFDF1DC), texto: Color(0xFF4A3200));
}

typedef _ColoresTarjeta = ({Color color, Color fondo, Color texto});

/// Escala sutil al presionar (0.97, 140 ms ease-out): confirma el toque sin exagerar.
/// Usa [Listener] para no competir con el InkWell por el gesto.
class _Presionable extends StatefulWidget {
  final Widget child;

  const _Presionable({required this.child});

  @override
  State<_Presionable> createState() => _PresionableState();
}

class _PresionableState extends State<_Presionable> {
  bool _abajo = false;

  void _cambiar(bool abajo) {
    if (_abajo != abajo) setState(() => _abajo = abajo);
  }

  @override
  Widget build(BuildContext context) {
    final sinMovimiento = MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: (_) => _cambiar(true),
      onPointerUp: (_) => _cambiar(false),
      onPointerCancel: (_) => _cambiar(false),
      child: AnimatedScale(
        scale: _abajo && !sinMovimiento ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final String nombre;
  final EstadoDisponibilidad disponibilidad;
  final VoidCallback onNotificaciones;

  const _Encabezado({
    required this.nombre,
    required this.disponibilidad,
    required this.onNotificaciones,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'V';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF173D7A)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: RepaintBoundary(child: CustomPaint(painter: CurvasDeNivelPainter())),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6F1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        inicial,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            nombre.isEmpty ? 'Hola' : 'Hola, $nombre',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // TODO: agregar la organización cuando el modelo del
                          // usuario la exponga ("Voluntario · Bomberos...").
                          Text(
                            'Voluntario',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PildoraEstado(disponibilidad: disponibilidad),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: IconButton(
                        onPressed: onNotificaciones,
                        tooltip: 'Notificaciones',
                        style: IconButton.styleFrom(
                          fixedSize: const Size(48, 48),
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.notifications_none_rounded, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pin decorativo sobre las curvas de nivel.
            Positioned(
              right: 24,
              bottom: 16,
              child: ExcludeSemantics(
                child: Icon(
                  Icons.location_on_rounded,
                  size: 32,
                  color: _Tono.teal.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PildoraEstado extends StatelessWidget {
  final EstadoDisponibilidad disponibilidad;

  const _PildoraEstado({required this.disponibilidad});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
      decoration: BoxDecoration(
        color: disponibilidad.color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: disponibilidad.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            disponibilidad.etiqueta,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaEstado extends StatelessWidget {
  final EstadoDisponibilidad disponibilidad;
  final VoidCallback onTap;

  const _TarjetaEstado({required this.disponibilidad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = disponibilidad.color;
    final radio = BorderRadius.circular(24);

    return Semantics(
      button: true,
      label: 'Estado actual: ${disponibilidad.etiqueta}. Toca para cambiarlo.',
      excludeSemantics: true,
      child: _Presionable(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Color.alphaBlend(color.withValues(alpha: 0.09), Colors.white),
            borderRadius: radio,
            border: Border.all(color: color.withValues(alpha: 0.35)),
            boxShadow: _sombraSuave,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: radio,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        child: Icon(_iconoEstado, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado actual',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            disponibilidad.etiqueta,
                            style: const TextStyle(
                              fontSize: 19,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            disponibilidad.descripcion,
                            style: const TextStyle(fontSize: 13, height: 1.3, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _iconoEstado => switch (disponibilidad) {
        EstadoDisponibilidad.disponible => Icons.check_rounded,
        EstadoDisponibilidad.ocupado => Icons.timelapse_rounded,
        EstadoDisponibilidad.fueraDeServicio => Icons.pause_rounded,
      };
}

/// Dos tarjetas lado a lado con la misma altura (la de la más alta). Con letra
/// grande o pantalla angosta pasan a una columna, para que los títulos no se encojan.
class _FilaTarjetas extends StatelessWidget {
  final Widget izquierda;
  final Widget derecha;

  const _FilaTarjetas({required this.izquierda, required this.derecha});

  @override
  Widget build(BuildContext context) {
    final escala = MediaQuery.textScalerOf(context).scale(16) / 16;
    if (escala > 1.15 || MediaQuery.sizeOf(context).width < 330) {
      return Column(children: [izquierda, const SizedBox(height: 12), derecha]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: izquierda),
          const SizedBox(width: 12),
          Expanded(child: derecha),
        ],
      ),
    );
  }
}

class _TarjetaAcceso extends StatelessWidget {
  final _ColoresTarjeta tono;
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final AsyncValue<int>? conteo;
  final CustomPainter ilustracion;
  final ({String etiqueta, IconData icono})? accion;
  final VoidCallback onTap;

  const _TarjetaAcceso({
    required this.tono,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.ilustracion,
    required this.onTap,
    this.conteo,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    const radio = BorderRadius.all(Radius.circular(24));
    final textoConteo = conteo?.when(
      data: (n) => '$n',
      loading: () => null,
      error: (_, __) => '—',
    );

    return Semantics(
      button: true,
      label: [titulo, if (textoConteo != null) textoConteo, subtitulo].join(', '),
      excludeSemantics: accion == null,
      child: _Presionable(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: radio,
            boxShadow: _sombraSuave,
          ),
          child: ClipRRect(
            borderRadius: radio,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: tono.color.withValues(alpha: 0.12)),
                          borderRadius: radio,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, tono.fondo.withValues(alpha: 0.7)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      // Con botón, la ilustración sube para que el botón no la tape.
                      bottom: accion == null ? 0 : 40,
                      height: accion == null ? 72 : 60,
                      child: RepaintBoundary(child: CustomPaint(painter: ilustracion)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: tono.fondo,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(icono, color: tono.color, size: 24),
                              ),
                              const Spacer(),
                              if (conteo != null)
                                _Insignia(texto: textoConteo, tono: tono),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Una sola línea que se reduce si no cabe: con letra grande
                              // nunca parte una palabra ("Notificacio-nes").
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    titulo,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.25,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded, color: tono.color, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitulo,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          // Deja ver la ilustración; con botón, el botón la tapa en parte.
                          SizedBox(height: accion == null ? 52 : 48),
                          if (accion case final accion?)
                            _BotonAccion(
                              etiqueta: accion.etiqueta,
                              icono: accion.icono,
                              tono: tono,
                              onTap: onTap,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Insignia extends StatelessWidget {
  /// null = cargando.
  final String? texto;
  final _ColoresTarjeta tono;

  const _Insignia({required this.texto, required this.tono});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 36),
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tono.fondo,
        borderRadius: BorderRadius.circular(18),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: texto == null
            ? SizedBox(
                key: const ValueKey('cargando'),
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: tono.texto),
              )
            : Text(
                texto!,
                key: ValueKey(texto),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: tono.texto,
                  // Dígitos del mismo ancho: el número no "salta" al cambiar.
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final _ColoresTarjeta tono;
  final VoidCallback onTap;

  const _BotonAccion({
    required this.etiqueta,
    required this.icono,
    required this.tono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(16);
    return Material(
      color: tono.color,
      borderRadius: radio,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: radio,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icono, size: 20, color: tono.texto),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      etiqueta,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: tono.texto,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 20, color: tono.texto),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Elevación con sombras (no bordes): una cercana y nítida, otra amplia y suave.
const _sombraSuave = [
  BoxShadow(color: Color(0x0D0F2A5C), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F0F2A5C), blurRadius: 16, offset: Offset(0, 6), spreadRadius: -4),
];
