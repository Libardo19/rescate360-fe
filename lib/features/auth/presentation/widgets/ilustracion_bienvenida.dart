import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../shared/widgets/curvas_de_nivel.dart';

/// Ilustración de la bienvenida con el logo animado al abrir la app.
///
/// El logo es parte de la imagen: se tapa su lugar y se vuelve a dibujar recortado de la misma
/// imagen en una capa propia, para poder girarlo y hacerlo brillar sin otro archivo.
///
/// Entrada (~1,9 s): aparece la escena, el logo llega girando como una moneda, al asentarse
/// suelta un destello y una onda, y un barrido de luz lo recorre. Después queda vivo: el brillo
/// respira, un arco orbita alrededor (el "360") y salen ondas de radar suaves.
/// Con "reducir movimiento" se muestra quieto desde el principio.
class IlustracionBienvenida extends StatefulWidget {
  final ImageProvider imagen;

  const IlustracionBienvenida({super.key, required this.imagen});

  /// Momento en que el logo se asienta: la pantalla muestra los botones después de esto.
  static const llegadaDelLogo = Duration(milliseconds: 1300);

  @override
  State<IlustracionBienvenida> createState() => _IlustracionBienvenidaState();
}

// Medidas de assets/images/bienvenida.jpg (en píxeles de la imagen)
const _tamanoImagen = Size(1125, 1195);
const _centroLogo = Offset(561.5, 318);
const _radioLogo = 197.0;
const _alineacion = Alignment(0, 0.3);

const _coral = Color(0xFFF2665B);
// El azul del disco del logo: tapa el logo de la imagen mientras el animado está girando
const _fondoDisco = Color(0xFF07173D);

class _IlustracionBienvenidaState extends State<IlustracionBienvenida> with TickerProviderStateMixin {
  late final _entrada = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
  // Un ciclo de 6,4 s: dos vueltas del arco, dos respiros del brillo y un barrido de luz
  late final _ciclo = AnimationController(vsync: this, duration: const Duration(milliseconds: 6400));
  bool _iniciada = false;
  bool _quieto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quieto = MediaQuery.disableAnimationsOf(context);
    if (_quieto) {
      _entrada.value = 1;
      _ciclo.stop();
    } else if (!_iniciada) {
      _iniciada = true;
      _entrada.forward();
      _ciclo.repeat();
    } else if (!_ciclo.isAnimating) {
      _ciclo.repeat();
    }
  }

  @override
  void dispose() {
    _entrada.dispose();
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ClipRect(
          child: RepaintBoundary(child: CustomPaint(painter: CurvasDeNivelPainter(conMancha: false))),
        ),
        LayoutBuilder(builder: (context, limites) {
          // Mismo cálculo que BoxFit.contain + _alineacion, para saber dónde queda el logo en pantalla
          final caja = Offset.zero & limites.biggest;
          final ajustado = applyBoxFit(BoxFit.contain, _tamanoImagen, limites.biggest).destination;
          final zona = _alineacion.inscribe(ajustado, caja);
          final escala = zona.width / _tamanoImagen.width;
          final centro = zona.topLeft + _centroLogo * escala;
          final radio = _radioLogo * escala;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fromRect(
                rect: zona,
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: _entrada, curve: const Interval(0, 0.35, curve: Curves.easeOut)),
                  child: _Escena(imagen: widget.imagen, centro: _centroLogo * escala, radio: radio),
                ),
              ),
              // Brillo, ondas y órbita: alrededor del logo, detrás de él
              Positioned.fromRect(
                rect: Rect.fromCircle(center: centro, radius: radio * 2),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _HaloPainter(entrada: _entrada, ciclo: _ciclo, radio: radio, quieto: _quieto),
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: Rect.fromCircle(center: centro, radius: radio + 1),
                child: _LogoAnimado(
                  imagen: widget.imagen,
                  entrada: _entrada,
                  ciclo: _ciclo,
                  // Dónde queda la imagen completa respecto al cuadro del logo
                  imagenEnLogo: Rect.fromLTWH(
                    -(centro.dx - radio - 1 - zona.left),
                    -(centro.dy - radio - 1 - zona.top),
                    zona.width,
                    zona.height,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

/// La imagen sin el logo: se desvanece arriba y abajo, y un disco tapa el logo original.
class _Escena extends StatelessWidget {
  final ImageProvider imagen;
  final Offset centro;
  final double radio;

  const _Escena({required this.imagen, required this.centro, required this.radio});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
            stops: [0, 0.14, 0.88, 1],
          ).createShader(rect),
          child: Image(
            image: imagen,
            fit: BoxFit.fill,
            semanticLabel: 'RESCATE 360. Tu comunidad, más segura. Actúa cuando más importa.',
          ),
        ),
        CustomPaint(painter: _TapaLogoPainter(centro: centro, radio: radio)),
      ],
    );
  }
}

class _TapaLogoPainter extends CustomPainter {
  final Offset centro;
  final double radio;

  const _TapaLogoPainter({required this.centro, required this.radio});

  @override
  void paint(Canvas canvas, Size size) {
    // Mientras el logo gira se ve este disco: con relieve y un aro tenue, como un medallón vacío
    canvas.drawCircle(
      centro,
      radio - 0.5,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.35),
          colors: [const Color(0xFF13306F), _fondoDisco],
        ).createShader(Rect.fromCircle(center: centro, radius: radio)),
    );
    canvas.drawCircle(
      centro,
      radio * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radio * 0.035
        ..color = Colors.white.withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(_TapaLogoPainter old) => old.centro != centro || old.radio != radio;
}

/// El logo recortado de la imagen: llega girando como una moneda y lo cruza un barrido de luz.
class _LogoAnimado extends StatelessWidget {
  final ImageProvider imagen;
  final AnimationController entrada;
  final AnimationController ciclo;
  final Rect imagenEnLogo;

  const _LogoAnimado({
    required this.imagen,
    required this.entrada,
    required this.ciclo,
    required this.imagenEnLogo,
  });

  static const _giro = Interval(0.12, 0.7, curve: Curves.easeOutCubic);
  static const _crecer = Interval(0.12, 0.7, curve: Curves.easeOutBack);
  static const _aparecer = Interval(0.12, 0.3, curve: Curves.easeOut);
  static const _barridoEntrada = Interval(0.7, 0.95, curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    final logo = ClipOval(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fromRect(rect: imagenEnLogo, child: Image(image: imagen, fit: BoxFit.fill)),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([entrada, ciclo]),
      child: logo,
      builder: (context, logo) {
        final t = entrada.value;
        // Vuelta y cuarto que frena al llegar; en perspectiva se ve como una moneda
        final angulo = (1 - _giro.transform(t)) * math.pi * 2.5;
        final escala = 0.45 + 0.55 * _crecer.transform(t);
        // Barrido de luz: uno al llegar y luego uno por ciclo
        final enEntrada = t < 1 ? _barridoEntrada.transform(t) : null;
        final enCiclo = ciclo.value < 0.16 ? ciclo.value / 0.16 : null;
        final barrido = enEntrada ?? enCiclo;

        return Opacity(
          opacity: _aparecer.transform(t),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0014)
              ..rotateY(angulo)
              ..scaleByDouble(escala, escala, 1, 1),
            child: barrido == null || barrido <= 0 || barrido >= 1
                ? logo
                : ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (rect) => _barridoDeLuz(rect, barrido),
                    child: logo,
                  ),
          ),
        );
      },
    );
  }

  /// Una franja de luz en diagonal que cruza el logo de izquierda a derecha.
  static Shader _barridoDeLuz(Rect rect, double avance) {
    final x = -0.6 + 2.2 * avance;
    return LinearGradient(
      begin: Alignment(x * 2 - 1.6, -1),
      end: Alignment(x * 2 - 0.6, 1),
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.42),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0.35, 0.5, 0.65],
    ).createShader(rect);
  }
}

/// Lo que rodea al logo: el brillo coral que respira, el destello y la onda al llegar,
/// las ondas de radar y el arco que orbita.
class _HaloPainter extends CustomPainter {
  final AnimationController entrada;
  final AnimationController ciclo;
  final double radio;
  final bool quieto;

  _HaloPainter({required this.entrada, required this.ciclo, required this.radio, required this.quieto})
      : super(repaint: Listenable.merge([entrada, ciclo]));

  static double _tramo(double t, double desde, double hasta) => ((t - desde) / (hasta - desde)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final t = entrada.value;
    final presente = Curves.easeOut.transform(_tramo(t, 0.55, 0.85));
    final golpe = _tramo(t, 0.62, 1);
    final destello = golpe > 0 && golpe < 1 ? math.sin(math.pi * golpe) : 0.0;
    final fase = ciclo.value;
    final respiro = quieto ? 0.5 : 0.5 + 0.5 * math.sin(fase * 4 * math.pi);

    // Brillo coral detrás del logo
    final intensidad = presente * (0.26 + 0.14 * respiro) + 0.5 * destello;
    if (intensidad > 0) {
      canvas.drawCircle(
        c,
        radio * 1.95,
        Paint()
          ..shader = RadialGradient(
            colors: [
              _coral.withValues(alpha: intensidad),
              _coral.withValues(alpha: intensidad * 0.4),
              _coral.withValues(alpha: 0),
            ],
            stops: const [0.48, 0.66, 1],
          ).createShader(Rect.fromCircle(center: c, radius: radio * 1.95)),
      );
    }

    // Onda blanca que sale cuando el logo se asienta
    if (golpe > 0 && golpe < 1) {
      final r = radio * (1.02 + 0.75 * Curves.easeOutCubic.transform(golpe));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radio * 0.025
          ..color = Colors.white.withValues(alpha: 0.55 * (1 - golpe)),
      );
    }

    if (quieto || presente == 0) return;

    // Ondas de radar, dos por ciclo y desfasadas
    for (final desfase in const [0.0, 0.5]) {
      final onda = (fase * 2 + desfase) % 1;
      canvas.drawCircle(
        c,
        radio * (1.04 + 0.6 * onda),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radio * 0.012
          ..color = _coral.withValues(alpha: presente * 0.45 * math.pow(1 - onda, 2)),
      );
    }

    // Arco que orbita: una cola que se desvanece y una cabeza brillante
    final orbita = radio * 1.09;
    final cabeza = fase * 4 * math.pi - math.pi / 2;
    const cola = math.pi * 0.62;
    const tramos = 28;
    for (var i = 0; i < tramos; i++) {
      final desde = cabeza - cola + cola * i / tramos;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: orbita),
        desde,
        cola / tramos + 0.01,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = radio * 0.04
          ..color = _coral.withValues(alpha: presente * math.pow(i / tramos, 1.4)),
      );
    }
    final punta = c + Offset(math.cos(cabeza), math.sin(cabeza)) * orbita;
    canvas.drawCircle(
      punta,
      radio * 0.1,
      Paint()
        ..color = _coral.withValues(alpha: presente * 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radio * 0.07),
    );
    canvas.drawCircle(punta, radio * 0.035, Paint()..color = Colors.white.withValues(alpha: presente));
  }

  @override
  bool shouldRepaint(_HaloPainter old) => old.radio != radio || old.quieto != quieto;
}
