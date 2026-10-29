import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../viewmodels/voluntario_viewmodel.dart';
import '../widgets/voluntario_ui.dart';
import 'estado_disponibilidad_screen.dart';

/// Inicio (dashboard) del voluntario, con los números reales del backend.
/// [onIrAPestana] cambia la pestaña de la barra inferior:
/// 1 Incidentes, 2 Mapa, 3 Asignaciones.
class InicioVoluntarioScreen extends ConsumerWidget {
  final ValueChanged<int> onIrAPestana;

  const InicioVoluntarioScreen({super.key, required this.onIrAPestana});

  Future<void> _refrescar(WidgetRef ref) async {
    ref.invalidate(casosOrganizacionProvider);
    ref.invalidate(misTareasProvider);
    try {
      await ref.read(casosOrganizacionProvider.future);
    } catch (_) {
      // Si falla, los tiles muestran "—" y se puede reintentar.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casos = ref.watch(casosOrganizacionProvider);
    final tareas = ref.watch(misTareasProvider);
    final ocultos = ref.watch(casosOcultosProvider);
    final disponibilidad = ref.watch(disponibilidadProvider);
    final nombre = ref.watch(authViewModelProvider).usuario?.primerNombre ?? '';

    final textoCasos = casos.when(
      data: (lista) => '${lista.where((c) => !ocultos.contains(c.id)).length}',
      loading: () => '…',
      error: (_, __) => '—',
    );
    final textoTareas = tareas.when(
      data: (lista) => '${lista.where((a) => a.estado == 'activa').length}',
      loading: () => '…',
      error: (_, __) => '—',
    );

    return Column(
      children: [
        _Encabezado(nombre: nombre, disponibilidad: disponibilidad),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refrescar(ref),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TarjetaEstado(
                    disponibilidad: disponibilidad,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EstadoDisponibilidadScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _TileResumen(
                          icono: Icons.warning_amber_rounded,
                          color: AppColors.danger,
                          titulo: 'Incidentes cercanos',
                          valor: textoCasos,
                          valorGrande: true,
                          onTap: () => onIrAPestana(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TileResumen(
                          icono: Icons.assignment_ind_outlined,
                          color: AppColors.info,
                          titulo: 'Mis asignaciones',
                          valor: textoTareas,
                          valorGrande: true,
                          onTap: () => onIrAPestana(3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TileResumen(
                          icono: Icons.map_outlined,
                          color: AppColors.success,
                          titulo: 'Mapa',
                          valor: 'Ver en mapa',
                          valorGrande: false,
                          onTap: () => onIrAPestana(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TileResumen(
                          icono: Icons.notifications_none,
                          color: AppColors.warning,
                          titulo: 'Notificaciones',
                          valor: 'Ver todas',
                          valorGrande: false,
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRouter.notificaciones),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  final String nombre;
  final EstadoDisponibilidad disponibilidad;

  const _Encabezado({required this.nombre, required this.disponibilidad});

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'V';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Text(
                  inicial,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre.isEmpty ? 'Hola' : 'Hola, $nombre',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // TODO: agregar la organización cuando el modelo del
                    // usuario la exponga ("Voluntario · Bomberos...").
                    const Text(
                      'Voluntario',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x24FFFFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: disponibilidad.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            disponibilidad.etiqueta,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaEstado extends StatelessWidget {
  final EstadoDisponibilidad disponibilidad;
  final VoidCallback onTap;

  const _TarjetaEstado({required this.disponibilidad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = disponibilidad.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(disponibilidad.icono, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estado actual', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    disponibilidad.etiqueta,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.expand_more, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TileResumen extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String valor;
  final bool valorGrande;
  final VoidCallback onTap;

  const _TileResumen({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.valor,
    required this.valorGrande,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: Material(
        color: AppColors.background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono, color: color, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  valor,
                  style: valorGrande
                      ? const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        )
                      : TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
