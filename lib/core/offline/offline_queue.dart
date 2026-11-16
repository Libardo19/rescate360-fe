import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mensaje_offline.dart';
import '../storage/secure_storage.dart';

/// Cola local del modo sin conexión, en el teléfono:
/// - propios: lo que este usuario generó sin red (se sube con /offline/sync);
/// - ajenos: lo que llegó de otros teléfonos por Bluetooth (se sube con /offline/relevo).
/// Máximo 50 en cada una; lo vencido (más de 24 h) se descarta.
class OfflineQueue {
  OfflineQueue(this._storage);

  static const maximo = 50;
  static const _propios = 'offline_propios';
  static const _ajenos = 'offline_ajenos';

  final SecureStorage _storage;

  /// Migra una cola antigua de SharedPreferences a almacenamiento cifrado.
  Future<String?> _contenidoSeguro(String clave, {required bool ajena}) async {
    final seguro = await _storage.leerColaOffline(ajena: ajena);
    if (seguro != null) return seguro;

    final prefs = await SharedPreferences.getInstance();
    final anterior = prefs.getStringList(clave);
    if (anterior == null) return null;

    final migrado = jsonEncode(anterior);
    await _storage.guardarColaOffline(migrado, ajena: ajena);
    await prefs.remove(clave);
    return migrado;
  }

  Future<List<MensajeOffline>> _leer(String clave,
      {required bool ajena}) async {
    final contenido = await _contenidoSeguro(clave, ajena: ajena);
    if (contenido == null) return [];
    try {
      final json = jsonDecode(contenido);
      if (json is! List ||
          json.length > maximo ||
          json.any((item) => item is! String)) {
        throw const FormatException('Cola offline inválida');
      }
      return [
        for (final texto in json)
          MensajeOffline.fromJson(
              jsonDecode(texto as String) as Map<String, dynamic>)
      ].where((m) => !m.vencido).toList();
    } on FormatException {
      await _storage.borrarColaOffline(ajena: ajena);
      return [];
    } on TypeError {
      await _storage.borrarColaOffline(ajena: ajena);
      return [];
    }
  }

  Future<void> _escribir(String clave, List<MensajeOffline> mensajes,
      {required bool ajena}) async {
    final recientes = mensajes.length > maximo
        ? mensajes.sublist(mensajes.length - maximo)
        : mensajes;
    await _storage.guardarColaOffline(
      jsonEncode([for (final m in recientes) jsonEncode(m.toJson())]),
      ajena: ajena,
    );
  }

  Future<List<MensajeOffline>> propios() => _leer(_propios, ajena: false);

  Future<List<MensajeOffline>> ajenos() => _leer(_ajenos, ajena: true);

  Future<List<MensajeOffline>> todos() async =>
      [...await propios(), ...await ajenos()];

  Future<void> agregarPropio(MensajeOffline mensaje) async =>
      _escribir(_propios, [...await propios(), mensaje], ajena: false);

  /// Guarda los que llegaron por Bluetooth y no se conocían. Devuelve cuántos eran nuevos.
  Future<int> agregarAjenos(Iterable<MensajeOffline> recibidos,
      {required String miUsuarioId}) async {
    final conocidos = {for (final m in await todos()) m.uuidOrigen};
    final nuevos = [
      for (final m in recibidos)
        if (m.usuarioId != miUsuarioId &&
            !conocidos.contains(m.uuidOrigen) &&
            m.relevable)
          m.conUnSaltoMas()
    ];
    if (nuevos.isNotEmpty) {
      await _escribir(_ajenos, [...await ajenos(), ...nuevos], ajena: true);
    }
    return nuevos.length;
  }

  /// Quita los que el backend ya recibió (aceptados, duplicados o rechazados para siempre).
  Future<void> quitar(Set<String> uuids) async {
    await _escribir(
        _propios,
        [
          for (final m in await propios())
            if (!uuids.contains(m.uuidOrigen)) m
        ],
        ajena: false);
    await _escribir(
        _ajenos,
        [
          for (final m in await ajenos())
            if (!uuids.contains(m.uuidOrigen)) m
        ],
        ajena: true);
  }
}

final offlineQueueProvider =
    Provider<OfflineQueue>((ref) => OfflineQueue(SecureStorage()));
