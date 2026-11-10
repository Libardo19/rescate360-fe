import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/asignacion_model.dart';
import '../viewmodels/voluntario_local_viewmodel.dart';
import '../widgets/voluntario_ui.dart';

/// Actualizar estado de la atención (mockup 12): En camino → En sitio →
/// En atención → Finalizado, con notas opcionales.
class ActualizarEstadoScreen extends ConsumerStatefulWidget {
  final AsignacionModel asignacion;

  const ActualizarEstadoScreen({super.key, required this.asignacion});

  @override
  ConsumerState<ActualizarEstadoScreen> createState() =>
      _ActualizarEstadoScreenState();
}

class _ActualizarEstadoScreenState
    extends ConsumerState<ActualizarEstadoScreen> {
  late PasoAtencion _paso;
  late AtencionEstado _atencion;
  late final TextEditingController _notasCtrl;

  @override
  void initState() {
    super.initState();
    _atencion = ref.read(atencionProvider.notifier).de(widget.asignacion.id);
    _paso = _atencion.paso;
    _notasCtrl = TextEditingController(text: _atencion.notas);
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  void _enviar() {
    ref.read(atencionProvider.notifier).actualizar(
          widget.asignacion.id,
          _paso,
          notas: _notasCtrl.text.trim(),
        );
    Navigator.of(context).pop(_paso);
  }

  @override
  Widget build(BuildContext context) {
    final solicitud = widget.asignacion.solicitud;
    final esFinal = _paso == PasoAtencion.finalizado;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Actualizar estado', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (solicitud != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(solicitud.icono, color: solicitud.colorTipo),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            solicitud.titulo,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(solicitud.ubicacionTexto,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text('¿En qué paso estás?', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            for (var i = 0; i < PasoAtencion.values.length; i++)
              _PasoFila(
                paso: PasoAtencion.values[i],
                seleccionado: _paso == PasoAtencion.values[i],
                fecha: _atencion.fechas[PasoAtencion.values[i]],
                esUltimo: i == PasoAtencion.values.length - 1,
                onTap: () => setState(() => _paso = PasoAtencion.values[i]),
              ),
            const SizedBox(height: 20),
            const Text('Notas (opcional)', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            TextField(
              controller: _notasCtrl,
              maxLines: 3,
              maxLength: 300,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Escribe una breve actualización...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Los pasos se guardan solo en este celular. El backend '
                    'registra el caso como atendido únicamente al finalizar.',
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
          child: PrimaryButton(
            label: esFinal ? 'Finalizar caso' : 'Enviar actualización',
            onPressed: _enviar,
          ),
        ),
      ),
    );
  }
}

class _PasoFila extends StatelessWidget {
  final PasoAtencion paso;
  final bool seleccionado;
  final DateTime? fecha;
  final bool esUltimo;
  final VoidCallback onTap;

  const _PasoFila({
    required this.paso,
    required this.seleccionado,
    required this.fecha,
    required this.esUltimo,
    required this.onTap,
  });

  String get _hora {
    if (fecha == null) return '';
    final h = fecha!.hour.toString().padLeft(2, '0');
    final m = fecha!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final color = paso.color;
    final activo = seleccionado || fecha != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: activo
                      ? color.withValues(alpha: 0.15)
                      : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activo ? color : AppColors.surfaceBorder,
                    width: seleccionado ? 2 : 1,
                  ),
                ),
                child: Icon(
                  seleccionado ? Icons.radio_button_checked : paso.icono,
                  size: 17,
                  color: activo ? color : AppColors.textMuted,
                ),
              ),
              if (!esUltimo)
                Container(
                  width: 2,
                  height: 30,
                  color: AppColors.surfaceBorder,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paso.etiqueta,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          seleccionado ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(paso.descripcion, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
          if (fecha != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _hora,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
