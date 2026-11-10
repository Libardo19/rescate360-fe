import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../check_in/presentation/widgets/vigilante_check_in.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../mapa/presentation/views/mapa_emergencia_screen.dart';
import '../../../perfil/presentation/views/mas_screen.dart';
import '../../../reportes/presentation/views/mis_reportes_screen.dart';
import '../widgets/barra_ciudadano.dart';
import 'home_screen.dart';

/// Contenedor principal del ciudadano: barra de navegación inferior con
/// Inicio, Mapa, Reportes y Más. Es el destino de la ruta '/home'.
class PrincipalScreen extends ConsumerStatefulWidget {
  const PrincipalScreen({super.key});

  @override
  ConsumerState<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends ConsumerState<PrincipalScreen> {
  int _indice = 0;

  // Las pestañas se construyen la primera vez que se visitan.
  final Set<int> _visitadas = {0};

  void _irA(int i) => setState(() {
        _indice = i;
        _visitadas.add(i);
      });

  Widget _construirPagina(int i) {
    switch (i) {
      case 0:
        final nombre =
            ref.watch(authViewModelProvider).usuario?.primerNombre ?? 'Usuario';
        return HomeScreen(
          nombreUsuario: nombre,
          onAbrirMapa: () => _irA(BarraCiudadano.indiceMapa),
        );
      case 1:
        return const MapaEmergenciaScreen();
      case 2:
        return const ReportesScreen();
      default:
        return const MasScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VigilanteCheckIn(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _indice,
          children: List.generate(
            4,
            (i) => _visitadas.contains(i)
                ? _construirPagina(i)
                : const SizedBox.shrink(),
          ),
        ),
        bottomNavigationBar: BarraCiudadano(indice: _indice, onTap: _irA),
      ),
    );
  }
}
