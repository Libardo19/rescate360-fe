import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/campo_password.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/contacto_emergencia_model.dart';
import '../viewmodels/perfil_viewmodel.dart';

/// Ley 1581 de 2012: conocer qué datos guarda RESCATE360 y pedir que se borren.
class PrivacidadDatosScreen extends ConsumerWidget {
  const PrivacidadDatosScreen({super.key});

  Future<void> _eliminarCuenta(BuildContext context, WidgetRef ref) async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _ConfirmarEliminacion(),
    );
    if (password == null || !context.mounted) return;
    final error = await ref.read(perfilViewModelProvider).eliminarCuenta(password);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.inicial, (_) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(misDatosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacidad y mis datos', style: AppTextStyles.h2), centerTitle: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text(
              'Según la Ley 1581 de 2012 puedes conocer, corregir y pedir que se borren tus datos personales.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 20),
            const Text('Lo que guardamos de ti', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            datos.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(ApiException.desde(e).mensaje, style: AppTextStyles.bodySecondary),
              data: (r) => _Resumen(resumen: r),
            ),
            const SizedBox(height: 28),
            const Text('Eliminar mi cuenta', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            const Text(
              'Se borran tu nombre, correo, teléfono, ubicación, contactos de emergencia y dispositivos, '
              'y no podrás volver a entrar. Las solicitudes y reportes que hiciste se conservan sin tus '
              'datos, porque pueden seguir sirviendo a la emergencia.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Eliminar mi cuenta',
              icon: Icons.delete_forever_outlined,
              outlined: true,
              onPressed: () => _eliminarCuenta(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final ResumenMisDatos resumen;

  const _Resumen({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final filas = [
      ('Perfil', 'Nombre, correo y teléfono'),
      ('Ubicación', resumen.tieneUbicacion ? 'Guardada (para alertas de tu zona)' : 'No guardada'),
      ('Autorizaciones', '${resumen.consentimientos}'),
      ('Contactos de emergencia', '${resumen.contactos}'),
      ('Dispositivos', '${resumen.dispositivos}'),
      ('Solicitudes de ayuda', '${resumen.solicitudes}'),
      ('Reportes', '${resumen.reportes}'),
      ('Personas reportadas', '${resumen.personasReportadas}'),
    ];
    return Column(
      children: [
        for (final (titulo, valor) in filas)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text(titulo, style: AppTextStyles.body)),
                Text(valor, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConfirmarEliminacion extends StatefulWidget {
  const _ConfirmarEliminacion();

  @override
  State<_ConfirmarEliminacion> createState() => _ConfirmarEliminacionState();
}

class _ConfirmarEliminacionState extends State<_ConfirmarEliminacion> {
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Eliminar tu cuenta?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Esta acción no se puede deshacer. Escribe tu contraseña para confirmar.'),
          const SizedBox(height: 12),
          CampoPassword(controlador: _passwordCtrl, hint: 'Contraseña'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            final password = _passwordCtrl.text;
            if (password.isNotEmpty) Navigator.of(context).pop(password);
          },
          child: const Text('Eliminar', style: TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }
}
