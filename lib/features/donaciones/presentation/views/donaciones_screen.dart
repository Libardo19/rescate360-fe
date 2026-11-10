import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Donaciones (mockup 18). Solo disponible en casos habilitados.
class DonacionesScreen extends StatelessWidget {
  const DonacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volunteer_activism_outlined,
                    color: AppColors.danger, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Donaciones', style: AppTextStyles.h1),
              const SizedBox(height: 6),
              const Text(
                'Tu aporte también salva vidas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Las donaciones ayudan a las personas afectadas por '
                'emergencias y a fortalecer la respuesta comunitaria.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Hacer donación',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente')),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Disponible solo en casos habilitados',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 28),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('¿En qué se usa?', style: AppTextStyles.h2),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _UsoDonacion(
                        icono: Icons.restaurant_outlined, etiqueta: 'Alimentos'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _UsoDonacion(
                        icono: Icons.medical_services_outlined,
                        etiqueta: 'Medicamentos'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _UsoDonacion(
                        icono: Icons.home_outlined, etiqueta: 'Refugios'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _UsoDonacion(
                        icono: Icons.handyman_outlined,
                        etiqueta: 'Equipos de rescate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsoDonacion extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _UsoDonacion({required this.icono, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icono, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              etiqueta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
