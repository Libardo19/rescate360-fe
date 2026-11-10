import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Mensaje vacío/error que igual se puede deslizar (y tocar) para reintentar.
class MensajeLista extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Future<void> Function() onReintentar;

  const MensajeLista({
    super.key,
    required this.icono,
    required this.texto,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onReintentar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
        children: [
          Icon(icono, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ),
        ],
      ),
    );
  }
}
