import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../datasources/personas_desaparecidas_remote_datasource.dart';
import '../models/persona_desaparecida.dart';

class PersonasDesaparecidasRepository {
  PersonasDesaparecidasRepository(this._remoto);

  final PersonasDesaparecidasRemoteDatasource _remoto;

  Future<List<PersonaDesaparecida>> listar({String? busqueda}) => _remoto.listar(busqueda: busqueda);

  Future<PersonaDesaparecida> detalle(String id) => _remoto.detalle(id);

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
  }) =>
      _remoto.crear(
        nombre: nombre,
        edad: edad,
        sexo: sexo,
        fechaVista: fechaVista,
        lugar: lugar,
        descripcion: descripcion,
        contactoNombre: contactoNombre,
        contactoTelefono: contactoTelefono,
        estatura: estatura,
        senasParticulares: senasParticulares,
        vestimenta: vestimenta,
        foto: foto,
      );

  Future<PersonaDesaparecida> cambiarEstado(String id, EstadoPersona estado) =>
      _remoto.cambiarEstado(id, estado);
}

final personasRepositoryProvider = Provider<PersonasDesaparecidasRepository>((ref) {
  return PersonasDesaparecidasRepository(
      PersonasDesaparecidasRemoteDatasource(ref.watch(apiClientProvider)));
});
