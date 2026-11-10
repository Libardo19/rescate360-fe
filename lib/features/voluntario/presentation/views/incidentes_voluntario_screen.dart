import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/pestanas_segmentadas.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../../data/models/asignacion_model.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../viewmodels/voluntario_viewmodel.dart';
import '../widgets/mensaje_lista.dart';
import '../widgets/tarjeta_incidente.dart';
import '../widgets/voluntario_ui.dart';
import 'detalle_incidente_screen.dart';
import 'incidente_en_curso_screen.dart';

enum _OrdenLista { prioridad, cercania, recientes }

extension on _OrdenLista {
  String get etiqueta => switch (this) {
        _OrdenLista.prioridad => 'Mayor prioridad',
        _OrdenLista.cercania => 'Más cercanos',
        _OrdenLista.recientes => 'Más recientes',
      };

  IconData get icono => switch (this) {
        _OrdenLista.prioridad => Icons.priority_high,
        _OrdenLista.cercania => Icons.near_me_outlined,
        _OrdenLista.recientes => Icons.schedule,
      };
}

/// Incidentes cercanos (mockup 4): casos abiertos de la organización y los
/// que el voluntario ya tiene asignados.
class IncidentesVoluntarioScreen extends ConsumerStatefulWidget {
  const IncidentesVoluntarioScreen({super.key});

  @override
  ConsumerState<IncidentesVoluntarioScreen> createState() =>
      _IncidentesVoluntarioScreenState();
}

class _IncidentesVoluntarioScreenState
    extends ConsumerState<IncidentesVoluntarioScreen> {
  int _pestana = 0;
  _OrdenLista _orden = _OrdenLista.prioridad;

  Future<void> _refrescar() async {
    try {
      await Future.wait([
        ref.refresh(casosOrganizacionProvider.future),
        ref.refresh(misTareasProvider.future),
      ]);
    } catch (_) {
      // Los errores ya se muestran en cada pestaña con su botón de reintentar.
    }
  }

  Future<void> _elegirOrden() async {
    final elegido = await showModalBottomSheet<_OrdenLista>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Ordenar por', style: AppTextStyles.h2),
              ),
            ),
            for (final opcion in _OrdenLista.values)
              ListTile(
                leading: Icon(
                  opcion.icono,
                  color: opcion == _orden
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                title: Text(opcion.etiqueta),
                trailing: opcion == _orden
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(ctx).pop(opcion),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (elegido != null && mounted) setState(() => _orden = elegido);
  }

  List<SolicitudAyudaModel> _ordenados(
    List<SolicitudAyudaModel> lista,
    Position? posicion,
  ) {
    final copia = [...lista];
    copia.sort((a, b) {
      switch (_orden) {
        case _OrdenLista.cercania:
          final da = a.distanciaKm(posicion) ?? double.infinity;
          final db = b.distanciaKm(posicion) ?? double.infinity;
          final porDistancia = da.compareTo(db);
          if (porDistancia != 0) return porDistancia;
          break;
        case _OrdenLista.recientes:
          return b.creadoEn.compareTo(a.creadoEn);
        case _OrdenLista.prioridad:
          final porPrioridad = a.nivel.index.compareTo(b.nivel.index);
          if (porPrioridad != 0) return porPrioridad;
      }
      return b.creadoEn.compareTo(a.creadoEn);
    });
    return copia;
  }

  void _abrirDetalle(
    SolicitudAyudaModel solicitud, {
    AsignacionModel? asignacion,
  }) {
    final activa = asignacion != null && asignacion.estado == 'activa';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => activa
            ? IncidenteEnCursoScreen(asignacion: asignacion)
            : DetalleIncidenteScreen(
                solicitud: solicitud,
                asignacion: asignacion,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final casos = ref.watch(casosOrganizacionProvider);
    final tareas = ref.watch(misTareasProvider);
    final ocultos = ref.watch(casosOcultosProvider);
    final posicion = ref.watch(miUbicacionProvider).valueOrNull;

    final activas = tareas.valueOrNull ?? const <AsignacionModel>[];
    final porSolicitud = <String, AsignacionModel>{
      for (final a in activas)
        if (a.solicitudId != null) a.solicitudId!: a,
    };

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 2),
            child: Text('Incidentes cercanos', style: AppTextStyles.h1),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Text(
              'Casos abiertos de tu organización',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: PestanasSegmentadas(
                    etiquetas: const ['Todos', 'Cercanos', 'Asignados'],
                    indice: _pestana,
                    onCambiar: (i) => setState(() => _pestana = i),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _elegirOrden,
                  tooltip: 'Ordenar',
                  icon: const Icon(Icons.tune, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _pestana == 2
                ? _listaAsignados(tareas, posicion)
                : _listaCasos(casos, ocultos, porSolicitud, posicion),
          ),
        ],
      ),
    );
  }

  Widget _listaCasos(
    AsyncValue<List<SolicitudAyudaModel>> casos,
    Set<String> ocultos,
    Map<String, AsignacionModel> porSolicitud,
    Position? posicion,
  ) {
    return casos.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => MensajeLista(
        icono: Icons.cloud_off,
        texto: 'No se pudieron cargar los casos. Desliza hacia abajo para '
            'reintentar.',
        onReintentar: () async {
          ref.invalidate(casosOrganizacionProvider);
        },
      ),
      data: (lista) {
        var visibles = lista.where((s) {
          if (ocultos.contains(s.id)) return false;
          // Un caso ya en proceso solo interesa si es mío.
          return s.estado == 'pendiente' || porSolicitud.containsKey(s.id);
        }).toList();

        if (_pestana == 1) {
          visibles = visibles.where((s) {
            final km = s.distanciaKm(posicion);
            return km != null && km <= 5;
          }).toList();
        }
        final ordenados = _ordenados(visibles, posicion);

        if (ordenados.isEmpty) {
          return MensajeLista(
            icono: _pestana == 1
                ? Icons.near_me_disabled_outlined
                : Icons.inbox_outlined,
            texto: _pestana == 1
                ? (posicion == null
                    ? 'Activa la ubicación para ver los casos a menos de 5 km.'
                    : 'No hay casos a menos de 5 km de tu ubicación.')
                : 'No hay casos abiertos en tu organización.',
            onReintentar: _refrescar,
          );
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: ordenados.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final s = ordenados[i];
              final asignacion = porSolicitud[s.id];
              final esNuevo =
                  DateTime.now().difference(s.creadoEn).inMinutes < 30;
              return TarjetaIncidente(
                solicitud: s,
                distancia: textoDistancia(s.distanciaKm(posicion)),
                etiqueta: asignacion != null
                    ? 'En curso'
                    : esNuevo
                        ? 'Nuevo'
                        : null,
                etiquetaColor:
                    asignacion != null ? AppColors.warning : AppColors.danger,
                pie: asignacion != null
                    ? 'Asignada ${textoHace(asignacion.asignadoEn).toLowerCase()}'
                    : s.haceCuanto,
                onTap: () => _abrirDetalle(s, asignacion: asignacion),
              );
            },
          ),
        );
      },
    );
  }

  Widget _listaAsignados(
    AsyncValue<List<AsignacionModel>> tareas,
    Position? posicion,
  ) {
    return tareas.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => MensajeLista(
        icono: Icons.cloud_off,
        texto: 'No se pudieron cargar tus asignaciones. Desliza hacia abajo '
            'para reintentar.',
        onReintentar: () async {
          ref.invalidate(misTareasProvider);
        },
      ),
      data: (lista) {
        final conSolicitud = lista.where((a) => a.solicitud != null).toList();
        if (conSolicitud.isEmpty) {
          return MensajeLista(
            icono: Icons.assignment_outlined,
            texto: 'Todavía no has tomado ningún caso. Abre uno en "Todos" y '
                'toca "Tomar caso".',
            onReintentar: _refrescar,
          );
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: conSolicitud.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final a = conSolicitud[i];
              final s = a.solicitud!;
              return TarjetaIncidente(
                solicitud: s,
                distancia: textoDistancia(s.distanciaKm(posicion)),
                etiqueta: 'En curso',
                etiquetaColor: AppColors.warning,
                pie: 'Asignada ${textoHace(a.asignadoEn).toLowerCase()}',
                onTap: () => _abrirDetalle(s, asignacion: a),
              );
            },
          ),
        );
      },
    );
  }
}
