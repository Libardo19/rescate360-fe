import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../mapa/data/models/marcador_mapa_model.dart';
import '../../../mapa/presentation/views/mapa_emergencia_screen.dart';
import '../../../mapa/presentation/viewmodels/mapa_viewmodel.dart';
import '../../data/datasources/voluntario_remote_datasource.dart';
import '../viewmodels/voluntario_viewmodel.dart';
import 'detalle_incidente_screen.dart';
import 'incidente_en_curso_screen.dart';

/// El mismo mapa del ciudadano con acceso a atender casos de la organización.
class MapaVoluntarioScreen extends ConsumerStatefulWidget {
  const MapaVoluntarioScreen({super.key});
  @override
  ConsumerState<MapaVoluntarioScreen> createState() =>
      _MapaVoluntarioScreenState();
}

class _MapaVoluntarioScreenState extends ConsumerState<MapaVoluntarioScreen> {
  bool _abriendo = false;
  Future<void> _abrir(MarcadorMapaModel punto) async {
    if (_abriendo) return;
    setState(() => _abriendo = true);
    try {
      final remoto = VoluntarioRemoteDatasource(ref.read(apiClientProvider));
      final caso = punto.capa == 'reporte'
          ? await remoto.reporte(punto.id)
          : await remoto.solicitud(punto.id);
      final tareas = await ref.refresh(misTareasProvider.future);
      final propias = tareas.where((a) => punto.capa == 'reporte'
          ? a.reporteId == punto.id
          : a.solicitudId == punto.id);
      final asignacion =
          propias.isEmpty ? null : propias.first.conSolicitud(caso);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => asignacion != null
            ? IncidenteEnCursoScreen(asignacion: asignacion)
            : DetalleIncidenteScreen(solicitud: caso),
      ));
      if (mounted) await ref.read(mapaViewModelProvider.notifier).recargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ApiException.desde(e).mensaje)));
      }
    } finally {
      if (mounted) setState(() => _abriendo = false);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        MapaEmergenciaScreen(onAbrirCaso: _abrir),
        if (_abriendo)
          const Positioned.fill(
              child: AbsorbPointer(
                  child: ColoredBox(
            color: Color(0x33000000),
            child: Center(child: CircularProgressIndicator()),
          ))),
      ]);
}
