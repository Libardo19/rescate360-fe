import 'package:flutter/widgets.dart';

enum Pantalla { movil, tablet, escritorio }

/// Puntos de quiebre compartidos por la landing y el panel web.
class Responsive {
  Responsive._();

  static const double movilMax = 600;
  static const double tabletMax = 900;

  static Pantalla de(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    if (ancho < movilMax) return Pantalla.movil;
    if (ancho < tabletMax) return Pantalla.tablet;
    return Pantalla.escritorio;
  }

  static bool esMovil(BuildContext c) => de(c) == Pantalla.movil;
  static bool esEscritorio(BuildContext c) => de(c) == Pantalla.escritorio;

  /// Elige un valor según el tamaño. Si no das [tablet], usa el de escritorio.
  static T valor<T>(
    BuildContext context, {
    required T movil,
    T? tablet,
    required T escritorio,
  }) {
    switch (de(context)) {
      case Pantalla.movil:
        return movil;
      case Pantalla.tablet:
        return tablet ?? escritorio;
      case Pantalla.escritorio:
        return escritorio;
    }
  }
}
