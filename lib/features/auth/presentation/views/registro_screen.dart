import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
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
  final _confirmarCtrl = TextEditingController();
  bool _ocultarPassword = true;
  bool _aceptaDatos = false;
  bool _intentoEnviar = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _intentoEnviar = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || !_aceptaDatos) return;

    final ok = await ref.read(authViewModelProvider.notifier).registrar(
          nombre: _nombreCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim().isEmpty
              ? null
              : _telefonoCtrl.text.trim(),
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
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(text: 'RESCATE ', style: AppTextStyles.logo),
                      TextSpan(text: '360', style: AppTextStyles.logoAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Crea tu cuenta',
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 28),
                const Text('Nombre completo', style: AppTextStyles.body),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombreCtrl,
                  style: AppTextStyles.body,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(hintText: 'Nombre y apellido'),
                  validator: Validators.nombre,
                ),
                const SizedBox(height: 16),
                const Text('Correo electrónico', style: AppTextStyles.body),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _correoCtrl,
                  style: AppTextStyles.body,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'tucorreo@ejemplo.com'),
                  validator: Validators.correo,
                ),
                const SizedBox(height: 16),
                const Text('Teléfono (opcional)', style: AppTextStyles.body),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _telefonoCtrl,
                  style: AppTextStyles.body,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: '3001234567'),
                  validator: Validators.telefono,
                ),
                const SizedBox(height: 16),
                const Text('Contraseña', style: AppTextStyles.body),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl,
                  style: AppTextStyles.body,
                  obscureText: _ocultarPassword,
                  decoration: InputDecoration(
                    hintText: 'Mínimo 6 caracteres',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _ocultarPassword = !_ocultarPassword),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                const Text('Confirmar contraseña', style: AppTextStyles.body),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmarCtrl,
                  style: AppTextStyles.body,
                  obscureText: _ocultarPassword,
                  decoration:
                      const InputDecoration(hintText: 'Repite tu contraseña'),
                  validator: (v) =>
                      Validators.confirmarPassword(v, _passwordCtrl.text),
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
                  label: 'Crear cuenta',
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
                              text: 'Iniciar sesión',
                              style: AppTextStyles.link),
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
