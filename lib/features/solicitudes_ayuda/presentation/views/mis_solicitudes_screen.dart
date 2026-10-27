import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/solicitud_ayuda_model.dart';
import '../viewmodels/solicitudes_ayuda_viewmodel.dart';

/// Las solicitudes de ayuda y SOS del ciudadano, con su estado. Puede cancelar las abiertas.
class MisSolicitudesScreen extends ConsumerWidget {
  const MisSolicitudesScreen({super.key});

  static const _colorEstado = {
    'pendiente': AppColors.warning,
    'en_proceso': AppColors.info,
    'atendida': AppColors.success,
    'cancelada': AppColors.textMuted,
  };

  Future<void> _cancelar(BuildContext context, WidgetRef ref, SolicitudAyudaModel s) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar solicitud'),
        content: Text('¿Ya no necesitas "${s.titulo}"? Si un voluntario la tomó, se le avisará que se canceló.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (confirmar != true) return;
    final resultado = await ref.read(solicitudesAyudaViewModelProvider).cancelar(s.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado.error ?? 'Solicitud cancelada')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudes = ref.watch(misSolicitudesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mis solicitudes', style: AppTextStyles.h2), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).pushNamed('/solicitar-ayuda'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Pedir ayuda', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(misSolicitudesProvider.future),
        child: solicitudes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudieron cargar tus solicitudes. Desliza hacia abajo para reintentar.',
                    style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
              ),
            ],
          ),
          data: (lista) => lista.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Aún no has pedido ayuda.',
                          style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = lista[i];
                    final color = _colorEstado[s.estado] ?? AppColors.textMuted;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: s.esSos ? AppColors.danger : AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(s.esSos ? Icons.sos : Icons.support_agent,
                                  color: s.esSos ? AppColors.danger : AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s.titulo, style: AppTextStyles.body)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(s.estadoEtiqueta,
                                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          if (!s.esSos) ...[
                            const SizedBox(height: 6),
                            Text(s.descripcion, style: AppTextStyles.bodySecondary, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${s.creadoEn.day}/${s.creadoEn.month}/${s.creadoEn.year} '
                                '${s.creadoEn.hour.toString().padLeft(2, '0')}:${s.creadoEn.minute.toString().padLeft(2, '0')}',
                                style: AppTextStyles.bodySecondary,
                              ),
                              const Spacer(),
                              if (s.cancelable)
                                TextButton(
                                  onPressed: () => _cancelar(context, ref, s),
                                  child: const Text('Cancelar', style: TextStyle(color: AppColors.danger)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
