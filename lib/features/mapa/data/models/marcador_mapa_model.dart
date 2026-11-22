/// PuntoMapa de GET /mapa (el mismo formato que usa el panel web).
class MarcadorMapaModel {
  final String id;
  final String capa; // solicitud | reporte | centro | zona | alerta | sismo
  final String tipo;
  final String titulo;
  final String detalle;
  final String estado;
  final String? prioridad;
  final double lat;
  final double lng;
  final double? radioM; // zonas, alertas y sismos de Colombia se dibujan como círculo
  final double? magnitud; // solo los sismos (de todo el mundo)
  final bool aproximada; // posición redondeada (~200 m): no es mío ni de mi organización
  final bool propio;
  final bool activo; // false = se cerró y hay que quitarlo del mapa

  const MarcadorMapaModel({
    required this.id,
    required this.capa,
    required this.tipo,
    required this.titulo,
    required this.detalle,
    required this.estado,
    this.prioridad,
    required this.lat,
    required this.lng,
    this.radioM,
    this.magnitud,
    required this.aproximada,
    required this.propio,
    required this.activo,
  });

  factory MarcadorMapaModel.fromJson(Map<String, dynamic> json) => MarcadorMapaModel(
        id: json['id'] as String,
        capa: json['capa'] as String,
        tipo: json['tipo'] as String,
        titulo: json['titulo'] as String,
        detalle: json['detalle'] as String,
        estado: json['estado'] as String,
        prioridad: json['prioridad'] as String?,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        radioM: (json['radio_m'] as num?)?.toDouble(),
        magnitud: (json['magnitud'] as num?)?.toDouble(),
        aproximada: json['aproximada'] as bool? ?? false,
        propio: json['propio'] as bool? ?? false,
        activo: json['activo'] as bool? ?? true,
      );
}

/// Respuesta de GET /mapa: los puntos y la hora del servidor (se manda como `desde`).
class RespuestaMapa {
  final List<MarcadorMapaModel> puntos;
  final String generadoEn;

  const RespuestaMapa(this.puntos, this.generadoEn);
}
