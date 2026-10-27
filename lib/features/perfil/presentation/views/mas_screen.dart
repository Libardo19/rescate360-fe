import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/fila_opcion.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

/// Pestaña "Más": perfil, acceso a SOS y al resto de módulos (mockups 12 a 18).
class MasScreen extends ConsumerWidget {
  const MasScreen({super.key});

  void _ir(BuildContext context, String ruta) {
    Navigator.of(context).pushNamed(ruta);
  }

  void _proximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente')),
    );
  }

  Future<void> _cerrarSesion(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      // Borra los tokens; app.dart escucha el cambio y vuelve a la bienvenida
      await ref.read(authViewModelProvider.notifier).cerrarSesion();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authViewModelProvider).usuario;
    final nombreUsuario = usuario?.nombre ?? 'Usuario';
    final inicial =
        nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombreUsuario, style: AppTextStyles.h1),
                      const SizedBox(height: 2),
                      Text(usuario?.rol.etiqueta ?? 'Ciudadano',
                          style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Material(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _ir(context, '/sos'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 26),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'SOS · Pedir ayuda urgente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GrupoOpciones(
              filas: [
                FilaOpcion(
                  icono: Icons.person_outline,
                  titulo: 'Mis datos',
                  onTap: () => _proximamente(context),
                ),
                FilaOpcion(
                  icono: Icons.support_agent,
                  titulo: 'Mis solicitudes de ayuda',
                  onTap: () => _ir(context, '/mis-solicitudes'),
                ),
                FilaOpcion(
                  icono: Icons.contacts_outlined,
                  titulo: 'Contactos de emergencia',
                  onTap: () => _ir(context, '/contactos-emergencia'),
                ),
                FilaOpcion(
                  icono: Icons.local_hospital_outlined,
                  titulo: 'Centros de ayuda',
                  color: AppColors.info,
                  onTap: () => _ir(context, '/centros-ayuda'),
                ),
                FilaOpcion(
                  icono: Icons.menu_book_outlined,
                  titulo: 'Guía de emergencia',
                  color: AppColors.warning,
                  onTap: () => _ir(context, '/guia-emergencia'),
                ),
                FilaOpcion(
                  icono: Icons.volunteer_activism_outlined,
                  titulo: 'Donaciones',
                  color: AppColors.danger,
                  onTap: () => _ir(context, '/donaciones'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GrupoOpciones(
              filas: [
                FilaOpcion(
                  icono: Icons.notifications_none,
                  titulo: 'Notificaciones',
                  onTap: () => _ir(context, '/notificaciones'),
                ),
                FilaOpcion(
                  icono: Icons.settings_outlined,
                  titulo: 'Configuración',
                  onTap: () => _ir(context, '/configuracion'),
                ),
                FilaOpcion(
                  icono: Icons.help_outline,
                  titulo: 'Ayuda y soporte',
                  onTap: () => _proximamente(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger, width: 1.2),
              ),
              onPressed: () => _cerrarSesion(context, ref),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
