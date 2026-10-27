import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Pantalla de bienvenida. Si hay una sesión guardada en el dispositivo, entra directo.
class BienvenidaScreen extends ConsumerStatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  ConsumerState<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends ConsumerState<BienvenidaScreen> {
  bool _revisando = true;

  @override
  void initState() {
    super.initState();
    _restaurar();
  }

  Future<void> _restaurar() async {
    final ok = await ref.read(authViewModelProvider.notifier).restaurarSesion();
    if (!mounted) return;
    if (ok) {
      final rol = ref.read(authViewModelProvider).usuario!.rol;
      Navigator.of(context).pushNamedAndRemoveUntil(rutaInicio(rol), (_) => false);
    } else {
      setState(() => _revisando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 4),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'RESCATE ', style: AppTextStyles.logo),
                    TextSpan(text: '360', style: AppTextStyles.logoAccent),
                  ],
                ),
              ),
              const Spacer(flex: 5),
              if (_revisando)
                const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else ...[
                PrimaryButton(
                  label: 'Iniciar sesión',
                  onPressed: () => Navigator.of(context).pushNamed('/login'),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Crear cuenta',
                  outlined: true,
                  onPressed: () => Navigator.of(context).pushNamed('/registro'),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Juntos somos más fuertes',
                style: AppTextStyles.bodySecondary,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
