import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router.dart';
import '../../../check_in/presentation/viewmodels/check_in_viewmodel.dart';

/// Alerta SOS de un sismo muy fuerte, a pantalla completa, con la pregunta "¿Estás bien?".
///
/// Llega por push urgente (`urgente=1`) solo a quien estaba dentro del radio de afectación según
/// su ubicación reciente; los que están lejos reciben solo un aviso informativo.
///
/// - "No, necesito ayuda": responde el "¿Estás bien?" del sismo como necesito_ayuda (el backend crea
///   el SOS con la ubicación y avisa a los contactos) o, si no hay uno pendiente, abre la pantalla SOS.
/// - "Sí, estoy bien": responde a_salvo.
/// - La cuenta regresiva muestra cuánto falta para que se avise a los contactos de emergencia.
class AlertaSismoScreen extends ConsumerStatefulWidget {
  final String titulo;
  final String mensaje;

  const AlertaSismoScreen({super.key, required this.titulo, required this.mensaje});

  /// Mientras está abierta, el vigilante del "¿Estás bien?" no abre su propia pantalla encima.
  static bool abierta = false;

  @override
  ConsumerState<AlertaSismoScreen> createState() => _AlertaSismoScreenState();
}

class _AlertaSismoScreenState extends ConsumerState<AlertaSismoScreen> with TickerProviderStateMixin {
  // Ondas sísmicas del fondo (se repiten), temblor del ícono al entrar, entrada escalonada y latido del SOS
  late final AnimationController _ondas;
  late final AnimationController _temblor;
  late final AnimationController _entrada;
  late final AnimationController _latido;
  Timer? _reloj;
  bool _enviando = false;

  static const _fondo = Color(0xFF450A0A);
  static const _rojo = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    AlertaSismoScreen.abierta = true;
    _ondas = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
    _temblor = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _entrada = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
    _latido = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    HapticFeedback.heavyImpact();
    // Trae el "¿Estás bien?" que el backend abrió para este sismo (da la cuenta regresiva)
    Future.microtask(() => ref.read(checkInProvider.notifier).consultar());
  }

  @override
  void dispose() {
    AlertaSismoScreen.abierta = false;
    _reloj?.cancel();
    _ondas.dispose();
    _temblor.dispose();
    _entrada.dispose();
    _latido.dispose();
    super.dispose();
  }

  Future<void> _responder({required bool aSalvo}) async {
    final navegador = Navigator.of(context);
    final mensajero = ScaffoldMessenger.of(context);
    HapticFeedback.mediumImpact();
    setState(() => _enviando = true);
    await ref.read(checkInProvider.notifier).consultar();
    final pendiente = ref.read(checkInProvider);
    if (pendiente == null) {
      // Sin "¿Estás bien?" abierto: el SOS se pide desde su pantalla (mantener 3 s)
      navegador.pop();
      if (!aSalvo) navegador.pushNamed(AppRouter.sos);
      return;
    }
    final error = await ref.read(checkInProvider.notifier).responder(aSalvo: aSalvo);
    if (!mounted) return;
    if (error != null) {
      setState(() => _enviando = false);
      mensajero.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    navegador.pop();
    mensajero.showSnackBar(SnackBar(
      content: Text(aSalvo
          ? 'Gracias. Quedó registrado que estás a salvo.'
          : 'SOS enviado con tu ubicación. Avisamos a los organismos de rescate y a tus contactos.'),
    ));
  }

  /// Aparece de abajo hacia arriba entre [desde] y [hasta] (fracciones de la entrada).
  Widget _aparece(double desde, double hasta, Widget hijo) {
    final curva = CurvedAnimation(parent: _entrada, curve: Interval(desde, hasta, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: curva,
      builder: (_, child) => Opacity(
        opacity: curva.value,
        child: Transform.translate(offset: Offset(0, (1 - curva.value) * 28), child: child),
      ),
      child: hijo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final check = ref.watch(checkInProvider);
    final pendiente = check != null && check.pendiente;
    final restante = pendiente ? check.venceEn.difference(DateTime.now()) : Duration.zero;
    final segundos = restante.isNegative ? 0 : restante.inSeconds;
    final inicio = pendiente ? (check.creadoEn ?? check.venceEn.subtract(const Duration(minutes: 10))) : null;
    final total = inicio == null ? 1 : check!.venceEn.difference(inicio).inSeconds.clamp(1, 1 << 30);
    final fraccion = pendiente ? segundos / total : 0.0;
    final reloj = '${(segundos ~/ 60).toString().padLeft(2, '0')}:${(segundos % 60).toString().padLeft(2, '0')}';

    return PopScope(
      canPop: !_enviando,
      child: Scaffold(
        backgroundColor: _fondo,
        body: Stack(
          children: [
            // Ondas sísmicas que salen del centro
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ondas,
                builder: (_, __) => CustomPaint(painter: _OndasSismicas(_ondas.value)),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _aparece(
                          0,
                          0.3,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FadeTransition(
                                  opacity: _latido,
                                  child: const Icon(Icons.circle, color: Color(0xFFF87171), size: 10),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'ALERTA SOS · SISMO',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white60),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Anillo con la cuenta regresiva y el ícono que tiembla
                    Center(
                      child: SizedBox(
                        width: 190,
                        height: 190,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: fraccion),
                                duration: const Duration(milliseconds: 900),
                                builder: (_, valor, __) => CircularProgressIndicator(
                                  value: pendiente ? valor : null,
                                  strokeWidth: 7,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                                  color: segundos <= 60 && pendiente ? const Color(0xFFFBBF24) : Colors.white,
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: Listenable.merge([_temblor, _latido]),
                              builder: (_, child) {
                                // Temblor fuerte que se apaga + latido suave constante
                                final t = _temblor.value;
                                final dx = math.sin(t * math.pi * 14) * 12 * (1 - t);
                                final giro = math.sin(t * math.pi * 10) * 0.12 * (1 - t);
                                final escala = 1 + _latido.value * 0.06;
                                return Transform.translate(
                                  offset: Offset(dx, 0),
                                  child: Transform.rotate(angle: giro, child: Transform.scale(scale: escala, child: child)),
                                );
                              },
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  color: _rojo,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: const [BoxShadow(color: Color(0x99F87171), blurRadius: 46, spreadRadius: 10)],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.vibration, color: Colors.white, size: 40),
                                    if (pendiente) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        reloj,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          fontFeatures: [FontFeature.tabularFigures()],
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
                    ),
                    const SizedBox(height: 26),
                    _aparece(
                      0.15,
                      0.45,
                      Text(
                        widget.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFFECACA), fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _aparece(
                      0.25,
                      0.55,
                      const Text(
                        '¿Estás bien?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, height: 1.05),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _aparece(
                      0.35,
                      0.65,
                      Text(
                        pendiente
                            ? 'Estás dentro de la zona afectada. Si no respondes en $reloj, enviaremos tu SOS automáticamente con tu ubicación y avisaremos a tus contactos.'
                            : 'Estás dentro de la zona afectada. ${widget.mensaje}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 14.5, height: 1.4),
                      ),
                    ),
                    const Spacer(),
                    _aparece(
                      0.5,
                      0.85,
                      ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.035).animate(CurvedAnimation(parent: _latido, curve: Curves.easeInOut)),
                        child: SizedBox(
                          height: 66,
                          child: ElevatedButton.icon(
                            onPressed: _enviando ? null : () => _responder(aSalvo: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _rojo,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: const Color(0xAAF87171),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                            icon: const Icon(Icons.sos, size: 32),
                            label: const Text('No, necesito ayuda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _aparece(
                      0.6,
                      0.95,
                      SizedBox(
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: _enviando ? null : () => _responder(aSalvo: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF166534),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          icon: _enviando
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.check_circle, size: 26),
                          label: const Text('Sí, estoy bien', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _aparece(
                      0.75,
                      1,
                      const Text(
                        'Información de fuentes sismológicas públicas (USGS/SGC); no es una alerta temprana oficial.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ),
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

/// Anillos que se expanden desde el centro de la pantalla, como las ondas de un sismo.
class _OndasSismicas extends CustomPainter {
  final double t; // 0..1, se repite

  _OndasSismicas(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height * 0.4);
    final maximo = size.longestSide * 0.75;
    for (var i = 0; i < 4; i++) {
      final fase = (t + i / 4) % 1;
      final pintura = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (1 - fase) * 4
        ..color = const Color(0xFFF87171).withValues(alpha: (1 - fase) * 0.35);
      canvas.drawCircle(centro, 60 + fase * maximo, pintura);
    }
    // Resplandor central
    canvas.drawCircle(
      centro,
      maximo * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFDC2626).withValues(alpha: 0.35), Colors.transparent],
        ).createShader(Rect.fromCircle(center: centro, radius: maximo * 0.45)),
    );
  }

  @override
  bool shouldRepaint(_OndasSismicas viejo) => viejo.t != t;
}
