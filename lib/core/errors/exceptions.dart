import 'package:dio/dio.dart';

/// Error del contrato del backend: `{"detalle": "...", "codigo": "..."}` y, en los 422,
/// `errores: [{campo, mensaje}]`. Las pantallas muestran [mensaje].
class ApiException implements Exception {
  final int? status;
  final String codigo;
  final String detalle;
  final List<({String campo, String mensaje})> errores;

  const ApiException({
    this.status,
    required this.codigo,
    required this.detalle,
    this.errores = const [],
  });

  /// Texto listo para mostrar: el detalle del backend y, si hay, el primer campo con problema.
  String get mensaje =>
      errores.isEmpty ? detalle : '$detalle: ${errores.first.mensaje}';

  /// Convierte cualquier error de dio en [ApiException] (sin red, timeout o respuesta del backend).
  factory ApiException.desde(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      if (error.error is ApiException) return error.error as ApiException;
      final datos = error.response?.data;
      if (datos is Map && datos['detalle'] is String) {
        final errores = (datos['errores'] as List? ?? [])
            .whereType<Map>()
            .map((e) => (campo: '${e['campo']}', mensaje: '${e['mensaje']}'))
            .toList();
        return ApiException(
          status: error.response?.statusCode,
          codigo: '${datos['codigo'] ?? 'ERROR'}',
          detalle: datos['detalle'] as String,
          errores: errores,
        );
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return const ApiException(
          codigo: 'SIN_CONEXION',
          detalle: 'No hay conexión con el servidor. Revisa tu internet e intenta de nuevo.',
        );
      }
      return ApiException(
        status: error.response?.statusCode,
        codigo: 'ERROR',
        detalle: 'Ocurrió un error (${error.response?.statusCode ?? 'sin respuesta'}).',
      );
    }
    return const ApiException(codigo: 'ERROR', detalle: 'Ocurrió un error inesperado.');
  }

  @override
  String toString() => 'ApiException($codigo, $detalle)';
}
