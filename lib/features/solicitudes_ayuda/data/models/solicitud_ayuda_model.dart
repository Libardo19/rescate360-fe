/// SolicitudAyudaOut del backend (lo que la app necesita mostrar).
class SolicitudAyudaModel {
  final String id;
  final String tipo; // medica, alimentaria, refugio, rescate, ropa, otro
  final String origen; // manual, sos, acelerometro
  final String descripcion;
  final String? direccion;
  final double lat;
  final double lng;
  final String estado; // pendiente, en_proceso, atendida, cancelada
  final String prioridad; // la manual del admin si existe; si no, la de la IA
  final DateTime creadoEn;

  const SolicitudAyudaModel({
    required this.id,
    required this.tipo,
    required this.origen,
    required this.descripcion,
    this.direccion,
    required this.lat,
    required this.lng,
    required this.estado,
    required this.prioridad,
    required this.creadoEn,
  });

  factory SolicitudAyudaModel.fromJson(Map<String, dynamic> json) {
    final ubicacion = json['ubicacion'] as Map<String, dynamic>;
    return SolicitudAyudaModel(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      origen: json['origen'] as String,
      descripcion: json['descripcion'] as String,
      direccion: json['direccion'] as String?,
      lat: (ubicacion['lat'] as num).toDouble(),
      lng: (ubicacion['lng'] as num).toDouble(),
      estado: json['estado'] as String,
      prioridad: (json['prioridad_manual'] ?? json['prioridad_ia']) as String,
      creadoEn: DateTime.parse(json['creado_en'] as String).toLocal(),
    );
  }

  bool get esSos => origen == 'sos';

  /// El dueño puede cancelarla mientras no esté atendida ni cancelada.
  bool get cancelable => estado == 'pendiente' || estado == 'en_proceso';

  static const etiquetasTipo = {
    'medica': 'Ayuda médica',
    'alimentaria': 'Alimentos',
    'refugio': 'Refugio',
    'rescate': 'Rescate',
    'ropa': 'Ropa',
    'otro': 'Otra ayuda',
  };

  static const etiquetasEstado = {
    'pendiente': 'Pendiente',
    'en_proceso': 'En proceso',
    'atendida': 'Atendida',
    'cancelada': 'Cancelada',
  };

  String get titulo => esSos ? 'SOS' : (etiquetasTipo[tipo] ?? 'Solicitud de ayuda');
  String get estadoEtiqueta => etiquetasEstado[estado] ?? estado;
}
