import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Lo escrito en el formulario de reportar incidente, para mandarlo sin internet.
/// Las fotos no viajan: son muy pesadas para el relevo por Bluetooth.
class ReporteOffline {
  static const maximoDescripcion = 500;

  final String tipo;
  final String descripcion;
  final String? direccion;

  const ReporteOffline(
      {required this.tipo, required this.descripcion, this.direccion});

  factory ReporteOffline.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipo'];
    final descripcion = json['descripcion'];
    final direccion = json['direccion'];
    if (tipo is! String || tipo.trim().length < 3 || tipo.length > 30) {
      throw const FormatException('Tipo de reporte inválido');
    }
    if (descripcion is! String ||
        descripcion.trim().length < 3 ||
        descripcion.length > maximoDescripcion) {
      throw const FormatException('Descripción de reporte inválida');
    }
    if (direccion != null && (direccion is! String || direccion.length > 50)) {
      throw const FormatException('Dirección de reporte inválida');
    }
    return ReporteOffline(
        tipo: tipo, descripcion: descripcion, direccion: direccion as String?);
  }

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
  static const maximoBytesLote = 64 * 1024;
  static const maximoMensajesLote = 50;
  static const _tipos = {
    'sos',
    'necesito_ayuda',
    'a_salvo',
    'sin_respuesta',
    'reporte'
  };
  static final _uuidValido =
      RegExp(r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$');
  static final _firmaValida = RegExp(r'^[0-9a-f]{64}$');

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

  static String textoAFirmar(String uuidOrigen, String usuarioId, String tipo,
      double lat, double lng, String generadoEn,
      [ReporteOffline? reporte]) {
    final texto =
        '$uuidOrigen|$usuarioId|$tipo|${lat.toStringAsFixed(6)}|${lng.toStringAsFixed(6)}|$generadoEn';
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
    final texto =
        textoAFirmar(uuidOrigen, usuarioId, tipo, lat, lng, generado, reporte);
    final firma =
        Hmac(sha256, utf8.encode(llave)).convert(utf8.encode(texto)).toString();
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

  factory MensajeOffline.fromJson(Map<String, dynamic> json) {
    final uuidOrigen = json['uuid_origen'];
    final usuarioId = json['usuario_id'];
    final tipo = json['tipo'];
    final lat = json['lat'];
    final lng = json['lng'];
    final generadoEn = json['generado_en'];
    final saltos = json['saltos'] ?? 0;
    final firma = json['firma'];
    if (uuidOrigen is! String ||
        !_uuidValido.hasMatch(uuidOrigen) ||
        usuarioId is! String ||
        !_uuidValido.hasMatch(usuarioId)) {
      throw const FormatException('Identificador de mensaje inválido');
    }
    if (tipo is! String || !_tipos.contains(tipo)) {
      throw const FormatException('Tipo de mensaje inválido');
    }
    if (lat is! num ||
        !lat.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng is! num ||
        !lng.isFinite ||
        lng < -180 ||
        lng > 180) {
      throw const FormatException('Coordenadas inválidas');
    }
    if (generadoEn is! String ||
        generadoEn.length < 10 ||
        generadoEn.length > 40 ||
        DateTime.tryParse(generadoEn) == null) {
      throw const FormatException('Fecha de mensaje inválida');
    }
    if (saltos is! int || saltos < 0 || saltos > maximoSaltos) {
      throw const FormatException('Número de saltos inválido');
    }
    if (firma is! String || !_firmaValida.hasMatch(firma)) {
      throw const FormatException('Firma de mensaje inválida');
    }
    final reporteJson = json['reporte'];
    if (reporteJson != null && reporteJson is! Map<String, dynamic>) {
      throw const FormatException('Reporte offline inválido');
    }
    final reporte = reporteJson == null
        ? null
        : ReporteOffline.fromJson(reporteJson as Map<String, dynamic>);
    if ((tipo == 'reporte') != (reporte != null)) {
      throw const FormatException(
          'Los datos de reporte no corresponden al tipo de mensaje');
    }
    return MensajeOffline(
      uuidOrigen: uuidOrigen,
      usuarioId: usuarioId,
      tipo: tipo,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      generadoEn: generadoEn,
      saltos: saltos,
      firma: firma,
      reporte: reporte,
    );
  }

  /// Decodifica un lote de Nearby después de limitar su tamaño y validar cada elemento.
  static List<MensajeOffline> desdeLoteBytes(List<int> bytes) {
    if (bytes.length > maximoBytesLote) {
      throw const FormatException('El lote offline supera el tamaño permitido');
    }
    final valor = jsonDecode(utf8.decode(bytes));
    if (valor is! List || valor.length > maximoMensajesLote) {
      throw const FormatException('El lote offline tiene un formato inválido');
    }
    return [
      for (final elemento in valor)
        if (elemento is Map<String, dynamic>)
          MensajeOffline.fromJson(elemento)
        else
          throw const FormatException('Elemento de lote offline inválido'),
    ];
  }

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
    return generado == null ||
        DateTime.now().toUtc().difference(generado) > vigencia;
  }

  /// Se puede seguir pasando: no venció y no llegó al máximo de saltos.
  bool get relevable => !vencido && saltos < maximoSaltos;
}
