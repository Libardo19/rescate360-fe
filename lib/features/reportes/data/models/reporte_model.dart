import 'dart:typed_data';

enum EstadoReporteCiudadano { pendiente, enRevision, atendido }

/// Reporte de un incidente hecho por un ciudadano.
class ReporteCiudadano {
  final String id;
  final String tipo;
  final String descripcion;
  final DateTime fecha;
  final String lugar;
  final bool esMio;
  final EstadoReporteCiudadano estado;
  final List<Uint8List> fotos;
  final int videos;

  const ReporteCiudadano({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    required this.lugar,
    required this.esMio,
    required this.estado,
    this.fotos = const [],
    this.videos = 0,
  });

  String get haceCuanto {
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inMinutes < 1) return 'Ahora mismo';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours} h';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 30) return 'Hace ${diferencia.inDays} días';
    final meses = diferencia.inDays ~/ 30;
    return meses == 1 ? 'Hace 1 mes' : 'Hace $meses meses';
  }
}
