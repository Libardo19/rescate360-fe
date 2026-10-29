import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import 'voluntario_ui.dart';

/// Tarjeta de un incidente/solicitud para las listas del voluntario
/// (mockups 4 y 6: "Incidentes cercanos" y "Mis asignaciones").
class TarjetaIncidente extends StatelessWidget {
  final SolicitudAyudaModel solicitud;

  /// "A 1.2 km", si se conoce la ubicación del voluntario.
  final String? distancia;

  /// Píldora de la derecha: "Nuevo", "En curso", "Finalizada"...
  final String? etiqueta;
  final Color etiquetaColor;

  /// Línea inferior: "Hace 8 min" o "Asignada hace 2 h".
  final String? pie;

  final VoidCallback onTap;

  const TarjetaIncidente({
    super.key,
    required this.solicitud,
    required this.onTap,
    this.distancia,
    this.etiqueta,
    this.etiquetaColor = AppColors.danger,
    this.pie,
  });

  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final color = s.colorTipo;
    final detalle = [
      s.nivel.textoCompleto,
      if (distancia != null) distancia!,
    ].join(' · ');

    return Material(
      color: AppColors.background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: s.esSos ? AppColors.danger : AppColors.surfaceBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s.icono, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (etiqueta != null) ...[
                          const SizedBox(width: 8),
                          EtiquetaEstado(
                            texto: etiqueta!,
                            color: etiquetaColor,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detalle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (pie != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        pie!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
