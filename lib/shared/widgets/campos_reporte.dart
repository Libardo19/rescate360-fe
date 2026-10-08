import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

/// Archivo adjunto a un reporte (foto o video).
/// [vistaPrevia] solo existe para las fotos; los videos se muestran con un
/// ícono para no cargar el archivo completo en memoria.
class AdjuntoReporte {
  final XFile archivo;
  final bool esVideo;
  final Uint8List? vistaPrevia;

  const AdjuntoReporte({
    required this.archivo,
    required this.esVideo,
    this.vistaPrevia,
  });
}

/// Sección "Adjuntar fotos o videos": caja punteada cuando está vacía y
/// miniaturas con botón para quitar cuando ya hay archivos.
class CampoAdjuntos extends StatelessWidget {
  final List<AdjuntoReporte> adjuntos;
  final VoidCallback onAgregar;
  final ValueChanged<int> onQuitar;
  final int maximo;

  const CampoAdjuntos({
    super.key,
    required this.adjuntos,
    required this.onAgregar,
    required this.onQuitar,
    this.maximo = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Adjuntar fotos o videos', style: AppTextStyles.body),
            const Spacer(),
            Text('${adjuntos.length}/$maximo', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 8),
        if (adjuntos.isEmpty)
          _CajaVacia(onTap: onAgregar)
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < adjuntos.length; i++)
                _Miniatura(
                  adjunto: adjuntos[i],
                  onQuitar: () => onQuitar(i),
                ),
              if (adjuntos.length < maximo) _BotonAgregar(onTap: onAgregar),
            ],
          ),
      ],
    );
  }
}

const double _tamanoMiniatura = 84;

class _CajaVacia extends StatelessWidget {
  final VoidCallback onTap;

  const _CajaVacia({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: const _BordeDiscontinuoPainter(radio: 12),
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
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  final VoidCallback onTap;

  const _BotonAgregar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: const _BordeDiscontinuoPainter(radio: 12),
        child: const SizedBox(
          width: _tamanoMiniatura,
          height: _tamanoMiniatura,
          child: Icon(Icons.add, color: AppColors.primary, size: 28),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  final AdjuntoReporte adjunto;
  final VoidCallback onQuitar;

  const _Miniatura({required this.adjunto, required this.onQuitar});

  @override
  Widget build(BuildContext context) {
    final vistaPrevia = adjunto.vistaPrevia;

    return SizedBox(
      width: _tamanoMiniatura,
      height: _tamanoMiniatura,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: vistaPrevia != null
                  ? Image.memory(vistaPrevia, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.primary,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, color: Colors.white, size: 28),
                          SizedBox(height: 4),
                          Text(
                            'Video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onQuitar,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xB3000000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BordeDiscontinuoPainter extends CustomPainter {
  final double radio;

  const _BordeDiscontinuoPainter({this.radio = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final camino = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radio),
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
  bool shouldRepaint(covariant _BordeDiscontinuoPainter oldDelegate) =>
      oldDelegate.radio != radio;
}
