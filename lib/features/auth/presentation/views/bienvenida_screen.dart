import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Pantalla de bienvenida
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

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
