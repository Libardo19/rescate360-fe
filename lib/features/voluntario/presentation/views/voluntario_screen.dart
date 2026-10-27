import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../mapa/presentation/views/mapa_emergencia_screen.dart';
import '../../../perfil/presentation/views/mas_screen.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../viewmodels/voluntario_viewmodel.dart';

/// Inicio del voluntario: casos de su organización, sus tareas, el mapa y "Más".
/// Misma estructura de navegación que la del ciudadano (PrincipalScreen).
class VoluntarioScreen extends ConsumerStatefulWidget {
  const VoluntarioScreen({super.key});

  @override
  ConsumerState<VoluntarioScreen> createState() => _VoluntarioScreenState();
}

class _VoluntarioScreenState extends ConsumerState<VoluntarioScreen> {
  int _indice = 0;
  final Set<int> _visitadas = {0};

  Widget _pagina(int i) => switch (i) {
        0 => const _CasosTab(),
        1 => const _TareasTab(),
        2 => const MapaEmergenciaScreen(),
        _ => const MasScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _indice,
        children: List.generate(4, (i) => _visitadas.contains(i) ? _pagina(i) : const SizedBox.shrink()),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.surfaceBorder))),
        child: BottomNavigationBar(
          currentIndex: _indice,
          onTap: (i) => setState(() {
            _indice = i;
            _visitadas.add(i);
          }),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), activeIcon: Icon(Icons.inbox), label: 'Casos'),
            BottomNavigationBarItem(
                icon: Icon(Icons.task_alt_outlined), activeIcon: Icon(Icons.task_alt), label: 'Mis tareas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Mapa'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Más'),
          ],
        ),
      ),
    );
  }
}

void _avisar(BuildContext context, String? error, String ok) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? ok)));
}

const _colorPrioridad = {
  'critica': AppColors.danger,
  'alta': AppColors.danger,
  'media': AppColors.warning,
  'baja': AppColors.success,
  'pendiente': AppColors.textMuted,
};

/// Tarjeta de una solicitud de ayuda (casos y tareas)
class _TarjetaSolicitud extends StatelessWidget {
  final SolicitudAyudaModel solicitud;
  final List<Widget> acciones;

  const _TarjetaSolicitud({required this.solicitud, required this.acciones});

  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final color = _colorPrioridad[s.prioridad] ?? AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.esSos ? AppColors.danger : AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(s.esSos ? Icons.sos : Icons.support_agent, color: s.esSos ? AppColors.danger : AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(s.titulo, style: AppTextStyles.body)),
              EtiquetaEstado(texto: s.prioridad == 'pendiente' ? 'Sin clasificar' : s.prioridad, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(s.descripcion, style: AppTextStyles.bodySecondary, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(s.direccion ?? '${s.lat.toStringAsFixed(4)}, ${s.lng.toStringAsFixed(4)} · ${s.estadoEtiqueta}',
              style: AppTextStyles.caption),
          if (acciones.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: acciones),
          ],
        ],
      ),
    );
  }
}

Widget _vacio(String texto) => ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Text(texto, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
        ),
      ],
    );

/// Casos abiertos de la organización: el voluntario toma los que va a atender.
class _CasosTab extends ConsumerWidget {
  const _CasosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casos = ref.watch(casosOrganizacionProvider);
    final nombre = ref.watch(authViewModelProvider).usuario?.primerNombre ?? '';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text('Hola, $nombre', style: AppTextStyles.h1),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text('Casos abiertos de tu organización', style: AppTextStyles.bodySecondary),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(casosOrganizacionProvider.future),
              child: casos.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _vacio('No se pudieron cargar los casos. Desliza hacia abajo para reintentar.'),
                data: (lista) => lista.isEmpty
                    ? _vacio('No hay casos abiertos en tu organización.')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _TarjetaSolicitud(
                          solicitud: lista[i],
                          acciones: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                              onPressed: () async {
                                final error = await ref.read(voluntarioViewModelProvider).tomar(lista[i].id);
                                if (context.mounted) _avisar(context, error, 'Caso tomado: está en "Mis tareas".');
                              },
                              icon: const Icon(Icons.pan_tool_alt_outlined, size: 18),
                              label: const Text('Tomar caso'),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lo que el voluntario tomó: lo finaliza (atendido) o lo suelta.
class _TareasTab extends ConsumerWidget {
  const _TareasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tareas = ref.watch(misTareasProvider);
    final vm = ref.read(voluntarioViewModelProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Mis tareas', style: AppTextStyles.h1),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(misTareasProvider.future),
              child: tareas.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _vacio('No se pudieron cargar tus tareas. Desliza hacia abajo para reintentar.'),
                data: (lista) => lista.isEmpty
                    ? _vacio('No tienes tareas activas. Toma un caso en la pestaña "Casos".')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final tarea = lista[i];
                          final acciones = [
                            TextButton(
                              onPressed: () async {
                                final error = await vm.soltar(tarea.id);
                                if (context.mounted) _avisar(context, error, 'Soltaste el caso.');
                              },
                              child: const Text('Soltar', style: TextStyle(color: AppColors.danger)),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                              onPressed: () async {
                                final error = await vm.finalizar(tarea.id);
                                if (context.mounted) _avisar(context, error, 'Caso marcado como atendido.');
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Atendido'),
                            ),
                          ];
                          final solicitud = tarea.solicitud;
                          if (solicitud != null) return _TarjetaSolicitud(solicitud: solicitud, acciones: acciones);
                          return ListTile(
                            tileColor: AppColors.surface,
                            title: Text(tarea.reporteId != null ? 'Reporte asignado' : 'Tarea asignada'),
                            subtitle: Row(children: acciones),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
