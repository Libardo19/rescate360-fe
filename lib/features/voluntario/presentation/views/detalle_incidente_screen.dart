import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import '../../data/models/asignacion_model.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../viewmodels/voluntario_viewmodel.dart';
import '../widgets/voluntario_ui.dart';

/// Detalle de un incidente (mockup 5) y de una asignación en curso.
///
/// Si [asignacion] es null el caso todavía no es del voluntario: puede
/// tomarlo o rechazarlo. Si viene una asignación activa puede soltarla o
/// marcarla como atendida.
class DetalleIncidenteScreen extends ConsumerWidget {
  final SolicitudAyudaModel solicitud;
  final AsignacionModel? asignacion;

  const DetalleIncidenteScreen({
    super.key,
    required this.solicitud,
    this.asignacion,
  });

  Future<void> _tomar(BuildContext context, WidgetRef ref) async {
    final mensajero = ScaffoldMessenger.of(context);
    final error =
        await ref.read(voluntarioViewModelProvider).tomar(solicitud);
    if (!context.mounted) return;

    if (error != null) {
      mensajero.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
    mensajero.showSnackBar(
      const SnackBar(content: Text('Caso tomado: está en "Mis asignaciones".')),
    );
  }

  void _rechazar(BuildContext context, WidgetRef ref) {
    final mensajero = ScaffoldMessenger.of(context);
    ref.read(casosOcultosProvider.notifier).ocultar(solicitud.id);
    Navigator.of(context).pop();
    mensajero.showSnackBar(
      const SnackBar(content: Text('Caso rechazado: no volverá a aparecer.')),
    );
  }

  Future<void> _soltar(BuildContext context, WidgetRef ref) async {
    final mensajero = ScaffoldMessenger.of(context);
    final error =
        await ref.read(voluntarioViewModelProvider).soltar(asignacion!.id);
    if (!context.mounted) return;

    if (error != null) {
      mensajero.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
    mensajero.showSnackBar(
      const SnackBar(content: Text('Soltaste el caso: vuelve a la lista.')),
    );
  }

  Future<void> _finalizar(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar caso'),
        content: const Text(
          '¿Confirmas que el incidente ya fue atendido? Esta acción no se '
          'puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, atendido'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;

    final mensajero = ScaffoldMessenger.of(context);
    final error =
        await ref.read(voluntarioViewModelProvider).finalizar(asignacion!.id);
    if (!context.mounted) return;

    if (error != null) {
      mensajero.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
    mensajero.showSnackBar(
      const SnackBar(content: Text('Caso marcado como atendido.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posicion = ref.watch(miUbicacionProvider).valueOrNull;
    final distancia = textoDistancia(solicitud.distanciaKm(posicion));
    final activa = asignacion?.estado == 'activa';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle del incidente', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _Encabezado(solicitud: solicitud),
            const SizedBox(height: 20),
            _Dato(
              icono: Icons.place_outlined,
              titulo: 'Ubicación',
              valor: solicitud.ubicacionTexto,
              extra: distancia,
            ),
            const SizedBox(height: 14),
            _Dato(
              icono: Icons.schedule,
              titulo: 'Reportado',
              valor: solicitud.haceCuanto,
            ),
            if (asignacion != null) ...[
              const SizedBox(height: 14),
              _Dato(
                icono: Icons.assignment_turned_in_outlined,
                titulo: 'Asignada',
                valor: textoHace(asignacion!.asignadoEn),
                extra: _etiquetaEstado(asignacion!.estado),
              ),
            ],
            const SizedBox(height: 22),
            const Text('Descripción', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(solicitud.descripcion, style: AppTextStyles.body),
            const SizedBox(height: 22),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 18, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Las fotos del reporte aparecerán aquí cuando el backend '
                    'las exponga en la API.',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: asignacion == null
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _rechazar(context, ref),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _tomar(context, ref),
                        icon: const Icon(Icons.pan_tool_alt_outlined, size: 18),
                        label: const Text('Tomar caso'),
                      ),
                    ),
                  ],
                )
              : activa
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(color: AppColors.danger),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _soltar(context, ref),
                            child: const Text('Soltar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _finalizar(context, ref),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Finalizar caso'),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  static String _etiquetaEstado(String estado) {
    switch (estado) {
      case 'activa':
        return 'En curso';
      case 'finalizada':
        return 'Finalizada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }
}

class _Encabezado extends StatelessWidget {
  final SolicitudAyudaModel solicitud;

  const _Encabezado({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    final color = solicitud.colorTipo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(solicitud.icono, color: color, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  solicitud.titulo,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    EtiquetaEstado(
                      texto: solicitud.nivel.textoCompleto,
                      color: solicitud.nivel.color,
                    ),
                    EtiquetaEstado(
                      texto: solicitud.estadoEtiqueta,
                      color: AppColors.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final String? extra;

  const _Dato({
    required this.icono,
    required this.titulo,
    required this.valor,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (extra != null)
          Text(
            extra!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
