import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/sismo_model.dart';

/// colombia, mundo (fuera de Colombia) o null para todos.
enum RegionSismo { todos, colombia, mundo }

class SismosRepository {
  SismosRepository(this._api);

  final ApiClient _api;

  Future<List<SismoModel>> recientes({RegionSismo region = RegionSismo.todos, double? magnitudMin}) async {
    final pagina = await _api.get<Map<String, dynamic>>(Endpoints.sismos, query: {
      'por_pagina': 100,
      if (region != RegionSismo.todos) 'region': region.name,
      if (magnitudMin != null) 'magnitud_min': magnitudMin,
    });
    return [
      for (final s in (pagina['items'] as List).cast<Map<String, dynamic>>()) SismoModel.fromJson(s),
    ];
  }
}

final sismosRepositoryProvider = Provider<SismosRepository>((ref) {
  return SismosRepository(ref.watch(apiClientProvider));
});

/// Lista de la pantalla de sismos, por región.
final sismosProvider = FutureProvider.autoDispose.family<List<SismoModel>, RegionSismo>((ref, region) {
  return ref.watch(sismosRepositoryProvider).recientes(region: region);
});
