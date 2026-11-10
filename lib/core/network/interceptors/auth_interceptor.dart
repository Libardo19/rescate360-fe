import 'package:dio/dio.dart';
import '../../storage/secure_storage.dart';
import '../endpoints.dart';

/// Agrega el token a cada petición y, si el backend responde 401, renueva la sesión
/// con el refresh token y repite la petición una sola vez.
/// Es un [QueuedInterceptor]: si llegan varios 401 a la vez, solo se renueva una vez.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.storage,
    required this.dio,
    required this.alExpirarSesion,
  });

  final SecureStorage storage;
  // El mismo cliente, para repetir la petición original con el token nuevo
  final Dio dio;
  // La sesión no se pudo renovar: la app vuelve al login
  final void Function() alExpirarSesion;

  static const _reintento = 'reintento';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.accessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final opciones = err.requestOptions;
    final esAuth = opciones.path.startsWith('/auth/');
    if (err.response?.statusCode != 401 || esAuth || opciones.extra[_reintento] == true) {
      return handler.next(err);
    }

    final refresh = await storage.refreshToken();
    if (refresh == null) return handler.next(err);

    try {
      // Cliente aparte, sin interceptores, para no entrar en un ciclo
      final respuesta = await Dio(BaseOptions(baseUrl: opciones.baseUrl))
          .post(Endpoints.refresh, data: {'refresh_token': refresh});
      final datos = respuesta.data as Map<String, dynamic>;
      await storage.guardarTokens(datos['access_token'] as String, datos['refresh_token'] as String);

      opciones.extra[_reintento] = true;
      opciones.headers['Authorization'] = 'Bearer ${datos['access_token']}';
      return handler.resolve(await dio.fetch(opciones));
    } on DioException {
      await storage.borrarSesion();
      alExpirarSesion();
      return handler.next(err);
    }
  }
}
