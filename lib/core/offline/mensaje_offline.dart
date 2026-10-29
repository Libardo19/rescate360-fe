import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Mensaje de emergencia sin conexión. Pequeño (menos de 512 bytes) para pasarlo por Bluetooth.
///
/// Lo firma el teléfono del autor con su llave offline (la entrega el backend al iniciar sesión):
///   firma = HMAC-SHA256(llave, "uuid_origen|usuario_id|tipo|lat|lng|generado_en") en hex
/// con lat y lng a 6 decimales. Así quien lo pasa no puede inventarlo ni cambiarlo.
/// `saltos` no entra en la firma: cada teléfono que lo pasa le suma uno.
class MensajeOffline {
  static const maximoSaltos = 8;
  static const vigencia = Duration(hours: 24);

  final String uuidOrigen;
  final String usuarioId;
  // sos | necesito_ayuda | a_salvo | sin_respuesta
  final String tipo;
  final double lat;
  final double lng;
  // ISO 8601 en UTC, exactamente como se firmó
  final String generadoEn;
  final int saltos;
  final String firma;

  const MensajeOffline({
    required this.uuidOrigen,
    required this.usuarioId,
    required this.tipo,
    required this.lat,
    required this.lng,
    required this.generadoEn,
    required this.saltos,
    required this.firma,
  });

  static String textoAFirmar(String uuidOrigen, String usuarioId, String tipo, double lat, double lng, String generadoEn) =>
      '$uuidOrigen|$usuarioId|$tipo|${lat.toStringAsFixed(6)}|${lng.toStringAsFixed(6)}|$generadoEn';

  /// Crea y firma un mensaje propio.
  factory MensajeOffline.firmado({
    required String llave,
    required String uuidOrigen,
    required String usuarioId,
    required String tipo,
    required double lat,
    required double lng,
    DateTime? ahora,
  }) {
    final momento = (ahora ?? DateTime.now()).toUtc();
    // Sin milisegundos: el backend recibe el mismo texto que se firmó
    final generado = '${momento.toIso8601String().split('.').first}Z';
    final texto = textoAFirmar(uuidOrigen, usuarioId, tipo, lat, lng, generado);
    final firma = Hmac(sha256, utf8.encode(llave)).convert(utf8.encode(texto)).toString();
    return MensajeOffline(
      uuidOrigen: uuidOrigen,
      usuarioId: usuarioId,
      tipo: tipo,
      lat: lat,
      lng: lng,
      generadoEn: generado,
      saltos: 0,
      firma: firma,
    );
  }

  factory MensajeOffline.fromJson(Map<String, dynamic> json) => MensajeOffline(
        uuidOrigen: json['uuid_origen'] as String,
        usuarioId: json['usuario_id'] as String,
        tipo: json['tipo'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        generadoEn: json['generado_en'] as String,
        saltos: (json['saltos'] as num?)?.toInt() ?? 0,
        firma: json['firma'] as String,
      );

  Map<String, dynamic> toJson() => {
        'uuid_origen': uuidOrigen,
        'usuario_id': usuarioId,
        'tipo': tipo,
        'lat': lat,
        'lng': lng,
        'generado_en': generadoEn,
        'saltos': saltos,
        'firma': firma,
      };

  /// El mismo mensaje con un salto más (al recibirlo de otro teléfono).
  MensajeOffline conUnSaltoMas() => MensajeOffline(
        uuidOrigen: uuidOrigen,
        usuarioId: usuarioId,
        tipo: tipo,
        lat: lat,
        lng: lng,
        generadoEn: generadoEn,
        saltos: saltos + 1,
        firma: firma,
      );

  bool get vencido {
    final generado = DateTime.tryParse(generadoEn);
    return generado == null || DateTime.now().toUtc().difference(generado) > vigencia;
  }

  /// Se puede seguir pasando: no venció y no llegó al máximo de saltos.
  bool get relevable => !vencido && saltos < maximoSaltos;
}
