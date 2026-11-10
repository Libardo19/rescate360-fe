/// Nivel de la alerta: la app lo pinta como info (bajo), warning (medio) y danger (alto).
enum NivelAlerta {
  bajo,
  medio,
  alto;

  static NivelAlerta desde(String valor) =>
      NivelAlerta.values.firstWhere((n) => n.name == valor, orElse: () => NivelAlerta.medio);
}

/// AlertaOut del backend: un círculo con mensaje, nivel y vencimiento.
class AlertaModel {
  final String id;
  final String titulo;
  // Texto libre: inundacion, deslizamiento, seguridad, clima, sismo, otro…
  final String tipo;
  final String mensaje;
  final NivelAlerta nivel;
  final String estado;
  // manual o sismo
  final String origen;
  final double lat;
  final double lng;
  final double radioM;
  final DateTime creadaEn;
  final DateTime expiraEn;

  const AlertaModel({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.mensaje,
    required this.nivel,
    required this.estado,
    required this.origen,
    required this.lat,
    required this.lng,
    required this.radioM,
    required this.creadaEn,
    required this.expiraEn,
  });

  factory AlertaModel.fromJson(Map<String, dynamic> json) {
    final zona = json['zona'] as Map<String, dynamic>;
    return AlertaModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      tipo: json['tipo'] as String,
      mensaje: json['mensaje'] as String,
      nivel: NivelAlerta.desde(json['nivel'] as String),
      estado: json['estado'] as String,
      origen: json['origen'] as String,
      lat: (zona['lat'] as num).toDouble(),
      lng: (zona['lng'] as num).toDouble(),
      radioM: (zona['radio_m'] as num).toDouble(),
      creadaEn: DateTime.parse(json['creado_en'] as String).toLocal(),
      expiraEn: DateTime.parse(json['expira_en'] as String).toLocal(),
    );
  }

  String get haceCuanto {
    final minutos = DateTime.now().difference(creadaEn).inMinutes;
    if (minutos < 1) return 'Ahora';
    if (minutos < 60) return 'Hace $minutos min';
    final horas = minutos ~/ 60;
    if (horas < 24) return 'Hace $horas h';
    final dias = horas ~/ 24;
    return dias == 1 ? 'Hace 1 día' : 'Hace $dias días';
  }

  String get radioTexto => radioM >= 1000 ? '${(radioM / 1000).toStringAsFixed(radioM % 1000 == 0 ? 0 : 1)} km' : '${radioM.round()} m';
}
