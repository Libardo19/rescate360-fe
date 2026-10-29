import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mensaje_offline.dart';

/// Cola local del modo sin conexión, en el teléfono:
/// - propios: lo que este usuario generó sin red (se sube con /offline/sync);
/// - ajenos: lo que llegó de otros teléfonos por Bluetooth (se sube con /offline/relevo).
/// Máximo 50 en cada una; lo vencido (más de 24 h) se descarta.
class OfflineQueue {
  static const maximo = 50;
  static const _propios = 'offline_propios';
  static const _ajenos = 'offline_ajenos';

  Future<List<MensajeOffline>> _leer(String clave) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(clave) ?? const [];
    return [
      for (final texto in lista) MensajeOffline.fromJson(jsonDecode(texto) as Map<String, dynamic>)
    ].where((m) => !m.vencido).toList();
  }

  Future<void> _escribir(String clave, List<MensajeOffline> mensajes) async {
    final prefs = await SharedPreferences.getInstance();
    final recientes = mensajes.length > maximo ? mensajes.sublist(mensajes.length - maximo) : mensajes;
    await prefs.setStringList(clave, [for (final m in recientes) jsonEncode(m.toJson())]);
  }

  Future<List<MensajeOffline>> propios() => _leer(_propios);

  Future<List<MensajeOffline>> ajenos() => _leer(_ajenos);

  Future<List<MensajeOffline>> todos() async => [...await propios(), ...await ajenos()];

  Future<void> agregarPropio(MensajeOffline mensaje) async => _escribir(_propios, [...await propios(), mensaje]);

  /// Guarda los que llegaron por Bluetooth y no se conocían. Devuelve cuántos eran nuevos.
  Future<int> agregarAjenos(Iterable<MensajeOffline> recibidos, {required String miUsuarioId}) async {
    final conocidos = {for (final m in await todos()) m.uuidOrigen};
    final nuevos = [
      for (final m in recibidos)
        if (m.usuarioId != miUsuarioId && !conocidos.contains(m.uuidOrigen) && m.relevable) m.conUnSaltoMas()
    ];
    if (nuevos.isNotEmpty) await _escribir(_ajenos, [...await ajenos(), ...nuevos]);
    return nuevos.length;
  }

  /// Quita los que el backend ya recibió (aceptados, duplicados o rechazados para siempre).
  Future<void> quitar(Set<String> uuids) async {
    await _escribir(_propios, [for (final m in await propios()) if (!uuids.contains(m.uuidOrigen)) m]);
    await _escribir(_ajenos, [for (final m in await ajenos()) if (!uuids.contains(m.uuidOrigen)) m]);
  }
}

final offlineQueueProvider = Provider<OfflineQueue>((ref) => OfflineQueue());
