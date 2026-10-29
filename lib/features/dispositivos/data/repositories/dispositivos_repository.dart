import '../datasources/dispositivos_remote_datasource.dart';
import '../dispositivo_model.dart';

class DispositivosRepository {
  final DispositivosRemoteDataSource remoteDataSource;

  DispositivosRepository(this.remoteDataSource);

  Future<Dispositivo> registrarDispositivo({
    required String tokenPush,
    String? plataforma,
  }) {
    return remoteDataSource.registrarDispositivo(
      tokenPush: tokenPush,
      plataforma: plataforma,
    );
  }

  Future<void> eliminarDispositivo(String tokenPush) {
    return remoteDataSource.eliminarDispositivo(tokenPush);
  }
}
