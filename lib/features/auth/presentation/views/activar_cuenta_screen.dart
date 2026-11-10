import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_password.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/consentimiento_datos_checkbox.dart';

/// Activación de una cuenta invitada (voluntario): el administrador de su organización
/// le entrega un código de un solo uso (XXXX-XXXX) y aquí pone su contraseña.
class ActivarCuentaScreen extends ConsumerStatefulWidget {
  const ActivarCuentaScreen({super.key});

  @override
  ConsumerState<ActivarCuentaScreen> createState() => _ActivarCuentaScreenState();
}

class _ActivarCuentaScreenState extends ConsumerState<ActivarCuentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmacionCtrl = TextEditingController();
  bool _aceptaDatos = false;
  bool _intentoEnviar = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _codigoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmacionCtrl.dispose();
    super.dispose();
  }

  String? _validarCodigo(String? valor) {
    final limpio = (valor ?? '').replaceAll(RegExp(r'[\s\-]'), '');
    if (limpio.isEmpty) return 'El código es obligatorio';
    if (limpio.length != 8) return 'El código tiene 8 caracteres (XXXX-XXXX)';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _intentoEnviar = true);
    if (!_formKey.currentState!.validate() || !_aceptaDatos) return;
    final ok = await ref.read(authViewModelProvider.notifier).activar(
          correo: _correoCtrl.text.trim(),
          codigo: _codigoCtrl.text.trim().toUpperCase(),
          password: _passwordCtrl.text,
        );
    if (ok && mounted) {
      final rol = ref.read(authViewModelProvider).usuario!.rol;
      Navigator.of(context).pushNamedAndRemoveUntil(rutaInicio(rol), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Activar mi cuenta', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                const Text(
                  'Escribe el código que te entregó el administrador de tu organización '
                  'y crea tu contraseña.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controlador: _correoCtrl,
                  hint: 'el correo con el que te invitaron',
                  tipoTeclado: TextInputType.emailAddress,
                  validador: Validators.correo,
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Código de activación',
                  controlador: _codigoCtrl,
                  hint: 'XXXX-XXXX',
                  capitalizacion: TextCapitalization.characters,
                  validador: _validarCodigo,
                ),
                const SizedBox(height: 16),
                CampoPassword(
                  controlador: _passwordCtrl,
                  hint: 'Nueva contraseña (mín. 8 caracteres)',
                  validador: Validators.passwordNueva,
                ),
                const SizedBox(height: 16),
                CampoPassword(
                  controlador: _confirmacionCtrl,
                  hint: 'Repite la contraseña',
                  validador: (v) => Validators.confirmarPassword(v, _passwordCtrl.text),
                ),
                const SizedBox(height: 18),
                ConsentimientoDatosCheckbox(
                  value: _aceptaDatos,
                  onChanged: (v) => setState(() => _aceptaDatos = v),
                  errorText: (_intentoEnviar && !_aceptaDatos)
                      ? 'Debes autorizar el tratamiento de tus datos'
                      : null,
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 8),
                  Text(authState.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                PrimaryButton(label: 'Activar cuenta', loading: authState.loading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
