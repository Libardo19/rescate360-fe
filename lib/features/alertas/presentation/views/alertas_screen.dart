import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/pestanas_segmentadas.dart';
import '../../data/models/alerta_model.dart';
import '../viewmodels/alertas_viewmodel.dart';

/// Ícono por tipo de alerta (texto libre del backend; lo que no esté aquí usa el genérico).
IconData _icono(String tipo) => switch (tipo) {
      'inundacion' => Icons.water_drop_outlined,
      'deslizamiento' => Icons.terrain,
      'seguridad' => Icons.shield_outlined,
      'clima' => Icons.cloud_outlined,
      'sismo' => Icons.vibration,
      'incendio' => Icons.local_fire_department_outlined,
      _ => Icons.campaign_outlined,
    };

/// Color por nivel (acordado con el panel): alto = danger, medio = warning, bajo = info.
Color _color(NivelAlerta nivel) => switch (nivel) {
      NivelAlerta.alto => AppColors.danger,
      NivelAlerta.medio => AppColors.warning,
      NivelAlerta.bajo => AppColors.info,
    };

/// Alertas activas: las que cubren mi ubicación y todas las del sistema.
class AlertasScreen extends ConsumerStatefulWidget {
  const AlertasScreen({super.key});

  @override
  ConsumerState<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends ConsumerState<AlertasScreen> {
  int _pestana = 0;

  void _verDetalle(AlertaModel alerta) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconoAlerta(alerta: alerta),
                const SizedBox(width: 12),
                Expanded(child: Text(alerta.titulo, style: AppTextStyles.h2)),
              ],
            ),
            const SizedBox(height: 16),
            Text(alerta.mensaje, style: AppTextStyles.body),
            const SizedBox(height: 6),
            Text(
              '${alerta.haceCuanto} · radio de ${alerta.radioTexto} · nivel ${alerta.nivel.name}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            Text(
              alerta.origen == 'sismo'
                  ? 'Información de fuentes sismológicas públicas (USGS/SGC); no es una alerta temprana oficial.'
                  : 'Mantente atento a las indicaciones de las autoridades y '
                      'comparte esta información con tu comunidad.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mensaje(String texto) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(texto, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(alertasProvider);
    final datos = estado.valueOrNull;

    Widget contenido;
    if (datos == null) {
      contenido = estado.hasError
          ? _mensaje('${ApiException.desde(estado.error!).mensaje}\nDesliza hacia abajo para reintentar.')
          : const Center(child: CircularProgressIndicator());
    } else {
      final lista = _pestana == 0 ? datos.enMiZona : datos.todas;
      if (lista == null) {
        contenido = _mensaje('Activa la ubicación para ver las alertas de tu zona.');
      } else if (lista.isEmpty) {
        contenido = _mensaje(_pestana == 0 ? 'No hay alertas en tu zona.' : 'No hay alertas activas.');
      } else {
        contenido = ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: lista.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _TarjetaAlerta(alerta: lista[i], onVerMas: () => _verDetalle(lista[i])),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alertas', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: PestanasSegmentadas(
                etiquetas: const ['En mi zona', 'Todas'],
                indice: _pestana,
                onCambiar: (i) => setState(() => _pestana = i),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(alertasProvider.future),
                child: contenido is ListView ? contenido : ListView(children: [SizedBox(height: 320, child: contenido)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconoAlerta extends StatelessWidget {
  final AlertaModel alerta;
  const _IconoAlerta({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final color = _color(alerta.nivel);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_icono(alerta.tipo), color: color, size: 24),
    );
  }
}

class _TarjetaAlerta extends StatelessWidget {
  final AlertaModel alerta;
  final VoidCallback onVerMas;

  const _TarjetaAlerta({required this.alerta, required this.onVerMas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconoAlerta(alerta: alerta),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(alerta.mensaje, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySecondary),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(alerta.haceCuanto, style: AppTextStyles.caption),
                    const Spacer(),
                    GestureDetector(
                      onTap: onVerMas,
                      child: const Text('Ver más', style: AppTextStyles.link),
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
