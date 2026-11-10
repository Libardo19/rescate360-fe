import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_password.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/logo_rescate.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identificadorCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // La sesión siempre queda guardada (cifrada) en el dispositivo hasta cerrar sesión.
  bool _recordarme = true;

  @override
  void dispose() {
    _identificadorCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authViewModelProvider.notifier).iniciarSesion(
          correo: _identificadorCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    if (ok && mounted) {
      final rol = ref.read(authViewModelProvider).usuario!.rol;
      Navigator.of(context).pushNamedAndRemoveUntil(rutaInicio(rol), (_) => false);
    }
  }

  void _olvideContrasena() {
    ref.read(authViewModelProvider.notifier).limpiarError();
    Navigator.of(context).pushNamed('/recuperar', arguments: _identificadorCtrl.text.trim());
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
                const Center(child: LogoRescate()),
                const SizedBox(height: 28),
                const Text('Iniciar sesión', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                const Text(
                  'Accede a tu cuenta para continuar',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controlador: _identificadorCtrl,
                  hint: 'tucorreo@ejemplo.com',
                  tipoTeclado: TextInputType.emailAddress,
                  validador: Validators.correo,
                ),
                const SizedBox(height: 16),
                CampoPassword(
                  controlador: _passwordCtrl,
                  hint: 'Ingresa tu contraseña',
                  validador: Validators.password,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _recordarme,
                        onChanged: (v) =>
                            setState(() => _recordarme = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Recordarme',
                        style: AppTextStyles.bodySecondary),
                    const Spacer(),
                    GestureDetector(
                      onTap: _olvideContrasena,
                      child: const Text('¿Olvidaste tu contraseña?',
                          style: AppTextStyles.link),
                    ),
                  ],
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Text(authState.error!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Iniciar sesión',
                  loading: authState.loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/registro'),
                    child: RichText(
                      text: const TextSpan(
                        style: AppTextStyles.bodySecondary,
                        children: [
                          TextSpan(text: '¿No tienes cuenta? '),
                          TextSpan(
                              text: 'Regístrate', style: AppTextStyles.link),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/activar'),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: AppTextStyles.bodySecondary,
                        children: [
                          TextSpan(text: '¿Eres voluntario y tienes un código? '),
                          TextSpan(
                              text: 'Activa tu cuenta', style: AppTextStyles.link),
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
