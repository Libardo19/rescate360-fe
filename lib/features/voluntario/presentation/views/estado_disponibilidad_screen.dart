import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../widgets/voluntario_ui.dart';

/// Pantalla para elegir si el voluntario está Disponible, Ocupado o Fuera de
/// servicio.
class EstadoDisponibilidadScreen extends ConsumerStatefulWidget {
  const EstadoDisponibilidadScreen({super.key});

  @override
  ConsumerState<EstadoDisponibilidadScreen> createState() =>
      _EstadoDisponibilidadScreenState();
}

class _EstadoDisponibilidadScreenState
    extends ConsumerState<EstadoDisponibilidadScreen> {
  late EstadoDisponibilidad _seleccion;

  @override
  void initState() {
    super.initState();
    _seleccion = ref.read(disponibilidadProvider);
  }

  void _guardar() {
    ref.read(disponibilidadProvider.notifier).cambiar(_seleccion);
    final mensajero = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    mensajero.showSnackBar(
      SnackBar(content: Text('Estado actualizado: ${_seleccion.etiqueta}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Estado de disponibilidad', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _TarjetaActual(estado: _seleccion),
                  const SizedBox(height: 22),
                  const Text('Elige tu estado', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  for (final estado in EstadoDisponibilidad.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OpcionEstado(
                        estado: estado,
                        activo: estado == _seleccion,
                        onTap: () => setState(() => _seleccion = estado),
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: AppColors.textMuted),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Por ahora tu estado se guarda solo en este celular.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: 'Guardar cambios',
                onPressed: _guardar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaActual extends StatelessWidget {
  final EstadoDisponibilidad estado;

  const _TarjetaActual({required this.estado});

  @override
  Widget build(BuildContext context) {
    final color = estado.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(estado.icono, color: color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estado.etiqueta,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(estado.descripcion, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionEstado extends StatelessWidget {
  final EstadoDisponibilidad estado;
  final bool activo;
  final VoidCallback onTap;

  const _OpcionEstado({
    required this.estado,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: activo
              ? AppColors.primary.withOpacity(0.06)
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: activo ? AppColors.primary : AppColors.surfaceBorder,
            width: activo ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              activo
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: activo ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estado.etiqueta,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(estado.descripcion, style: AppTextStyles.caption),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: estado.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
