import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/persona_desaparecida.dart';

/// Texto y color de cada estado, para usarlos en la lista y en el detalle.
extension EstadoPersonaUi on EstadoPersona {
  String get etiqueta {
    switch (this) {
      case EstadoPersona.buscando:
        return 'En búsqueda';
      case EstadoPersona.encontrada:
        return 'Encontrada';
    }
  }

  Color get color {
    switch (this) {
      case EstadoPersona.buscando:
        return AppColors.danger;
      case EstadoPersona.encontrada:
        return AppColors.success;
    }
  }
}
