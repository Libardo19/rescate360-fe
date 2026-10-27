import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/i18n/textos.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/fila_opcion.dart';
import '../viewmodels/ajustes_viewmodel.dart';

/// Preferencias de notificaciones. Se guardan en el celular.
class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  Widget _fila(
    BuildContext context,
    WidgetRef ref,
    Ajustes ajustes,
    String clave,
    IconData icono,
  ) {
    return FilaOpcion(
      icono: icono,
      titulo: context.t('not_$clave'),
      subtitulo: context.t('not_${clave}_sub'),
      trailing: Switch(
        value: ajustes.notificaciones[clave] ?? true,
        onChanged: (valor) => ref
            .read(ajustesProvider.notifier)
            .cambiarNotificacion(clave, valor),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ajustes = ref.watch(ajustesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.t('not_titulo'), style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            GrupoOpciones(
              filas: [
                _fila(
                    context, ref, ajustes, 'comunidad', Icons.groups_outlined),
                _fila(context, ref, ajustes, 'reportes',
                    Icons.assignment_outlined),
                _fila(context, ref, ajustes, 'solicitudes',
                    Icons.volunteer_activism_outlined),
                _fila(context, ref, ajustes, 'importantes',
                    Icons.campaign_outlined),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.t('not_aviso'),
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
