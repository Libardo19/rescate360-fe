import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authViewModelProvider.notifier).iniciarSesion(
          correo: _correoCtrl.text.trim(),
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
                const Text(
                  'Inicia sesión para continuar',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 18),
                const Text('Contraseña', style: AppTextStyles.body),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl,
                  style: AppTextStyles.body,
                  obscureText: _ocultarPassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
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
                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Text(authState.error!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 28),
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
                              text: 'Crear cuenta', style: AppTextStyles.link),
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
