import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';

/// AsignacionOut del backend + la solicitud que se atiende (para mostrarla en "Mis tareas").
class AsignacionModel {
  final String id;
  final String? solicitudId;
  final String? reporteId;
  final String estado; // activa | finalizada | cancelada
  final DateTime asignadoEn;
  final SolicitudAyudaModel? solicitud;

  const AsignacionModel({
    required this.id,
    this.solicitudId,
    this.reporteId,
    required this.estado,
    required this.asignadoEn,
    this.solicitud,
  });

  factory AsignacionModel.fromJson(Map<String, dynamic> json) =>
      AsignacionModel(
        id: json['id'] as String,
        solicitudId: json['solicitud_id'] as String?,
        reporteId: json['reporte_id'] as String?,
        estado: json['estado_asignacion'] as String,
        asignadoEn: DateTime.parse(json['asignado_en'] as String).toLocal(),
      );

  AsignacionModel conSolicitud(SolicitudAyudaModel? s) => AsignacionModel(
        id: id,
        solicitudId: solicitudId,
        reporteId: reporteId,
        estado: estado,
        asignadoEn: asignadoEn,
        solicitud: s,
      );
}
