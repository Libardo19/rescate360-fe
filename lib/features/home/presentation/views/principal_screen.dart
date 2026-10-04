import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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

  // Mapa, Reportes y Más se reemplazan por sus vistas reales conforme
  // se vayan construyendo.
  final List<Widget> _paginas = const [
    HomeScreen(),
    _PaginaPendiente(titulo: 'Mapa'),
    _PaginaPendiente(titulo: 'Reportes'),
    _PaginaPendiente(titulo: 'Más'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _indice, children: _paginas),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _indice,
          onTap: (i) => setState(() => _indice = i),
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

class _PaginaPendiente extends StatelessWidget {
  final String titulo;
  const _PaginaPendiente({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titulo, style: AppTextStyles.h1),
            const SizedBox(height: 6),
            const Text('Próximamente', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}
