/// Estados del backend (EstadoReporte).
enum EstadoReporteCiudadano {
  pendiente('pendiente'),
  verificado('verificado'),
  rechazado('rechazado'),
  duplicado('duplicado'),
  noVerificable('no_verificable'),
  // Un voluntario lo atendió y finalizó su asignación
  atendido('atendido');

  const EstadoReporteCiudadano(this.valor);

  final String valor;

  static EstadoReporteCiudadano desde(String valor) =>
      EstadoReporteCiudadano.values.firstWhere((e) => e.valor == valor,
          orElse: () => EstadoReporteCiudadano.pendiente);
}

/// Reporte de un incidente hecho por un ciudadano.
class ReporteCiudadano {
  final String id;
  // Texto libre: uno de la lista sugerida o el que escribió el ciudadano ("fuga de gas")
  final String tipo;
  final String tipoEtiqueta;
  final String descripcion;
  final DateTime fecha;
  final String lugar;
  final bool esMio;
  final EstadoReporteCiudadano estado;
  // URLs (relativas al API) de las fotos
  final List<String> fotos;
  final int videos;
  final String? motivoRechazo;
  // Dónde pasó (para "Cómo llegar"); null si el dato no vino
  final double? lat;
  final double? lng;
  // Cuándo lo verificó la organización
  final DateTime? verificadoEn;

  const ReporteCiudadano({
    required this.id,
    required this.tipo,
    String? tipoEtiqueta,
    required this.descripcion,
    required this.fecha,
    required this.lugar,
    required this.esMio,
    required this.estado,
    this.fotos = const [],
    this.videos = 0,
    this.motivoRechazo,
    this.lat,
    this.lng,
    this.verificadoEn,
  }) : tipoEtiqueta = tipoEtiqueta ?? tipo;

  /// ReporteOut de GET /reportes (los míos) o de GET /reportes/{id} ([esMio] lo sabe quien lo pide)
  factory ReporteCiudadano.fromJson(Map<String, dynamic> json, {bool esMio = true}) {
    final evidencias =
        (json['evidencias'] as List).cast<Map<String, dynamic>>();
    final ubicacion = json['ubicacion'] as Map<String, dynamic>;
    return ReporteCiudadano(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      tipoEtiqueta: json['tipo_etiqueta'] as String?,
      descripcion: json['descripcion'] as String,
      fecha: DateTime.parse(json['creado_en'] as String).toLocal(),
      lugar: (json['direccion'] as String?) ??
          '${(ubicacion['lat'] as num).toStringAsFixed(4)}, ${(ubicacion['lng'] as num).toStringAsFixed(4)}',
      esMio: esMio,
      estado: EstadoReporteCiudadano.desde(json['estado'] as String),
      fotos: [
        for (final e in evidencias)
          if (e['tipo'] == 'foto') e['url'] as String
      ],
      videos: evidencias.where((e) => e['tipo'] == 'video').length,
      motivoRechazo: json['motivo_rechazo'] as String?,
      lat: (ubicacion['lat'] as num).toDouble(),
      lng: (ubicacion['lng'] as num).toDouble(),
      verificadoEn: json['verificado_en'] == null
          ? null
          : DateTime.parse(json['verificado_en'] as String).toLocal(),
    );
  }

  /// Punto de la capa "reportes" de GET /mapa: reportes verificados de la comunidad
  factory ReporteCiudadano.desdePuntoMapa(Map<String, dynamic> json) =>
      ReporteCiudadano(
        id: json['id'] as String,
        tipo: json['tipo'] as String,
        tipoEtiqueta: json['titulo'] as String?,
        descripcion: json['detalle'] as String,
        fecha: DateTime.parse(json['actualizado_en'] as String).toLocal(),
        lugar: 'Cerca de ti',
        esMio: json['propio'] as bool? ?? false,
        estado: EstadoReporteCiudadano.desde(json['estado'] as String),
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

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
