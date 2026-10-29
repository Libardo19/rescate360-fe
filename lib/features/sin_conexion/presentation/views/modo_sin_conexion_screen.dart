import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/sin_conexion_viewmodel.dart';

/// Modo sin conexión: relevo por Bluetooth y cola de mensajes que esperan internet.
class ModoSinConexionScreen extends ConsumerWidget {
  const ModoSinConexionScreen({super.key});

  Future<void> _cambiarRelevo(BuildContext context, WidgetRef ref, bool activar) async {
    final vm = ref.read(sinConexionProvider.notifier);
    if (!activar) {
      await vm.desactivarRelevo();
      return;
    }
    final error = await vm.activarRelevo();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(sinConexionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Modo sin conexión', style: AppTextStyles.h2), centerTitle: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'Si no tienes internet, tu SOS o tu respuesta a "¿Estás bien?" se guardan firmados en el teléfono '
              'y pasan por Bluetooth a otros teléfonos cercanos con RESCATE360. El primero que tenga '
              'internet los entrega, aunque no sean suyos.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: estado.relevoActivo,
              activeThumbColor: AppColors.primary,
              title: const Text('Ayudar a pasar mensajes por Bluetooth', style: AppTextStyles.body),
              subtitle: const Text(
                'Mientras esté activo, el teléfono busca a otros cercanos. Gasta batería.',
                style: AppTextStyles.caption,
              ),
              onChanged: (valor) => _cambiarRelevo(context, ref, valor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.outbox_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Mensajes esperando internet: ${estado.enCola}', style: AppTextStyles.body),
                ),
              ],
            ),
            if (estado.aviso != null) ...[
              const SizedBox(height: 8),
              Text(estado.aviso!, style: AppTextStyles.caption),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Entregar ahora',
              icon: Icons.sync,
              outlined: true,
              onPressed: () => ref.read(sinConexionProvider.notifier).sincronizar(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Prueba de concepto: funciona solo entre teléfonos Android, a unos 10-100 m por salto, y los '
              'teléfonos intermedios deben tener la app abierta con este modo activo.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
