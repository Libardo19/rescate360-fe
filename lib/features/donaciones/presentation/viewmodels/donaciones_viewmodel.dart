import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/donacion_model.dart';
import '../../data/repositories/donaciones_repository.dart';

/// Campañas de donación vigentes, desde la API.
final campanasProvider = FutureProvider.autoDispose<List<CampanaModel>>((ref) {
  return ref.watch(donacionesRepositoryProvider).campanas();
});
