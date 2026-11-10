import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Curvas de nivel (mapa topográfico) en blanco tenue, para fondos azul marino:
/// el encabezado del voluntario y la bienvenida. Es estática, se pinta una vez.
class CurvasDeNivelPainter extends CustomPainter {
  /// Mancha clara abajo a la izquierda; solo para áreas cerradas como el encabezado.
  final bool conMancha;

  const CurvasDeNivelPainter({this.conMancha = true});

  @override
  void paint(Canvas canvas, Size size) {
    final trazo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.09);

    void contornos(Offset centro, double radioBase, int anillos, double fase) {
      for (var i = 0; i < anillos; i++) {
        final radio = radioBase + i * 16.0;
        final camino = Path();
        for (var g = 0; g <= 72; g++) {
          final t = g / 72 * 2 * math.pi;
          final ondulacion = 1 +
              0.10 * math.sin(3 * t + fase + i * 0.35) +
              0.05 * math.sin(5 * t - fase);
          final p = centro +
              Offset(math.cos(t) * radio * 1.25 * ondulacion,
                  math.sin(t) * radio * 0.85 * ondulacion);
          g == 0 ? camino.moveTo(p.dx, p.dy) : camino.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(camino..close(), trazo);
      }
    }

    contornos(Offset(size.width * 0.86, size.height * 0.62), 18, 9, 0.4);
    contornos(Offset(size.width * 0.52, -size.height * 0.05), 30, 5, 2.1);

    // Mancha clara abajo a la izquierda: da profundidad sin degradados ruidosos.
    if (conMancha) {
      canvas.drawCircle(
        Offset(-size.width * 0.05, size.height * 1.05),
        size.height * 0.55,
        Paint()..color = Colors.white.withValues(alpha: 0.04),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
