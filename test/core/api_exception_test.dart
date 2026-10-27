import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/core/errors/exceptions.dart';

DioException _respuesta(int status, Object? datos) {
  final opciones = RequestOptions(path: '/x');
  return DioException(
    requestOptions: opciones,
    response: Response(requestOptions: opciones, statusCode: status, data: datos),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  test('lee el formato {detalle, codigo} del backend', () {
    final e = ApiException.desde(_respuesta(401, {'detalle': 'Correo o contraseña incorrectos', 'codigo': 'CREDENCIALES_INVALIDAS'}));
    expect(e.status, 401);
    expect(e.codigo, 'CREDENCIALES_INVALIDAS');
    expect(e.mensaje, 'Correo o contraseña incorrectos');
  });

  test('los 422 muestran el primer campo con problema', () {
    final e = ApiException.desde(_respuesta(422, {
      'detalle': 'Los datos enviados no son válidos',
      'codigo': 'DATOS_INVALIDOS',
      'errores': [
        {'campo': 'tipo', 'mensaje': 'Usa solo letras, números y espacios'},
      ],
    }));
    expect(e.errores.single.campo, 'tipo');
    expect(e.mensaje, 'Los datos enviados no son válidos: Usa solo letras, números y espacios');
  });

  test('sin red da un mensaje entendible', () {
    final e = ApiException.desde(DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    ));
    expect(e.codigo, 'SIN_CONEXION');
  });

  test('una respuesta sin el formato del contrato no revienta', () {
    final e = ApiException.desde(_respuesta(500, '<html>error</html>'));
    expect(e.status, 500);
    expect(e.codigo, 'ERROR');
  });
}
