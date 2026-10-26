import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../mapa/presentation/views/mapa_emergencia_screen.dart';
import '../../../perfil/presentation/views/mas_screen.dart';
import '../../../reportes/presentation/views/mis_reportes_screen.dart';
import 'home_screen.dart';

/// Contenedor principal del ciudadano: barra de navegación inferior con
/// Inicio, Mapa, Reportes y Más. Es el destino de la ruta '/home'.
class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _indice = 0;

  // Las pestañas se construyen la primera vez que se visitan.
  final Set<int> _visitadas = {0};

  Widget _construirPagina(int i) {
    switch (i) {
      case 0:
        return const HomeScreen();
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
    return Scaffold(
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Reportes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}
