import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../data/datasources/dispositivos_remote_datasource.dart';
import '../../data/dispositivo_model.dart';
import '../../data/repositories/dispositivos_repository.dart';

final dispositivosRemoteDataSourceProvider = Provider<DispositivosRemoteDataSource>((ref) {
  return DispositivosRemoteDataSource(ref.watch(apiClientProvider));
});

final dispositivosRepositoryProvider = Provider<DispositivosRepository>((ref) {
  return DispositivosRepository(ref.watch(dispositivosRemoteDataSourceProvider));
});

final dispositivosViewModelProvider = StateNotifierProvider<DispositivosViewModel, AsyncValue<Dispositivo?>>((ref) {
  return DispositivosViewModel(ref);
});

class DispositivosViewModel extends StateNotifier<AsyncValue<Dispositivo?>> {
  final Ref ref;

  DispositivosViewModel(this.ref) : super(const AsyncValue.data(null));

  Future<void> registrarTokenSiExiste() async {
    final token = await PushNotificationService().getSavedToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      state = const AsyncValue.loading();
      final repo = ref.read(dispositivosRepositoryProvider);
      final dispositivo = await repo.registrarDispositivo(tokenPush: token);
      state = AsyncValue.data(dispositivo);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> eliminarToken(String tokenPush) async {
    try {
      final repo = ref.read(dispositivosRepositoryProvider);
      await repo.eliminarDispositivo(tokenPush);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
