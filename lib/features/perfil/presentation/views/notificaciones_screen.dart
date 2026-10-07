import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/fila_opcion.dart';

/// Preferencias de notificaciones (mockup 15). Por ahora no se guardan.
class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  // TODO: leer y guardar estas preferencias en el backend.
  final Map<String, bool> _valores = {
    'comunidad': true,
    'reportes': true,
    'solicitudes': true,
    'importantes': true,
  };

  Widget _fila(String clave, IconData icono, String titulo, String subtitulo) {
    return FilaOpcion(
      icono: icono,
      titulo: titulo,
      subtitulo: subtitulo,
      trailing: Switch(
        value: _valores[clave] ?? false,
        onChanged: (v) => setState(() => _valores[clave] = v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificaciones', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            GrupoOpciones(
              filas: [
                _fila('comunidad', Icons.groups_outlined,
                    'Alertas de la comunidad',
                    'Incidentes, zonas de riesgo, etc.'),
                _fila('reportes', Icons.assignment_outlined, 'Mis reportes',
                    'Cambios de estado y actualizaciones'),
                _fila('solicitudes', Icons.volunteer_activism_outlined,
                    'Solicitudes de ayuda', 'Cerca de mi ubicación'),
                _fila('importantes', Icons.campaign_outlined,
                    'Mensajes importantes', 'Comunicados de autoridades'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
