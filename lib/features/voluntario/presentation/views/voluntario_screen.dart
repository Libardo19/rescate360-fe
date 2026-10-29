import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../perfil/presentation/views/mas_screen.dart';
import 'asignaciones_voluntario_screen.dart';
import 'incidentes_voluntario_screen.dart';
import 'inicio_voluntario_screen.dart';
import 'mapa_voluntario_screen.dart';

/// Contenedor principal del voluntario: barra inferior con Inicio,
/// Incidentes, Mapa, Asignaciones y Más (mockups del voluntario).
class VoluntarioScreen extends StatefulWidget {
  const VoluntarioScreen({super.key});

  @override
  State<VoluntarioScreen> createState() => _VoluntarioScreenState();
}

class _VoluntarioScreenState extends State<VoluntarioScreen> {
  int _indice = 0;

  // Las pestañas se construyen la primera vez que se visitan.
  final Set<int> _visitadas = {0};

  void _irA(int indice) {
    setState(() {
      _indice = indice;
      _visitadas.add(indice);
    });
  }

  Widget _pagina(int indice) => switch (indice) {
        0 => InicioVoluntarioScreen(onIrAPestana: _irA),
        1 => const IncidentesVoluntarioScreen(),
        2 => const MapaVoluntarioScreen(),
        3 => const AsignacionesVoluntarioScreen(),
        _ => const MasScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _indice,
        children: List.generate(
          5,
          (i) => _visitadas.contains(i) ? _pagina(i) : const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _indice,
          onTap: _irA,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_outlined),
              activeIcon: Icon(Icons.warning_amber_rounded),
              label: 'Incidentes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Asignaciones',
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
