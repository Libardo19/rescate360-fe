import 'package:dio/dio.dart';
import '../../errors/exceptions.dart';

/// Convierte cualquier error en [ApiException] (formato `{detalle, codigo}` del backend),
/// así los repositorios y las pantallas solo manejan un tipo de error.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: ApiException.desde(err)));
  }
}
