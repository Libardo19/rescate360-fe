/// CheckInOut del backend: el "¿Estás bien?" con vencimiento.
class CheckInModel {
  final String id;
  // sismo (lo abrió un sismo cerca) o manual (modo emergencia)
  final String motivo;
  // pendiente | a_salvo | necesito_ayuda | sin_respuesta
  final String estado;
  final String? eventoSismicoId;
  final DateTime venceEn;
  final String? solicitudId;

  const CheckInModel({
    required this.id,
    required this.motivo,
    required this.estado,
    required this.venceEn,
    this.eventoSismicoId,
    this.solicitudId,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) => CheckInModel(
        id: json['id'] as String,
        motivo: json['motivo'] as String,
        estado: json['estado'] as String,
        eventoSismicoId: json['evento_sismico_id'] as String?,
        venceEn: DateTime.parse(json['vence_en'] as String).toLocal(),
        solicitudId: json['solicitud_id'] as String?,
      );

  bool get pendiente => estado == 'pendiente';
}
