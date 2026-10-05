import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Fila "Usar mi ubicación actual" de los formularios de reporte y ayuda.
/// Por ahora solo marca la ubicación como seleccionada; la lectura real del
/// GPS se conecta después (o se reemplaza por tu location_picker).
class CampoUbicacion extends StatelessWidget {
  final bool seleccionada;
  final VoidCallback onTap;
  final String? errorText;

  const CampoUbicacion({
    super.key,
    required this.seleccionada,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ubicación', style: AppTextStyles.body),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: errorText != null
                    ? AppColors.danger
                    : AppColors.surfaceBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: seleccionada ? AppColors.success : AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    seleccionada
                        ? 'Ubicación actual seleccionada'
                        : 'Usar mi ubicación actual',
                    style: AppTextStyles.body,
                  ),
                ),
                Icon(
                  seleccionada ? Icons.check_circle : Icons.chevron_right,
                  size: 20,
                  color: seleccionada ? AppColors.success : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ],
      ],
    );
  }
}

/// Recuadro punteado "Toca para agregar" para fotos o videos.
class CampoAdjuntos extends StatelessWidget {
  final VoidCallback onTap;

  const CampoAdjuntos({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adjuntar fotos o videos', style: AppTextStyles.body),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            painter: _BordeDiscontinuoPainter(),
            child: const SizedBox(
              width: double.infinity,
              height: 96,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_outlined,
                      color: AppColors.primary, size: 26),
                  SizedBox(height: 6),
                  Text('Toca para agregar', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BordeDiscontinuoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final camino = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(12),
      ));
    for (final metrica in camino.computeMetrics()) {
      double distancia = 0;
      while (distancia < metrica.length) {
        canvas.drawPath(
          metrica.extractPath(distancia, distancia + 6),
          pincel,
        );
        distancia += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
