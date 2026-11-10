import 'package:flutter/material.dart';

/// Ilustraciones del inicio del voluntario, dibujadas con [CustomPainter]:
/// no pesan como imágenes, se ven nítidas en cualquier densidad y, como son
/// estáticas, se pintan una sola vez (todas devuelven `false` en shouldRepaint).

/// Pin de mapa (gota con círculo blanco), centrado en la punta inferior.
void dibujarPin(Canvas canvas, Offset punta, double alto, Color color) {
  final r = alto * 0.36;
  final centro = Offset(punta.dx, punta.dy - alto + r);
  final pin = Path()
    ..moveTo(punta.dx, punta.dy)
    ..cubicTo(punta.dx - r * 0.35, punta.dy - alto * 0.32, centro.dx - r,
        centro.dy + r * 0.55, centro.dx - r, centro.dy)
    ..arcToPoint(Offset(centro.dx + r, centro.dy),
        radius: Radius.circular(r), clockwise: true)
    ..cubicTo(centro.dx + r, centro.dy + r * 0.55, punta.dx + r * 0.35,
        punta.dy - alto * 0.32, punta.dx, punta.dy)
    ..close();
  canvas.drawPath(pin, Paint()..color = color);
  canvas.drawCircle(centro, r * 0.42, Paint()..color = Colors.white);
}

/// Colinas con un pin y su onda: "incidentes en tu zona".
class ZonaIncidentesPainter extends CustomPainter {
  final Color color;

  const ZonaIncidentesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final colinaAtras = Path()
      ..moveTo(0, h * 0.45)
      ..quadraticBezierTo(w * 0.22, h * 0.22, w * 0.45, h * 0.42)
      ..quadraticBezierTo(w * 0.7, h * 0.62, w, h * 0.3)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(colinaAtras, Paint()..color = color.withValues(alpha: 0.07));

    final colinaFrente = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.35, h * 0.5, w * 0.62, h * 0.7)
      ..quadraticBezierTo(w * 0.84, h * 0.86, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(colinaFrente, Paint()..color = color.withValues(alpha: 0.08));

    final camino = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.28, h)
        ..quadraticBezierTo(w * 0.4, h * 0.78, w * 0.58, h * 0.74)
        ..quadraticBezierTo(w * 0.78, h * 0.7, w * 0.92, h),
      camino,
    );

    final base = Offset(w * 0.56, h * 0.66);
    for (final (escala, alfa) in [(1.0, 0.10), (0.62, 0.16)]) {
      canvas.drawOval(
        Rect.fromCenter(center: base, width: 54 * escala, height: 20 * escala),
        Paint()..color = color.withValues(alpha: alfa),
      );
    }
    dibujarPin(canvas, base, 32, color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hoja con renglones inclinada: "tareas asignadas" y "notificaciones".
class HojaConRenglonesPainter extends CustomPainter {
  final Color color;
  final bool conPuntos;

  const HojaConRenglonesPainter(this.color, {this.conPuntos = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.save();
    canvas.translate(w * 0.5, h * 0.18);
    canvas.rotate(conPuntos ? -0.05 : 0.07);

    final hoja = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w * 0.62, h * 1.1),
      const Radius.circular(14),
    );
    canvas.drawRRect(hoja, Paint()..color = color.withValues(alpha: 0.09));

    final renglon = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: conPuntos ? 0.22 : 0.28);
    for (var i = 0; i < 3; i++) {
      final y = 16.0 + i * 18;
      final inicio = conPuntos ? 34.0 : 18.0;
      if (conPuntos) {
        canvas.drawCircle(Offset(18, y), 5, Paint()..color = color.withValues(alpha: 0.75));
      } else {
        canvas.drawLine(Offset(inicio, y), Offset(inicio + 16, y), renglon);
      }
      final finRenglon = w * 0.62 - 16 - (i == 2 ? 26 : 0);
      canvas.drawLine(Offset(inicio + (conPuntos ? 0 : 30), y), Offset(finRenglon, y), renglon);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Plano de calles en perspectiva con un pin: "explora tu área".
class PlanoCallesPainter extends CustomPainter {
  final Color color;

  const PlanoCallesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final manzana = Paint()..color = color.withValues(alpha: 0.08);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.05, h * 0.55)
        ..lineTo(w * 0.32, h * 0.32)
        ..lineTo(w * 0.52, h * 0.5)
        ..lineTo(w * 0.24, h * 0.78)
        ..close(),
      manzana,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.62, h * 0.2)
        ..lineTo(w * 0.9, h * 0.0)
        ..lineTo(w, h * 0.1)
        ..lineTo(w, h * 0.4)
        ..lineTo(w * 0.78, h * 0.38)
        ..close(),
      manzana,
    );

    final calle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawLine(Offset(0, h * 0.82), Offset(w, h * 0.08), calle);
    canvas.drawLine(Offset(w * 0.18, 0), Offset(w * 0.82, h), calle);
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w, h * 0.5), calle..strokeWidth = 3);

    final base = Offset(w * 0.68, h * 0.7);
    canvas.drawOval(
      Rect.fromCenter(center: base, width: 34, height: 12),
      Paint()..color = color.withValues(alpha: 0.18),
    );
    dibujarPin(canvas, base, 32, color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
