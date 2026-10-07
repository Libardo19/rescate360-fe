import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/fila_opcion.dart';

class _Guia {
  final String titulo;
  final IconData icono;
  final Color color;
  final List<String> pasos;

  const _Guia({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.pasos,
  });
}

const List<_Guia> _guias = [
  _Guia(
    titulo: 'Terremoto',
    icono: Icons.vibration,
    color: AppColors.warning,
    pasos: [
      'Mantén la calma. No corras ni uses ascensores.',
      'Agáchate, cúbrete bajo una mesa resistente y sujétate.',
      'Aléjate de ventanas, espejos y objetos que puedan caer.',
      'Si estás afuera, aléjate de edificios, postes y cables.',
      'Al terminar, sal con cuidado, revisa si hay heridos y ten presente que pueden venir réplicas.',
    ],
  ),
  _Guia(
    titulo: 'Inundación',
    icono: Icons.water_drop_outlined,
    color: AppColors.info,
    pasos: [
      'Sube a un lugar alto sin esperar a que el agua suba.',
      'No cruces corrientes de agua a pie ni en vehículo.',
      'Si puedes hacerlo con seguridad, desconecta la electricidad y el gas.',
      'Aléjate de postes, cables caídos y alcantarillas.',
      'Sigue las indicaciones de las autoridades y no regreses hasta que lo autoricen.',
    ],
  ),
  _Guia(
    titulo: 'Incendio',
    icono: Icons.local_fire_department_outlined,
    color: AppColors.danger,
    pasos: [
      'Da la alarma y llama a emergencias.',
      'Si hay humo, agáchate y cúbrete nariz y boca con un paño, mejor si está húmedo.',
      'Antes de abrir una puerta, tócala con el dorso de la mano. Si está caliente, no la abras.',
      'Sal por la ruta de evacuación y no uses ascensores.',
      'Una vez afuera, no regreses por ningún motivo.',
    ],
  ),
  _Guia(
    titulo: 'Accidente',
    icono: Icons.directions_car_outlined,
    color: AppColors.accent,
    pasos: [
      'Detente en un lugar seguro y enciende las luces de emergencia.',
      'Llama a emergencias e indica tu ubicación exacta.',
      'No muevas a los heridos, salvo que haya peligro inmediato.',
      'Señaliza el lugar para evitar otro choque.',
      'Quédate en el sitio hasta que llegue la ayuda.',
    ],
  ),
  _Guia(
    titulo: 'Deslizamiento',
    icono: Icons.terrain,
    color: AppColors.textSecondary,
    pasos: [
      'Si notas grietas, árboles inclinados o ruido de rocas, aléjate de inmediato.',
      'Dirígete a terreno firme y alto, lejos de la ladera.',
      'No cruces la zona afectada ni regreses por tus pertenencias.',
      'Avisa a tus vecinos y a las autoridades.',
      'No vuelvas hasta que las autoridades lo permitan.',
    ],
  ),
  _Guia(
    titulo: 'Robo',
    icono: Icons.lock_outline,
    color: AppColors.primary,
    pasos: [
      'Mantén la calma y no opongas resistencia.',
      'Entrega lo que te pidan: tu vida vale más que tus cosas.',
      'Fíjate en detalles como el rostro, la ropa y hacia dónde huye.',
      'Cuando estés a salvo, llama a emergencias y haz el reporte.',
      'Si estás herido, busca atención médica.',
    ],
  ),
  _Guia(
    titulo: 'Emergencias médicas',
    icono: Icons.medical_services_outlined,
    color: AppColors.danger,
    pasos: [
      'Llama a emergencias y explica qué pasó y dónde estás.',
      'Revisa si la persona responde y respira.',
      'Si hay un sangrado, presiona con un paño limpio.',
      'Sigue las indicaciones de quien te atienda por teléfono.',
      'No muevas a la persona ni le des de comer o beber sin necesidad.',
    ],
  ),
];

/// Guía de emergencia (mockup 17).
class GuiaEmergenciaScreen extends StatelessWidget {
  const GuiaEmergenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Guía de emergencia', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text('Qué hacer en caso de:', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            GrupoOpciones(
              filas: _guias
                  .map(
                    (g) => FilaOpcion(
                      icono: g.icono,
                      titulo: g.titulo,
                      color: g.color,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _DetalleGuiaScreen(guia: g),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.textSecondary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Esta guía es orientativa. En una emergencia real, '
                      'llama primero a la línea 123.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetalleGuiaScreen extends StatelessWidget {
  final _Guia guia;

  const _DetalleGuiaScreen({required this.guia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(guia.titulo, style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: guia.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(guia.icono, color: guia.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text('Qué hacer en caso de ${guia.titulo.toLowerCase()}',
                      style: AppTextStyles.h2),
                ),
              ],
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < guia.pasos.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(guia.pasos[i], style: AppTextStyles.body),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
