import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reporte_model.dart';

/// Lista de reportes. Por ahora vive en memoria: los reportes nuevos se
/// mantienen mientras la app esté abierta.
/// TODO: reemplazar por llamadas a la API de rescate360-be.
class ReportesCiudadanoViewModel extends Notifier<List<ReporteCiudadano>> {
  @override
  List<ReporteCiudadano> build() => _ejemplo();

  void agregar(ReporteCiudadano reporte) {
    state = [reporte, ...state];
  }
}

final reportesCiudadanoProvider =
    NotifierProvider<ReportesCiudadanoViewModel, List<ReporteCiudadano>>(
  ReportesCiudadanoViewModel.new,
);

// Datos de ejemplo (ficticios) de otros ciudadanos, hasta conectar la API.
List<ReporteCiudadano> _ejemplo() {
  final ahora = DateTime.now();
  return [
    ReporteCiudadano(
      id: 'r1',
      tipo: 'accidente',
      descripcion:
          'Choque entre dos motos en la vía principal. Hay un herido leve.',
      fecha: ahora.subtract(const Duration(minutes: 35)),
      lugar: 'Vía principal, sector centro',
      esMio: false,
      estado: EstadoReporteCiudadano.enRevision,
    ),
    ReporteCiudadano(
      id: 'r2',
      tipo: 'robo',
      descripcion: 'Le robaron el celular a un peatón cerca del parque.',
      fecha: ahora.subtract(const Duration(hours: 2)),
      lugar: 'Parque central',
      esMio: false,
      estado: EstadoReporteCiudadano.pendiente,
    ),
    ReporteCiudadano(
      id: 'r3',
      tipo: 'inundacion',
      descripcion: 'El arroyo se desbordó y el agua entró a varias casas.',
      fecha: ahora.subtract(const Duration(hours: 4)),
      lugar: 'Barrio Los Cocos',
      esMio: false,
      estado: EstadoReporteCiudadano.enRevision,
    ),
    ReporteCiudadano(
      id: 'r4',
      tipo: 'deslizamiento',
      descripcion: 'Cayó tierra sobre la vía que lleva al corregimiento.',
      fecha: ahora.subtract(const Duration(days: 1)),
      lugar: 'Vía al corregimiento',
      esMio: false,
      estado: EstadoReporteCiudadano.pendiente,
    ),
    ReporteCiudadano(
      id: 'r5',
      tipo: 'incendio',
      descripcion:
          'Quema de basura que se estaba extendiendo al lote vecino. Ya fue '
          'controlada.',
      fecha: ahora.subtract(const Duration(days: 3)),
      lugar: 'Barrio El Prado',
      esMio: false,
      estado: EstadoReporteCiudadano.atendido,
    ),
  ];
}
