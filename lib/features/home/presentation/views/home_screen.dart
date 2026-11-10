import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/curvas_de_nivel.dart';
import '../../../alertas/presentation/viewmodels/alertas_viewmodel.dart';
import '../../../mapa/presentation/viewmodels/mapa_viewmodel.dart';
import '../../../mapa/presentation/widgets/tipo_punto.dart';
import '../../../mapa/presentation/widgets/vista_previa_mapa.dart';

/// Inicio del ciudadano: saludo, accesos rápidos, la vista previa del mapa (los mismos datos de la
/// pestaña Mapa), las alertas de tu zona y un resumen con números reales.
class HomeScreen extends ConsumerWidget {
  final String nombreUsuario;

  /// Lleva a la pestaña Mapa (la vista previa y la búsqueda abren el mapa completo).
  final VoidCallback onAbrirMapa;

  const HomeScreen({super.key, this.nombreUsuario = 'Usuario', required this.onAbrirMapa});

  static const _fondo = Color(0xFFF5F7FC);

  void _ir(BuildContext context, String ruta) => Navigator.of(context).pushNamed(ruta);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertas = ref.watch(alertasProvider);
    final mapa = ref.watch(mapaViewModelProvider);
    final hayDatosDelMapa = mapa.posicion != null;
    final alertasEnZona = alertas.valueOrNull == null
        ? null
        : (alertas.valueOrNull!.enMiZona ?? alertas.valueOrNull!.todas).length;
    int contar(TipoPunto tipo) => mapa.puntos.values.where((p) => tipoDePunto(p) == tipo).length;

    return ColoredBox(
      color: _fondo,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(alertasProvider);
          await ref.read(mapaViewModelProvider.notifier).recargar();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _Encabezado(
              nombreUsuario: nombreUsuario,
              hayAlertas: (alertasEnZona ?? 0) > 0,
              onBuscar: onAbrirMapa,
              onNotificaciones: () => _ir(context, '/alertas'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AccesosRapidos(onIr: (ruta) => _ir(context, ruta)),
                  const SizedBox(height: 18),
                  _TituloSeccion(texto: 'Cerca de ti', accion: 'Ver mapa', onAccion: onAbrirMapa),
                  const SizedBox(height: 8),
                  VistaPreviaMapa(onAbrir: onAbrirMapa),
                  const SizedBox(height: 12),
                  _MantenteInformado(alertas: alertasEnZona, onTap: () => _ir(context, '/alertas')),
                  const SizedBox(height: 18),
                  const _TituloSeccion(texto: 'Resumen de tu zona'),
                  const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _Dato(
                            icono: Icons.warning_amber_rounded,
                            color: AppColors.danger,
                            valor: alertasEnZona,
                            etiqueta: 'Alertas activas',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Dato(
                            icono: Icons.assignment_turned_in_outlined,
                            color: AppColors.info,
                            valor: hayDatosDelMapa ? contar(TipoPunto.incidente) : null,
                            etiqueta: 'Incidentes cerca',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Dato(
                            icono: Icons.local_hospital_outlined,
                            color: AppColors.success,
                            valor: hayDatosDelMapa ? contar(TipoPunto.centro) : null,
                            etiqueta: 'Centros de ayuda',
                          ),
                        ),
                      ],
                    ),
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

class _Encabezado extends StatelessWidget {
  final String nombreUsuario;
  final bool hayAlertas;
  final VoidCallback onBuscar;
  final VoidCallback onNotificaciones;

  const _Encabezado({
    required this.nombreUsuario,
    required this.hayAlertas,
    required this.onBuscar,
    required this.onNotificaciones,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF14336F), AppColors.primary, AppColors.primaryDark],
            stops: [0, 0.5, 1],
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          child: Stack(
            children: [
              const Positioned.fill(
                child: RepaintBoundary(child: CustomPaint(painter: CurvasDeNivelPainter())),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Avatar(inicial: inicial),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hola, $nombreUsuario',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Tu seguridad también importa',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Color(0xFFC3D2F2), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          _Campana(hayAlertas: hayAlertas, onTap: onNotificaciones),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Reporta, consulta\ny mantente '),
                                  TextSpan(text: 'seguro', style: TextStyle(color: Color(0xFF8FB8FF))),
                                ],
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ExcludeSemantics(child: _EscudoOrbita()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Buscador(onTap: onBuscar),
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

class _Avatar extends StatelessWidget {
  final String inicial;

  const _Avatar({required this.inicial});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFF3E7BFA), width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              inicial,
              style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Campana extends StatelessWidget {
  final bool hayAlertas;
  final VoidCallback onTap;

  const _Campana({required this.hayAlertas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hayAlertas ? 'Alertas, hay alertas activas' : 'Alertas',
      excludeSemantics: true,
      child: Material(
        color: Colors.white.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 23),
                if (hayAlertas)
                  Positioned(
                    right: 9,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
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

/// Escudo con un anillo en órbita, la ilustración del encabezado.
class _EscudoOrbita extends StatelessWidget {
  const _EscudoOrbita();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Brillo azul detrás
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF3E7BFA).withValues(alpha: 0.45),
                const Color(0xFF3E7BFA).withValues(alpha: 0),
              ]),
            ),
          ),
          const CustomPaint(size: Size(84, 78), painter: _OrbitaPainter(delante: false)),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8FB8FF), Color(0xFF2F63E0), Color(0xFF173E9E)],
            ).createShader(rect),
            child: const Icon(Icons.shield_rounded, size: 62),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.verified_user_rounded, size: 27, color: Colors.white),
          ),
          const CustomPaint(size: Size(84, 78), painter: _OrbitaPainter(delante: true)),
        ],
      ),
    );
  }
}

/// Elipse inclinada alrededor del escudo; se pinta en dos mitades para que pase por detrás y por delante.
class _OrbitaPainter extends CustomPainter {
  final bool delante;

  const _OrbitaPainter({required this.delante});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + 8);
    canvas.rotate(-0.32);
    final elipse = Rect.fromCenter(center: Offset.zero, width: size.width * 0.98, height: size.height * 0.32);
    final trazo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8FB8FF).withValues(alpha: delante ? 0.9 : 0.35);
    // La mitad de abajo pasa por delante del escudo; la de arriba, por detrás
    canvas.drawArc(elipse, delante ? 0.15 : 3.29, 2.84, false, trazo);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OrbitaPainter old) => old.delante != delante;
}

class _Buscador extends StatelessWidget {
  final VoidCallback onTap;

  const _Buscador({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buscar incidentes, personas y lugares en el mapa',
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: const SizedBox(
            height: 46,
            child: Row(
              children: [
                SizedBox(width: 16),
                Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 21),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Buscar incidentes, personas, lugares...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
                SizedBox(
                  height: 28,
                  child: VerticalDivider(width: 24, thickness: 1, color: AppColors.surfaceBorder),
                ),
                Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccesosRapidos extends StatelessWidget {
  final ValueChanged<String> onIr;

  const _AccesosRapidos({required this.onIr});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Acceso(
            icono: Icons.campaign_rounded,
            etiqueta: 'Reportar\nincidente',
            color: AppColors.danger,
            fondo: const [Color(0xFFFFE9E7), Color(0xFFFFD3CF)],
            onTap: () => onIr('/reportar-incidente'),
          ),
        ),
        Expanded(
          child: _Acceso(
            icono: Icons.person_search_rounded,
            etiqueta: 'Personas\ndesaparecidas',
            color: const Color(0xFF2F63E0),
            fondo: const [Color(0xFFE8F0FF), Color(0xFFD3E2FF)],
            onTap: () => onIr('/personas-desaparecidas'),
          ),
        ),
        Expanded(
          child: _Acceso(
            icono: Icons.volunteer_activism_rounded,
            etiqueta: 'Solicitar\nayuda',
            color: const Color(0xFFE08A00),
            fondo: const [Color(0xFFFFF4DD), Color(0xFFFFE6B5)],
            onTap: () => onIr('/solicitar-ayuda'),
          ),
        ),
        Expanded(
          child: _Acceso(
            icono: Icons.notifications_active_rounded,
            etiqueta: 'Ver\nalertas',
            color: const Color(0xFF1C9A5E),
            fondo: const [Color(0xFFE2F7EC), Color(0xFFC9EEDB)],
            onTap: () => onIr('/alertas'),
          ),
        ),
      ],
    );
  }
}

class _Acceso extends StatefulWidget {
  final IconData icono;
  final String etiqueta;
  final Color color;
  final List<Color> fondo;
  final VoidCallback onTap;

  const _Acceso({
    required this.icono,
    required this.etiqueta,
    required this.color,
    required this.fondo,
    required this.onTap,
  });

  @override
  State<_Acceso> createState() => _AccesoState();
}

class _AccesoState extends State<_Acceso> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.etiqueta.replaceAll('\n', ' '),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _presionado = true),
        onTapCancel: () => setState(() => _presionado = false),
        onTapUp: (_) => setState(() => _presionado = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _presionado ? 0.94 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.fondo,
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.22),
                        blurRadius: 16,
                        spreadRadius: -4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(widget.icono, color: widget.color, size: 25),
                ),
                const SizedBox(height: 6),
                // Dos líneas fijas que se achican si no caben ("desaparecidas" es larga)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.etiqueta,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
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

class _TituloSeccion extends StatelessWidget {
  final String texto;
  final String? accion;
  final VoidCallback? onAccion;

  const _TituloSeccion({required this.texto, this.accion, this.onAccion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        if (accion != null)
          TextButton.icon(
            onPressed: onAccion,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: Text(accion!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2F63E0),
              minimumSize: const Size(44, 36),
              padding: const EdgeInsets.only(left: 10, right: 4),
            ),
          ),
      ],
    );
  }
}

class _MantenteInformado extends StatelessWidget {
  // null mientras carga o si no se pudo consultar
  final int? alertas;
  final VoidCallback onTap;

  const _MantenteInformado({required this.alertas, required this.onTap});

  String get _texto {
    final n = alertas;
    if (n == null) return 'Consulta las alertas de tu zona';
    if (n == 0) return 'No hay alertas activas en tu zona';
    return n == 1 ? 'Hay 1 alerta activa en tu zona' : 'Hay $n alertas activas en tu zona';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF6DCDA)),
            boxShadow: const [BoxShadow(color: Color(0x0F081C42), blurRadius: 18, offset: Offset(0, 6))],
          ),
          child: Stack(
            children: [
              // Ola coral suave en la esquina
              const Positioned.fill(child: CustomPaint(painter: _OlaPainter())),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.campaign_outlined, color: AppColors.danger, size: 23),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mantente informado',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(_texto, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OlaPainter extends CustomPainter {
  const _OlaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ola = Path()
      ..moveTo(size.width * 0.55, size.height)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.7, size.width, size.height * 0.62)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(ola, Paint()..color = AppColors.danger.withValues(alpha: 0.07));
  }

  @override
  bool shouldRepaint(_OlaPainter old) => false;
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final Color color;
  // null mientras carga
  final int? valor;
  final String etiqueta;

  const _Dato({required this.icono, required this.color, required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$etiqueta: ${valor ?? 'cargando'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: const [BoxShadow(color: Color(0x0A081C42), blurRadius: 14, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                valor?.toString() ?? '–',
                key: ValueKey(valor),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
