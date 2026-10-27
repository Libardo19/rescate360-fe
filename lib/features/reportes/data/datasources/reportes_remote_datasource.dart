import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/reporte_model.dart';

class ReportesRemoteDatasource {
  ReportesRemoteDatasource(this._api);

  final ApiClient _api;

  /// Lista sugerida de tipos: [{valor, etiqueta}]
  Future<List<({String valor, String etiqueta})>> tipos() async {
    final lista = await _api.get<List<dynamic>>(Endpoints.tiposReporte);
    return [
      for (final t in lista.cast<Map<String, dynamic>>())
        (valor: t['valor'] as String, etiqueta: t['etiqueta'] as String),
    ];
  }

  /// POST /reportes en multipart: campos del formulario + fotos y videos.
  Future<ReporteCiudadano> crear({
    required String tipo,
    required String descripcion,
    required double lat,
    required double lng,
    required List<XFile> archivos,
  }) async {
    final datos = FormData.fromMap({
      'tipo': tipo,
      'descripcion': descripcion,
      'lat': lat.toString(),
      'lng': lng.toString(),
      'archivos': [
        for (final a in archivos)
          MultipartFile.fromBytes(await a.readAsBytes(), filename: a.name),
      ],
    });
    return ReporteCiudadano.fromJson(await _api
        .post<Map<String, dynamic>>(Endpoints.reportes, datos: datos));
  }

  /// Para el ciudadano, GET /reportes devuelve solo los suyos.
  Future<List<ReporteCiudadano>> misReportes() async {
    final pagina = await _api.get<Map<String, dynamic>>(Endpoints.reportes,
        query: {'por_pagina': 50});
    return [
      for (final r in (pagina['items'] as List).cast<Map<String, dynamic>>())
        ReporteCiudadano.fromJson(r)
    ];
  }

  /// Reportes verificados de la comunidad (públicos), desde la capa de reportes del mapa.
  Future<List<ReporteCiudadano>> comunidad() async {
    final mapa = await _api.get<Map<String, dynamic>>(Endpoints.mapa,
        query: {'capas': 'reportes'});
    return [
      for (final p in (mapa['puntos'] as List).cast<Map<String, dynamic>>())
        if (p['propio'] != true) ReporteCiudadano.desdePuntoMapa(p),
    ];
  }
}
