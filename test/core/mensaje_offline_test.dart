import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/core/offline/mensaje_offline.dart';

void main() {
  test('la firma es la misma que verifica el backend (offline_schema.texto_a_firmar + HMAC-SHA256)', () {
    // Valor de referencia calculado con el código del backend (rescate360-be)
    final mensaje = MensajeOffline.firmado(
      llave: 'llave-de-prueba',
      uuidOrigen: '7f3c2a10-1111-4222-8333-944455556666',
      usuarioId: '0a1b2c3d-0000-4000-8000-000000000001',
      tipo: 'sos',
      lat: 10.4631,
      lng: -73.2532,
      ahora: DateTime.utc(2026, 10, 29, 15, 4, 5, 123),
    );
    expect(mensaje.generadoEn, '2026-10-29T15:04:05Z');
    expect(mensaje.firma, '3adbd44790f3237b138f1ece9ebfa2f55089063fa8d686552be0d0745f1ffba8');
  });

  test('un reporte firma también su tipo y descripción, igual que el backend', () {
    // Valor de referencia calculado con offline_schema.texto_a_firmar del backend (rescate360-be)
    final mensaje = MensajeOffline.firmado(
      llave: 'llave-de-prueba',
      uuidOrigen: '7f3c2a10-1111-4222-8333-944455556666',
      usuarioId: '0a1b2c3d-0000-4000-8000-000000000001',
      tipo: 'reporte',
      lat: 10.4631,
      lng: -73.2532,
      reporte: const ReporteOffline(tipo: 'Inundación', descripcion: 'El caño se desbordó'),
      ahora: DateTime.utc(2026, 10, 29, 15, 4, 5),
    );
    expect(mensaje.firma, '68087ee5203b4f67ef0719609d102440b7d933be263b573bd9ffce02c20f213e');
    // Viaja por Bluetooth como JSON y vuelve igual, con su reporte
    final copia = MensajeOffline.fromJson(mensaje.conUnSaltoMas().toJson());
    expect(copia.reporte!.descripcion, 'El caño se desbordó');
    expect(copia.firma, mensaje.firma);
  });

  test('cada relevo suma un salto sin tocar la firma y deja de relevarse al máximo', () {
    var mensaje = MensajeOffline.firmado(
      llave: 'k',
      uuidOrigen: 'u1',
      usuarioId: 'yo',
      tipo: 'a_salvo',
      lat: 1,
      lng: 2,
    );
    final firma = mensaje.firma;
    for (var i = 0; i < MensajeOffline.maximoSaltos; i++) {
      expect(mensaje.relevable, isTrue);
      mensaje = mensaje.conUnSaltoMas();
    }
    expect(mensaje.saltos, MensajeOffline.maximoSaltos);
    expect(mensaje.relevable, isFalse);
    expect(mensaje.firma, firma);
    expect(MensajeOffline.fromJson(mensaje.toJson()).toJson(), mensaje.toJson());
  });

  test('un mensaje de hace más de 24 horas está vencido', () {
    final viejo = MensajeOffline.firmado(
      llave: 'k',
      uuidOrigen: 'u2',
      usuarioId: 'yo',
      tipo: 'sos',
      lat: 1,
      lng: 2,
      ahora: DateTime.now().subtract(const Duration(hours: 25)),
    );
    expect(viejo.vencido, isTrue);
    expect(viejo.relevable, isFalse);
  });
}
