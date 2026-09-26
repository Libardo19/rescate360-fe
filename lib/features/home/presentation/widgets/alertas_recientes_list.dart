import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/resumen_inicio_model.dart';

/// Lista de "Alertas recientes" del Home, fiel al mockup 2:
/// ícono de advertencia (roja) para riesgos, ícono "+" (azul) para
/// alertas informativas, con chevron a la derecha.
class AlertasRecientesList extends StatelessWidget {
  final List<AlertaReciente> alertas;
  final ValueChanged<AlertaReciente> onTap;

  const AlertasRecientesList({
    super.key,
    required this.alertas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: alertas.map((alerta) {
        final esRiesgo = alerta.tipo == TipoAlerta.riesgo;
        final color = esRiesgo ? AppColors.danger : AppColors.info;
        final icon = esRiesgo ? Icons.warning_rounded : Icons.add_circle_rounded;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onTap(alerta),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alerta.titulo,
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(alerta.descripcion, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
