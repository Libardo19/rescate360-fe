import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/persona_desaparecida.dart';

class PersonasDesaparecidasRemoteDatasource {
  PersonasDesaparecidasRemoteDatasource(this._api);

  final ApiClient _api;

  Future<List<PersonaDesaparecida>> listar({String? busqueda}) async {
    final pagina = await _api.get<Map<String, dynamic>>(Endpoints.personas, query: {
      'por_pagina': 100,
      if (busqueda != null && busqueda.isNotEmpty) 'q': busqueda,
    });
    return [
      for (final p in (pagina['items'] as List).cast<Map<String, dynamic>>())
        PersonaDesaparecida.fromJson(p)
    ];
  }

  Future<PersonaDesaparecida> detalle(String id) async =>
      PersonaDesaparecida.fromJson(await _api.get<Map<String, dynamic>>(Endpoints.persona(id)));

  /// POST multipart. Publicar la foto exige la autorización (acepta_publicar_foto).
  Future<PersonaDesaparecida> crear({
    required String nombre,
    required int edad,
    required String sexo,
    required DateTime fechaVista,
    required String lugar,
    required String descripcion,
    required String contactoNombre,
    required String contactoTelefono,
    String? estatura,
    String? senasParticulares,
    String? vestimenta,
    Uint8List? foto,
  }) async {
    final datos = FormData.fromMap({
      'nombre': nombre,
      'edad': edad.toString(),
      'sexo': sexo,
      'fecha_vista': fechaApi(fechaVista),
      'lugar': lugar,
      'descripcion': descripcion,
      'contacto_nombre': contactoNombre,
      'contacto_telefono': contactoTelefono,
      if (estatura != null) 'estatura': estatura,
      if (senasParticulares != null) 'senas_particulares': senasParticulares,
      if (vestimenta != null) 'vestimenta': vestimenta,
      if (foto != null) ...{
        'acepta_publicar_foto': 'true',
        'foto': MultipartFile.fromBytes(foto, filename: 'foto.jpg'),
      },
    });
    return PersonaDesaparecida.fromJson(
        await _api.post<Map<String, dynamic>>(Endpoints.personas, datos: datos));
  }

  Future<PersonaDesaparecida> cambiarEstado(String id, EstadoPersona estado) async =>
      PersonaDesaparecida.fromJson(await _api.patch<Map<String, dynamic>>(
          Endpoints.estadoPersona(id),
          datos: {'estado': estado.valor}));
}
