class Dispositivo {
  final String id;
  final String tokenPush;
  final String plataforma;
  final DateTime actualizadoEn;

  Dispositivo({
    required this.id,
    required this.tokenPush,
    required this.plataforma,
    required this.actualizadoEn,
  });

  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    return Dispositivo(
      id: json['id'].toString(),
      tokenPush: json['token_push']?.toString() ?? '',
      plataforma: json['plataforma']?.toString() ?? '',
      actualizadoEn: DateTime.parse(json['actualizado_en'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token_push': tokenPush,
      'plataforma': plataforma,
      'actualizado_en': actualizadoEn.toIso8601String(),
    };
  }
}
