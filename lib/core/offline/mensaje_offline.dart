import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Lo escrito en el formulario de reportar incidente, para mandarlo sin internet.
/// Las fotos no viajan: son muy pesadas para el relevo por Bluetooth.
class ReporteOffline {
  static const maximoDescripcion = 500;

  final String tipo;
  final String descripcion;
  final String? direccion;

  const ReporteOffline({required this.tipo, required this.descripcion, this.direccion});

  factory ReporteOffline.fromJson(Map<String, dynamic> json) => ReporteOffline(
        tipo: json['tipo'] as String,
        descripcion: json['descripcion'] as String,
        direccion: json['direccion'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'descripcion': descripcion,
        if (direccion != null) 'direccion': direccion,
      };
}

/// Mensaje de emergencia sin conexión. Pequeño para pasarlo por Bluetooth.
///
/// Lo firma el teléfono del autor con su llave offline (la entrega el backend al iniciar sesión):
///   firma = HMAC-SHA256(llave, "uuid_origen|usuario_id|tipo|lat|lng|generado_en") en hex
/// con lat y lng a 6 decimales. Un `reporte` firma además "|tipo|descripcion|direccion".
/// Así quien lo pasa no puede inventarlo ni cambiarlo.
/// `saltos` no entra en la firma: cada teléfono que lo pasa le suma uno.
class MensajeOffline {
  static const maximoSaltos = 8;
  static const vigencia = Duration(hours: 24);

  final String uuidOrigen;
  final String usuarioId;
  // sos | necesito_ayuda | a_salvo | sin_respuesta | reporte
  final String tipo;
  final double lat;
  final double lng;
  // ISO 8601 en UTC, exactamente como se firmó
  final String generadoEn;
  final int saltos;
  final String firma;
  // Solo en los de tipo "reporte"
  final ReporteOffline? reporte;

  const MensajeOffline({
    required this.uuidOrigen,
    required this.usuarioId,
    required this.tipo,
    required this.lat,
    required this.lng,
    required this.generadoEn,
    required this.saltos,
    required this.firma,
    this.reporte,
  });

  static String textoAFirmar(String uuidOrigen, String usuarioId, String tipo, double lat, double lng, String generadoEn,
      [ReporteOffline? reporte]) {
    final texto = '$uuidOrigen|$usuarioId|$tipo|${lat.toStringAsFixed(6)}|${lng.toStringAsFixed(6)}|$generadoEn';
    if (reporte == null) return texto;
    return '$texto|${reporte.tipo}|${reporte.descripcion}|${reporte.direccion ?? ''}';
  }

  /// Crea y firma un mensaje propio.
  factory MensajeOffline.firmado({
    required String llave,
    required String uuidOrigen,
    required String usuarioId,
    required String tipo,
    required double lat,
    required double lng,
    ReporteOffline? reporte,
    DateTime? ahora,
  }) {
    final momento = (ahora ?? DateTime.now()).toUtc();
    // Sin milisegundos: el backend recibe el mismo texto que se firmó
    final generado = '${momento.toIso8601String().split('.').first}Z';
    final texto = textoAFirmar(uuidOrigen, usuarioId, tipo, lat, lng, generado, reporte);
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
      reporte: reporte,
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
        reporte: json['reporte'] == null ? null : ReporteOffline.fromJson(json['reporte'] as Map<String, dynamic>),
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
        if (reporte != null) 'reporte': reporte!.toJson(),
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
        reporte: reporte,
      );

  bool get vencido {
    final generado = DateTime.tryParse(generadoEn);
    return generado == null || DateTime.now().toUtc().difference(generado) > vigencia;
  }

  /// Se puede seguir pasando: no venció y no llegó al máximo de saltos.
  bool get relevable => !vencido && saltos < maximoSaltos;
}
