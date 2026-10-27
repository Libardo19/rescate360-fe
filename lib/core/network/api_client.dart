import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Cliente HTTP único de la app. Todas las llamadas reales pasan por aquí.
///
/// URL base: `Env.apiBaseUrl` (por defecto http://10.0.2.2:8000, el localhost de la PC
/// visto desde el emulador Android). En un teléfono real:
///   flutter run --dart-define=API_BASE_URL=http://<IP-de-tu-PC>:8000
class ApiClient {
  ApiClient({required this.storage, required void Function() alExpirarSesion})
      : dio = Dio(BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        )) {
    dio.interceptors.addAll([
      AuthInterceptor(storage: storage, dio: dio, alExpirarSesion: alExpirarSesion),
      ErrorInterceptor(),
    ]);
  }

  final Dio dio;
  final SecureStorage storage;

  Future<T> _llamar<T>(Future<Response<dynamic>> Function() peticion) async {
    try {
      return (await peticion()).data as T;
    } on DioException catch (e) {
      throw ApiException.desde(e);
    }
  }

  Future<T> get<T>(String ruta, {Map<String, dynamic>? query}) =>
      _llamar(() => dio.get(ruta, queryParameters: query));

  Future<T> post<T>(String ruta, {Object? datos}) => _llamar(() => dio.post(ruta, data: datos));

  Future<T> patch<T>(String ruta, {Object? datos}) => _llamar(() => dio.patch(ruta, data: datos));

  Future<T> delete<T>(String ruta) => _llamar(() => dio.delete(ruta));
}

/// La sesión vencida (sin refresh posible) la escucha SesionViewModel para volver al login.
final sesionExpiradaProvider = StateProvider<int>((ref) => 0);

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    storage: ref.watch(secureStorageProvider),
    alExpirarSesion: () => ref.read(sesionExpiradaProvider.notifier).state++,
  );
});
