import 'package:flutter/material.dart';

/// Filtro de color que invierte la luminosidad conservando los tonos:
/// blanco -> negro, texto oscuro -> texto claro, azul marino -> azul claro
/// y coral -> coral más claro. En modo oscuro se aplica sobre toda la app.
const ColorFilter filtroModoOscuro = ColorFilter.matrix(<double>[
  0.574,
  -1.430,
  -0.144,
  0,
  255,
  -0.426,
  -0.430,
  -0.144,
  0,
  255,
  -0.426,
  -1.430,
  0.856,
  0,
  255,
  0,
  0,
  0,
  1,
  0,
]);

/// Informa a los widgets de abajo si el modo oscuro está activo.
class EstadoOscuro extends InheritedWidget {
  final bool oscuro;

  const EstadoOscuro({super.key, required this.oscuro, required super.child});

  static bool de(BuildContext context) {
    final estado = context.dependOnInheritedWidgetOfExactType<EstadoOscuro>();
    return estado?.oscuro ?? false;
  }

  @override
  bool updateShouldNotify(EstadoOscuro oldWidget) => oscuro != oldWidget.oscuro;
}

/// Envuelve fotos y videos para que no se vean en negativo en modo oscuro:
/// aplica el mismo filtro por segunda vez y los colores vuelven a su estado
/// original. Si el modo oscuro está apagado, no hace nada.
class SinFiltroOscuro extends StatelessWidget {
  final Widget child;

  const SinFiltroOscuro({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!EstadoOscuro.de(context)) return child;
    return ColorFiltered(colorFilter: filtroModoOscuro, child: child);
  }
}
