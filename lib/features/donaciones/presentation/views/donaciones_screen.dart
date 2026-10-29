import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/models/donacion_model.dart';
import '../viewmodels/donaciones_viewmodel.dart';

/// Donaciones (mockup 18): las campañas vigentes de las organizaciones. La app no recibe pagos:
/// el aporte se coordina con la organización de cada campaña.
class DonacionesScreen extends ConsumerWidget {
  const DonacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campanas = ref.watch(campanasProvider);
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Campañas activas', style: AppTextStyles.h2),
              ),
              const SizedBox(height: 12),
              campanas.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(ApiException.desde(e).mensaje, style: AppTextStyles.bodySecondary),
                data: (lista) => lista.isEmpty
                    ? const Text('No hay campañas activas por ahora.', style: AppTextStyles.bodySecondary)
                    : Column(children: [for (final c in lista) _TarjetaCampana(campana: c)]),
              ),
              const SizedBox(height: 8),
              const Text(
                'La app no recibe pagos: coordina tu aporte con la organización de la campaña.',
                textAlign: TextAlign.center,
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

class _TarjetaCampana extends StatelessWidget {
  final CampanaModel campana;

  const _TarjetaCampana({required this.campana});

  String _numero(double valor) => valor == valor.roundToDouble() ? valor.toInt().toString() : valor.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(campana.titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(campana.descripcion, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: campana.avance,
              minHeight: 8,
              color: AppColors.success,
              backgroundColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_numero(campana.recaudado)} de ${_numero(campana.meta)} ${campana.unidad} · cierra el ${campana.fechaFinTexto}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
