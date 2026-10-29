import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Logo "RESCATE 360" con ícono. Usa Text.rich para respetar el texto escalable.
class RescateLogo extends StatelessWidget {
  final double tamano;
  const RescateLogo({super.key, this.tamano = 20});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'RESCATE360',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors, color: AppColors.primary, size: tamano * 1.3),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'RESCATE ',
                    style: AppTextStyles.logo.copyWith(fontSize: tamano),
                  ),
                  TextSpan(
                    text: '360',
                    style: AppTextStyles.logoAccent.copyWith(fontSize: tamano),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
