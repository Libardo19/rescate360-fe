import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../dispositivo_model.dart';

class DispositivosRemoteDataSource {
  final ApiClient apiClient;

  DispositivosRemoteDataSource(this.apiClient);

  Future<Dispositivo> registrarDispositivo({
    required String tokenPush,
    String? plataforma,
  }) async {
    String plataformaFinal = plataforma ?? 'android';
    if (kIsWeb) {
      plataformaFinal = 'web';
    } else if (Platform.isIOS) {
      plataformaFinal = 'ios';
    } else if (Platform.isAndroid) {
      plataformaFinal = 'android';
    }

    final response = await apiClient.post(
      '/usuarios/me/dispositivo',
      datos: {
        'token_push': tokenPush,
        'plataforma': plataformaFinal,
      },
    );

    return Dispositivo.fromJson(response as Map<String, dynamic>);
  }

  Future<void> eliminarDispositivo(String tokenPush) async {
    await apiClient.delete('/usuarios/me/dispositivo/$tokenPush');
  }
}
