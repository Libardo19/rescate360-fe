import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

enum EstadoDisponibilidad { disponible, ocupado, fueraDeServicio }

/// Disponibilidad del voluntario.
/// Por ahora solo vive en la app: el backend todavía no la guarda.
class DisponibilidadNotifier extends Notifier<EstadoDisponibilidad> {
  @override
  EstadoDisponibilidad build() => EstadoDisponibilidad.disponible;

  void cambiar(EstadoDisponibilidad nuevo) => state = nuevo;
}

final disponibilidadProvider =
    NotifierProvider<DisponibilidadNotifier, EstadoDisponibilidad>(
  DisponibilidadNotifier.new,
);

/// Casos que el voluntario ocultó ("rechazó") en este celular.
/// El backend no tiene la acción de rechazar, así que solo se ocultan aquí.
class CasosOcultosNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void ocultar(String idCaso) => state = {...state, idCaso};

  void restaurarTodos() => state = <String>{};
}

final casosOcultosProvider =
    NotifierProvider<CasosOcultosNotifier, Set<String>>(
  CasosOcultosNotifier.new,
);

/// Ubicación actual del voluntario, para calcular distancias a los casos.
/// Devuelve null si no hay GPS, permiso o señal.
final miUbicacionProvider = FutureProvider.autoDispose<Position?>((ref) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
  } catch (_) {
    return null;
  }
});

// ------------------------------------------------------- atención del caso

/// Pasos del voluntario mientras atiende un caso (mockup 12).
enum PasoAtencion { enCamino, enSitio, enAtencion, finalizado }

/// Progreso local de una asignación: no hay endpoints para estos sub-estados,
/// así que se guardan solo en el celular.
class AtencionEstado {
  final PasoAtencion paso;
  final Map<PasoAtencion, DateTime> fechas;
  final String notas;

  const AtencionEstado({
    this.paso = PasoAtencion.enCamino,
    this.fechas = const {},
    this.notas = '',
  });
}

class AtencionNotifier extends Notifier<Map<String, AtencionEstado>> {
  @override
  Map<String, AtencionEstado> build() => {};

  AtencionEstado de(String asignacionId) =>
      state[asignacionId] ?? const AtencionEstado();

  void actualizar(
    String asignacionId,
    PasoAtencion paso, {
    String? notas,
  }) {
    final actual = de(asignacionId);
    state = {
      ...state,
      asignacionId: AtencionEstado(
        paso: paso,
        notas: notas ?? actual.notas,
        fechas: {...actual.fechas, paso: DateTime.now()},
      ),
    };
  }

  void limpiar(String asignacionId) {
    final copia = {...state}..remove(asignacionId);
    state = copia;
  }
}

final atencionProvider =
    NotifierProvider<AtencionNotifier, Map<String, AtencionEstado>>(
  AtencionNotifier.new,
);
