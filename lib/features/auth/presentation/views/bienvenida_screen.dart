import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/curvas_de_nivel.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Pantalla de bienvenida. Si hay una sesión guardada en el dispositivo, entra directo.
class BienvenidaScreen extends ConsumerStatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  ConsumerState<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

/// Ilustración (logo, título y paisaje) recortada del diseño de la bienvenida.
const _ilustracion = AssetImage('assets/images/bienvenida.jpg');

/// Colores tomados de los bordes de la ilustración, para que el fondo continúe sin corte.
abstract final class _Color {
  static const fondoArriba = Color(0xFF02205A);
  static const fondoMedio = Color(0xFF00133C);
  static const fondoAbajo = Color(0xFF03245E);
  static const coral = Color(0xFFF2665B);
  static const coralOscuro = Color(0xFFDC4238);
  static const bordeContorno = Color(0xFF8EA8F0);
  static const textoSuave = Color(0xFFB4C3EE);
  static const textoTenue = Color(0xFF93A6DB);
}

class _BienvenidaScreenState extends ConsumerState<BienvenidaScreen> {
  bool _revisando = true;

  @override
  void initState() {
    super.initState();
    _restaurar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se decodifica de una vez para que la ilustración no aparezca a destiempo.
    precacheImage(_ilustracion, context);
  }

  Future<void> _restaurar() async {
    final ok = await ref.read(authViewModelProvider.notifier).restaurarSesion();
    if (!mounted) return;
    if (ok) {
      final rol = ref.read(authViewModelProvider).usuario!.rol;
      Navigator.of(context).pushNamedAndRemoveUntil(rutaInicio(rol), (_) => false);
    } else {
      setState(() => _revisando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _Color.fondoMedio,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_Color.fondoArriba, _Color.fondoMedio, _Color.fondoAbajo],
              stops: [0, 0.62, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Expanded(child: _Ilustracion()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: _revisando
                        ? const SizedBox(
                            key: ValueKey('revisando'),
                            height: 114,
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                        : Column(
                            key: const ValueKey('acciones'),
                            children: [
                              _BotonPrincipal(
                                etiqueta: 'Iniciar sesión',
                                icono: Icons.login_rounded,
                                onTap: () => Navigator.of(context).pushNamed('/login'),
                              ),
                              const SizedBox(height: 10),
                              _BotonContorno(
                                etiqueta: 'Crear cuenta',
                                icono: Icons.person_outline_rounded,
                                onTap: () => Navigator.of(context).pushNamed('/registro'),
                              ),
                            ],
                          ),
                  ),
                ),
                const Text(
                  'Juntos somos más fuertes',
                  style: TextStyle(fontSize: 14, color: _Color.textoSuave),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: _Color.textoTenue),
                    SizedBox(width: 6),
                    Text(
                      'Acceso seguro para voluntarios',
                      style: TextStyle(fontSize: 12, color: _Color.textoTenue),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La ilustración se muestra a su tamaño natural (nunca se amplía ni se recorta).
/// El espacio que sobra alrededor lo llenan curvas de nivel,
/// y la imagen se desvanece en sus bordes para que no se note dónde termina.
class _Ilustracion extends StatelessWidget {
  const _Ilustracion();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ClipRect(
          child: RepaintBoundary(child: CustomPaint(painter: CurvasDeNivelPainter(conMancha: false))),
        ),
        Align(
          // Un poco por debajo del centro: reparte el espacio libre sin dejar un hueco arriba.
          alignment: const Alignment(0, 0.3),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: [0, 0.14, 0.88, 1],
            ).createShader(rect),
            child: const Image(
              image: _ilustracion,
              fit: BoxFit.contain,
              semanticLabel: 'RESCATE 360. Tu comunidad, más segura. Actúa cuando más importa.',
            ),
          ),
        ),
      ],
    );
  }
}

class _BotonPrincipal extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final VoidCallback onTap;

  const _BotonPrincipal({required this.etiqueta, required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const radio = BorderRadius.all(Radius.circular(16));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radio,
        gradient: const LinearGradient(colors: [_Color.coral, _Color.coralOscuro]),
        boxShadow: [
          BoxShadow(
            color: _Color.coral.withValues(alpha: 0.28),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radio,
          child: _ContenidoBoton(etiqueta: etiqueta, icono: icono),
        ),
      ),
    );
  }
}

class _BotonContorno extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final VoidCallback onTap;

  const _BotonContorno({required this.etiqueta, required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const radio = BorderRadius.all(Radius.circular(16));
    return Material(
      color: Colors.white.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: radio,
        side: BorderSide(color: _Color.bordeContorno.withValues(alpha: 0.75), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radio,
        child: _ContenidoBoton(etiqueta: etiqueta, icono: icono),
      ),
    );
  }
}

class _ContenidoBoton extends StatelessWidget {
  final String etiqueta;
  final IconData icono;

  const _ContenidoBoton({required this.etiqueta, required this.icono});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                etiqueta,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
