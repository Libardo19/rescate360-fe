import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/fila_opcion.dart';

/// Configuración (mockup 14).
class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  void _proximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuración', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            GrupoOpciones(
              filas: [
                FilaOpcion(
                  icono: Icons.notifications_none,
                  titulo: 'Notificaciones',
                  subtitulo: 'Alertas, reportes y actualizaciones',
                  onTap: () => Navigator.of(context).pushNamed('/notificaciones'),
                ),
                FilaOpcion(
                  icono: Icons.location_on_outlined,
                  titulo: 'Ubicación',
                  subtitulo: 'Permitir ubicación en la app',
                  onTap: () => _proximamente(context),
                ),
                FilaOpcion(
                  icono: Icons.dark_mode_outlined,
                  titulo: 'Tema oscuro',
                  // El tema oscuro aún no está disponible.
                  trailing: Switch(
                    value: false,
                    onChanged: (_) => _proximamente(context),
                  ),
                ),
                FilaOpcion(
                  icono: Icons.language,
                  titulo: 'Idioma',
                  subtitulo: 'Español',
                  onTap: () => _proximamente(context),
                ),
                FilaOpcion(
                  icono: Icons.lock_outline,
                  titulo: 'Privacidad',
                  subtitulo: 'Política de privacidad y datos',
                  onTap: () => _proximamente(context),
                ),
                FilaOpcion(
                  icono: Icons.description_outlined,
                  titulo: 'Términos y condiciones',
                  onTap: () => _proximamente(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
