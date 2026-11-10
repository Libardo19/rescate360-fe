import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';

// ------------------------------------------------------------ disponibilidad

extension DisponibilidadUi on EstadoDisponibilidad {
  String get etiqueta {
    switch (this) {
      case EstadoDisponibilidad.disponible:
        return 'Disponible';
      case EstadoDisponibilidad.ocupado:
        return 'Ocupado';
      case EstadoDisponibilidad.fueraDeServicio:
        return 'Fuera de servicio';
    }
  }

  String get descripcion {
    switch (this) {
      case EstadoDisponibilidad.disponible:
        return 'Puedes recibir y aceptar asignaciones';
      case EstadoDisponibilidad.ocupado:
        return 'En atención de un incidente';
      case EstadoDisponibilidad.fueraDeServicio:
        return 'Por descanso o razones personales';
    }
  }

  Color get color {
    switch (this) {
      case EstadoDisponibilidad.disponible:
        return AppColors.success;
      case EstadoDisponibilidad.ocupado:
        return AppColors.warning;
      case EstadoDisponibilidad.fueraDeServicio:
        return AppColors.textMuted;
    }
  }

  IconData get icono {
    switch (this) {
      case EstadoDisponibilidad.disponible:
        return Icons.check_circle;
      case EstadoDisponibilidad.ocupado:
        return Icons.timelapse;
      case EstadoDisponibilidad.fueraDeServicio:
        return Icons.do_not_disturb_on;
    }
  }
}

// ------------------------------------------------------- paso de atención

extension PasoAtencionUi on PasoAtencion {
  String get etiqueta {
    switch (this) {
      case PasoAtencion.enCamino:
        return 'En camino';
      case PasoAtencion.enSitio:
        return 'En sitio';
      case PasoAtencion.enAtencion:
        return 'En atención';
      case PasoAtencion.finalizado:
        return 'Finalizado';
    }
  }

  String get descripcion {
    switch (this) {
      case PasoAtencion.enCamino:
        return 'Vas hacia el lugar del incidente';
      case PasoAtencion.enSitio:
        return 'Ya llegaste al lugar';
      case PasoAtencion.enAtencion:
        return 'Estás atendiendo el incidente';
      case PasoAtencion.finalizado:
        return 'El incidente quedó atendido';
    }
  }

  Color get color {
    switch (this) {
      case PasoAtencion.enCamino:
        return AppColors.info;
      case PasoAtencion.enSitio:
        return AppColors.warning;
      case PasoAtencion.enAtencion:
        return AppColors.primary;
      case PasoAtencion.finalizado:
        return AppColors.success;
    }
  }

  IconData get icono {
    switch (this) {
      case PasoAtencion.enCamino:
        return Icons.directions_walk;
      case PasoAtencion.enSitio:
        return Icons.place;
      case PasoAtencion.enAtencion:
        return Icons.medical_services_outlined;
      case PasoAtencion.finalizado:
        return Icons.check_circle;
    }
  }
}

// ----------------------------------------------------------------- prioridad
// Rojo oscuro, para distinguir "Crítica" del coral de "Alta".
const Color _rojoCritico = Color(0xFF9B1C1C);

/// De la más urgente a la menos urgente (el orden sirve para ordenar listas).
enum NivelPrioridad { critica, alta, media, baja, sinClasificar }

/// Convierte el texto que manda el backend ('critica', 'alta', 'media',
/// 'baja' o 'pendiente') en un nivel.
NivelPrioridad nivelDePrioridad(String prioridad) {
  switch (prioridad) {
    case 'critica':
      return NivelPrioridad.critica;
    case 'alta':
      return NivelPrioridad.alta;
    case 'media':
      return NivelPrioridad.media;
    case 'baja':
      return NivelPrioridad.baja;
    default:
      return NivelPrioridad.sinClasificar;
  }
}

extension NivelPrioridadUi on NivelPrioridad {
  String get etiqueta {
    switch (this) {
      case NivelPrioridad.critica:
        return 'Crítica';
      case NivelPrioridad.alta:
        return 'Alta';
      case NivelPrioridad.media:
        return 'Media';
      case NivelPrioridad.baja:
        return 'Baja';
      case NivelPrioridad.sinClasificar:
        return 'Sin clasificar';
    }
  }

  /// "Prioridad crítica", "Prioridad alta"... o "Sin clasificar".
  String get textoCompleto => this == NivelPrioridad.sinClasificar
      ? 'Sin clasificar'
      : 'Prioridad ${etiqueta.toLowerCase()}';

  Color get color {
    switch (this) {
      case NivelPrioridad.critica:
        return _rojoCritico;
      case NivelPrioridad.alta:
        return AppColors.danger;
      case NivelPrioridad.media:
        return AppColors.warning;
      case NivelPrioridad.baja:
        return AppColors.success;
      case NivelPrioridad.sinClasificar:
        return AppColors.textMuted;
    }
  }
}

// ------------------------------------------------------------------- caso

/// "Hace 8 min", "Hace 2 h", "Ayer"...
String textoHace(DateTime fecha) {
  final diferencia = DateTime.now().difference(fecha);
  if (diferencia.inMinutes < 1) return 'Ahora mismo';
  if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
  if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours} h';
  if (diferencia.inDays == 1) return 'Ayer';
  if (diferencia.inDays < 30) return 'Hace ${diferencia.inDays} días';
  final meses = diferencia.inDays ~/ 30;
  return meses == 1 ? 'Hace 1 mes' : 'Hace $meses meses';
}

/// "A 850 m" o "A 1.2 km"; null si no se conoce la distancia.
String? textoDistancia(double? km) {
  if (km == null) return null;
  if (km < 1) return 'A ${(km * 1000).round()} m';
  return 'A ${km.toStringAsFixed(1)} km';
}

/// Ícono, color y textos de una solicitud de ayuda para las pantallas del
/// voluntario.
extension SolicitudVoluntarioUi on SolicitudAyudaModel {
  NivelPrioridad get nivel => nivelDePrioridad(prioridad);

  IconData get icono {
    if (esSos) return Icons.sos;
    switch (tipo) {
      case 'medica':
        return Icons.medical_services_outlined;
      case 'alimentaria':
        return Icons.restaurant_outlined;
      case 'refugio':
        return Icons.home_outlined;
      case 'rescate':
        return Icons.groups_outlined;
      case 'ropa':
        return Icons.checkroom_outlined;
      default:
        return Icons.more_horiz;
    }
  }

  Color get colorTipo {
    if (esSos) return AppColors.danger;
    switch (tipo) {
      case 'medica':
        return AppColors.danger;
      case 'alimentaria':
        return AppColors.warning;
      case 'refugio':
        return AppColors.info;
      case 'rescate':
        return AppColors.primary;
      case 'ropa':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String get haceCuanto => textoHace(creadoEn);

  String get ubicacionTexto =>
      direccion ?? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';

  /// Distancia en km desde [posicion], o null si no se conoce.
  double? distanciaKm(Position? posicion) {
    if (posicion == null) return null;
    return Geolocator.distanceBetween(
          posicion.latitude,
          posicion.longitude,
          lat,
          lng,
        ) /
        1000;
  }
}
