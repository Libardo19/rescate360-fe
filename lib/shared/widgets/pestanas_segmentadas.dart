import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Selector de pestañas tipo "píldora" (Buscadas / Encontradas,
/// Activas / Historial).
class PestanasSegmentadas extends StatelessWidget {
  final List<String> etiquetas;
  final int indice;
  final ValueChanged<int> onCambiar;

  const PestanasSegmentadas({
    super.key,
    required this.etiquetas,
    required this.indice,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: List.generate(etiquetas.length, (i) {
          final activa = i == indice;
          return Expanded(
            child: GestureDetector(
              onTap: () => onCambiar(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: activa ? AppColors.background : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: activa
                      ? Border.all(color: AppColors.surfaceBorder)
                      : null,
                ),
                child: Text(
                  etiquetas[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: activa ? FontWeight.w700 : FontWeight.w500,
                    color: activa ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
