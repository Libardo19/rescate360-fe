import 'package:flutter/material.dart';

/// Un acceso rápido de la grilla de Home (mapa, solicitar ayuda, etc.).
class AccesoRapido {
  final String label;
  final IconData icon;
  final String ruta;

  const AccesoRapido({
    required this.label,
    required this.icon,
    required this.ruta,
  });
}

enum TipoAlerta { riesgo, informativa }

/// Un ítem de la lista "Alertas recientes".
class AlertaReciente {
  final String titulo;
  final String descripcion;
  final TipoAlerta tipo;

  const AlertaReciente({
    required this.titulo,
    required this.descripcion,
    required this.tipo,
  });
}

/// Alerta destacada en la parte superior de Home (ej. "Alerta sísmica").
/// Es nula la mayoría del tiempo: solo se muestra cuando hay una alerta
/// real en curso, nunca como elemento decorativo fijo.
class AlertaActiva {
  final String titulo;
  final String descripcion;

  const AlertaActiva({required this.titulo, required this.descripcion});
}
