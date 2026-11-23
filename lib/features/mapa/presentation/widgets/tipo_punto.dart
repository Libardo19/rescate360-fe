import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/marcador_mapa_model.dart';

/// Cómo se ve cada punto del mapa. Lo comparten el mapa y su vista previa del inicio.
enum TipoPunto { incidente, solicitud, alerta, centro, sismo }

extension TipoPuntoVisual on TipoPunto {
  String get etiqueta {
    switch (this) {
      case TipoPunto.incidente:
        return 'Incidente';
      case TipoPunto.solicitud:
        return 'Solicitud de ayuda';
      case TipoPunto.alerta:
        return 'Alerta';
      case TipoPunto.centro:
        return 'Centro de ayuda';
      case TipoPunto.sismo:
        return 'Sismo';
    }
  }

  Color get color {
    switch (this) {
      case TipoPunto.incidente:
        return AppColors.danger;
      case TipoPunto.solicitud:
        return AppColors.primary;
      case TipoPunto.alerta:
        return AppColors.warning;
      case TipoPunto.centro:
        return AppColors.info;
      case TipoPunto.sismo:
        return const Color(0xFFEA580C);
    }
  }

  IconData get icono {
    switch (this) {
      case TipoPunto.incidente:
        return Icons.report_gmailerrorred_outlined;
      case TipoPunto.solicitud:
        return Icons.support_agent;
      case TipoPunto.alerta:
        return Icons.warning_amber_rounded;
      case TipoPunto.centro:
        return Icons.local_hospital_outlined;
      case TipoPunto.sismo:
        return Icons.vibration;
    }
  }
}

/// Capa del backend → tipo visual. Las zonas peligrosas se pintan como alertas.
TipoPunto tipoDePunto(MarcadorMapaModel p) => switch (p.capa) {
      'reporte' => TipoPunto.incidente,
      'solicitud' => TipoPunto.solicitud,
      'centro' => TipoPunto.centro,
      'sismo' => TipoPunto.sismo,
      _ => TipoPunto.alerta,
    };
