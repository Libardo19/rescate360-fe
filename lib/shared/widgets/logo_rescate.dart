import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Logo de RESCATE360: pin con cruz y nombre. Cuando tengas el logo
/// oficial como imagen, se reemplaza aquí y cambia en toda la app.
class LogoRescate extends StatelessWidget {
  const LogoRescate({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.location_on, size: 64, color: AppColors.accent),
            Positioned(
              top: 14,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 18, color: AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'RESCATE', style: AppTextStyles.logo),
              TextSpan(text: '360', style: AppTextStyles.logoAccent),
            ],
          ),
        ),
      ],
    );
  }
}
