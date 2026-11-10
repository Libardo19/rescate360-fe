import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../check_in/presentation/widgets/vigilante_check_in.dart';
import '../../../perfil/presentation/views/mas_screen.dart';
import '../widgets/barra_voluntario.dart';
import 'asignaciones_voluntario_screen.dart';
import 'incidentes_voluntario_screen.dart';
import 'inicio_voluntario_screen.dart';
import 'mapa_voluntario_screen.dart';

/// Contenedor principal del voluntario: barra inferior con Inicio,
/// Incidentes, Mapa (botón central), Asignaciones y Más (mockups del voluntario).
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
    return VigilanteCheckIn(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _indice,
          children: List.generate(
            5,
            (i) =>
                _visitadas.contains(i) ? _pagina(i) : const SizedBox.shrink(),
          ),
        ),
        bottomNavigationBar: BarraVoluntario(indice: _indice, onTap: _irA),
      ),
    );
  }
}
