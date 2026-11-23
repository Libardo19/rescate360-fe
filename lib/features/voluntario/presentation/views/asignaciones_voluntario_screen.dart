import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../widgets/encabezado_casos.dart';
import '../../data/models/asignacion_model.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../viewmodels/voluntario_viewmodel.dart';
import '../widgets/mensaje_lista.dart';
import '../widgets/tarjeta_incidente.dart';
import '../widgets/voluntario_ui.dart';
import 'detalle_incidente_screen.dart';
import 'incidente_en_curso_screen.dart';

/// Mis asignaciones (mockup 6): casos activos e historial de los cerrados.
class AsignacionesVoluntarioScreen extends ConsumerStatefulWidget {
  const AsignacionesVoluntarioScreen({super.key});

  @override
  ConsumerState<AsignacionesVoluntarioScreen> createState() =>
      _AsignacionesVoluntarioScreenState();
}

class _AsignacionesVoluntarioScreenState
    extends ConsumerState<AsignacionesVoluntarioScreen> {
  int _pestana = 0;
  int _filtroHistorial = 0;

  Future<void> _refrescar() async {
    try {
      await Future.wait([
        ref.refresh(misTareasProvider.future),
        ref.refresh(historialTareasProvider.future),
      ]);
    } catch (_) {
      // Las pestañas muestran su propio error y botón de reintentar.
    }
  }

  void _abrirDetalle(AsignacionModel asignacion) {
    final solicitud = asignacion.solicitud;
    if (solicitud == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => asignacion.estado == 'activa'
            ? IncidenteEnCursoScreen(asignacion: asignacion)
            : DetalleIncidenteScreen(
                solicitud: solicitud,
                asignacion: asignacion,
              ),
      ),
    );
  }

  Future<void> _cerrar(AsignacionModel asignacion,
      {required bool atendida}) async {
    final mensajero = ScaffoldMessenger.of(context);
    final vm = ref.read(voluntarioViewModelProvider);
    final error = atendida
        ? await vm.finalizar(asignacion.id)
        : await vm.soltar(asignacion.id);
    if (!mounted) return;
    mensajero.showSnackBar(SnackBar(
      content:
          Text(error ?? (atendida ? 'Caso atendido.' : 'Soltaste el caso.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tareas = ref.watch(misTareasProvider);
    final historial = ref.watch(historialTareasProvider);
    final posicion = ref.watch(miUbicacionProvider).valueOrNull;
    final activas = tareas.valueOrNull?.length;
    final cerradas = historial.valueOrNull?.length;

    final atendidas =
        historial.valueOrNull?.where((a) => a.estado == 'finalizada').length;
    return ColoredBox(
        color: const Color(0xFFF5F7FC),
        child: Column(children: [
          EncabezadoCasos(
            titulo: 'Mis asignaciones',
            subtitulo: 'Cada caso atendido cuenta',
            cifras: [
              (
                valor: activas,
                etiqueta: 'En curso',
                icono: Icons.route_rounded
              ),
              (
                valor: atendidas,
                etiqueta: 'Atendidas',
                icono: Icons.task_alt_rounded
              ),
              (
                valor: cerradas,
                etiqueta: 'Historial',
                icono: Icons.history_rounded
              ),
            ],
            etiquetas: const ['En curso', 'Historial'],
            indice: _pestana,
            onCambiar: (i) => setState(() => _pestana = i),
          ),
          if (_pestana == 1)
            SizedBox(
                height: 60,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ChoiceChip(
                    label: Text(const ['Todas', 'Atendidas', 'Canceladas'][i]),
                    selected: _filtroHistorial == i,
                    onSelected: (_) => setState(() => _filtroHistorial = i),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                        color: _filtroHistorial == i
                            ? Colors.white
                            : AppColors.textSecondary),
                  ),
                ))
          else
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(children: [
                  Icon(Icons.assignment_ind_outlined,
                      size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Continúa la atención de tus casos',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13))),
                ])),
          Expanded(
              child: _pestana == 0
                  ? _listaActivas(tareas, posicion)
                  : _listaHistorial(historial, posicion)),
        ]));
  }

  Widget _listaActivas(
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
        if (lista.isEmpty) {
          return MensajeLista(
            icono: Icons.assignment_outlined,
            texto: 'No tienes casos activos. Toma uno en "Incidentes".',
            onReintentar: _refrescar,
          );
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final a = lista[i];
              final s = a.solicitud;
              if (s == null) return _tareaDeReporte(a, activa: true);
              return TarjetaIncidente(
                solicitud: s,
                distancia: textoDistancia(s.distanciaKm(posicion)),
                etiqueta: 'En curso',
                etiquetaColor: AppColors.warning,
                pie: 'Asignada ${textoHace(a.asignadoEn).toLowerCase()}',
                onTap: () => _abrirDetalle(a),
              );
            },
          ),
        );
      },
    );
  }

  Widget _listaHistorial(
    AsyncValue<List<AsignacionModel>> historial,
    Position? posicion,
  ) {
    return historial.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => MensajeLista(
        icono: Icons.cloud_off,
        texto: 'No se pudo cargar el historial. Desliza hacia abajo para '
            'reintentar.',
        onReintentar: () async {
          ref.invalidate(historialTareasProvider);
        },
      ),
      data: (todas) {
        final lista = todas
            .where((a) =>
                _filtroHistorial == 0 ||
                (_filtroHistorial == 1
                    ? a.estado == 'finalizada'
                    : a.estado == 'cancelada'))
            .toList();
        if (lista.isEmpty) {
          return MensajeLista(
            icono: Icons.history,
            texto: 'Todavía no has cerrado ninguna asignación.',
            onReintentar: _refrescar,
          );
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final a = lista[i];
              final s = a.solicitud;
              final atendida = a.estado == 'finalizada';
              if (s == null) return _tareaDeReporte(a, activa: false);
              return TarjetaIncidente(
                solicitud: s,
                distancia: textoDistancia(s.distanciaKm(posicion)),
                etiqueta: atendida ? 'Atendida' : 'Cancelada',
                etiquetaColor:
                    atendida ? AppColors.success : AppColors.textMuted,
                pie:
                    'Cerrada ${textoHace(a.cerradaEn ?? a.asignadoEn).toLowerCase()}',
                onTap: () => _abrirDetalle(a),
              );
            },
          ),
        );
      },
    );
  }

  /// Asignaciones sobre reportes: el backend no adjunta una solicitud.
  Widget _tareaDeReporte(AsignacionModel a, {required bool activa}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.info),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Reporte asignado',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              EtiquetaEstado(
                texto: activa
                    ? 'En curso'
                    : a.estado == 'finalizada'
                        ? 'Atendida'
                        : 'Cancelada',
                color: activa
                    ? AppColors.warning
                    : a.estado == 'finalizada'
                        ? AppColors.success
                        : AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            activa
                ? 'Asignada ${textoHace(a.asignadoEn).toLowerCase()}'
                : 'Cerrada ${textoHace(a.cerradaEn ?? a.asignadoEn).toLowerCase()}',
            style: AppTextStyles.caption,
          ),
          if (activa) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _cerrar(a, atendida: false),
                  child: const Text('Soltar',
                      style: TextStyle(color: AppColors.danger)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success),
                  onPressed: () => _cerrar(a, atendida: true),
                  child: const Text('Atendido'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
