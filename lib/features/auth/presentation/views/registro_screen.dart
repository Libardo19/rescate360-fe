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

class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _aceptaDatos = false;
  bool _intentoEnviar = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _intentoEnviar = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || !_aceptaDatos) return;

    final telefono =
        _telefonoCtrl.text.trim().replaceAll(RegExp(r'[\s\-]'), '');

    final ok = await ref.read(authViewModelProvider.notifier).registrar(
          nombre: _nombreCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
          telefono: telefono.isEmpty ? null : telefono,
          password: _passwordCtrl.text,
        );
    if (ok && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
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
                const Text('Crear cuenta', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                const Text(
                  'Completa tus datos para unirte a RESCATE360',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                CampoTexto(
                  etiqueta: 'Nombre completo',
                  controlador: _nombreCtrl,
                  hint: 'Ej: Juan Pérez',
                  capitalizacion: TextCapitalization.words,
                  validador: Validators.nombre,
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controlador: _correoCtrl,
                  hint: 'tucorreo@ejemplo.com',
                  tipoTeclado: TextInputType.emailAddress,
                  validador: Validators.correo,
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  etiqueta: 'Número de teléfono',
                  controlador: _telefonoCtrl,
                  hint: '+57 300 123 4567',
                  tipoTeclado: TextInputType.phone,
                  validador: Validators.telefono,
                ),
                const SizedBox(height: 16),
                CampoPassword(
                  controlador: _passwordCtrl,
                  hint: 'Mín. 8 caracteres',
                  validador: Validators.passwordNueva,
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
                  Text(authState.error!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Registrarse',
                  loading: authState.loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/login'),
                    child: RichText(
                      text: const TextSpan(
                        style: AppTextStyles.bodySecondary,
                        children: [
                          TextSpan(text: '¿Ya tienes cuenta? '),
                          TextSpan(
                              text: 'Inicia sesión', style: AppTextStyles.link),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
