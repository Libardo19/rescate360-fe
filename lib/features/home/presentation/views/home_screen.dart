import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/models/resumen_inicio_model.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/accesos_rapidos_grid.dart';
import '../widgets/alertas_recientes_list.dart';

/// Pantalla principal (Home), fiel al mockup 2.
/// La tarjeta roja de "Alerta sísmica" es CONDICIONAL: solo se dibuja si
/// [HomeState.alertaActiva] no es nula. Por defecto está oculta, ya que
/// solo debe aparecer cuando exista una alerta real en curso.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _navIndex = 0);
      return;
    }
    // TODO: conectar Mapa, Reportes y Más cuando esas pantallas existan.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disponible próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final usuario = ref.watch(authViewModelProvider).usuario;
    final nombre = usuario?.primerNombre ?? 'Oscar';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola, $nombre', style: AppTextStyles.h1),
                      const SizedBox(height: 2),
                      const Text('Estamos aquí para ayudarte.',
                          style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.textPrimary, size: 20),
                ),
              ],
            ),

            // Alerta destacada: solo si hay una alerta real activa.
            if (homeState.alertaActiva != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(homeState.alertaActiva!.titulo,
                              style: AppTextStyles.body
                                  .copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(homeState.alertaActiva!.descripcion,
                              style: AppTextStyles.body
                                  .copyWith(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.error_rounded, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Text('Accesos rápidos', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            AccesosRapidosGrid(
              items: HomeViewModel.accesosRapidos,
              onTap: (acceso) {
                // TODO: navegar a acceso.ruta cuando esa pantalla exista.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${acceso.label} — próximamente')),
                );
              },
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Alertas recientes', style: AppTextStyles.h2),
                GestureDetector(
                  onTap: () {
                    // TODO: navegar al listado completo de alertas cuando exista.
                  },
                  child: const Text('Ver todas', style: AppTextStyles.link),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AlertasRecientesList(
              alertas: homeState.alertasRecientes,
              onTap: (AlertaReciente alerta) {
                // TODO: navegar al detalle de la alerta cuando exista.
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
    );
  }
}
