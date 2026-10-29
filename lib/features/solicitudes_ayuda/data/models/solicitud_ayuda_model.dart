/// SolicitudAyudaOut del backend (lo que la app necesita mostrar).
/// El voluntario también recibe aquí los reportes de incidentes de su organización
/// ([esReporte]): se muestran y se toman igual que una solicitud.
class SolicitudAyudaModel {
  final String id;
  // solicitud | reporte
  final String clase;
  // Etiqueta del tipo de reporte ("Incendio", "Fuga de gas"); null en solicitudes
  final String? tipoEtiqueta;
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
    this.clase = 'solicitud',
    this.tipoEtiqueta,
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

  /// ReporteOut del backend, para la lista y el mapa del voluntario.
  factory SolicitudAyudaModel.desdeReporte(Map<String, dynamic> json) {
    final ubicacion = json['ubicacion'] as Map<String, dynamic>;
    return SolicitudAyudaModel(
      id: json['id'] as String,
      clase: 'reporte',
      tipo: json['tipo'] as String,
      tipoEtiqueta: json['tipo_etiqueta'] as String?,
      origen: 'reporte',
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
  bool get esReporte => clase == 'reporte';

  /// Sigue abierto: una solicitud mientras no esté atendida ni cancelada; un reporte mientras
  /// esté pendiente o verificado (al finalizarlo el voluntario queda `atendido`).
  bool get cancelable => esReporte
      ? estado == 'pendiente' || estado == 'verificado'
      : estado == 'pendiente' || estado == 'en_proceso';

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
    'verificado': 'Verificado',
    'atendido': 'Atendido',
  };

  String get titulo => esReporte
      ? 'Reporte: ${tipoEtiqueta ?? tipo}'
      : esSos
          ? 'SOS'
          : (etiquetasTipo[tipo] ?? 'Solicitud de ayuda');
  String get estadoEtiqueta => etiquetasEstado[estado] ?? estado;
}
