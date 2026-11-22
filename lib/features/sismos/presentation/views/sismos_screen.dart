import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/pestanas_segmentadas.dart';
import '../../data/models/sismo_model.dart';
import '../../data/repositories/sismos_repository.dart';

/// Sismos recientes de todo el mundo (USGS), con pestañas por región.
/// En el mapa se ven con la capa "Sismos"; aquí, en lista y del más reciente al más antiguo.
class SismosScreen extends ConsumerStatefulWidget {
  const SismosScreen({super.key});

  @override
  ConsumerState<SismosScreen> createState() => _SismosScreenState();
}

class _SismosScreenState extends ConsumerState<SismosScreen> {
  static const _regiones = [RegionSismo.todos, RegionSismo.colombia, RegionSismo.mundo];
  int _pestana = 0;

  Widget _mensaje(String texto) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(texto, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final region = _regiones[_pestana];
    final estado = ref.watch(sismosProvider(region));
    final datos = estado.valueOrNull;

    Widget contenido;
    if (datos == null) {
      contenido = estado.hasError
          ? _mensaje('${ApiException.desde(estado.error!).mensaje}\nDesliza hacia abajo para reintentar.')
          : const Center(child: CircularProgressIndicator());
    } else if (datos.isEmpty) {
      contenido = _mensaje(region == RegionSismo.colombia
          ? 'No hay sismos recientes en Colombia.'
          : 'No hay sismos recientes.');
    } else {
      contenido = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: datos.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => i == datos.length
            ? const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Información de fuentes sismológicas públicas (USGS); no es una alerta temprana oficial. '
                  'Sigue las indicaciones del Servicio Geológico Colombiano y de la UNGRD.',
                  style: AppTextStyles.caption,
                ),
              )
            : _TarjetaSismo(sismo: datos[i]),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sismos recientes', style: AppTextStyles.h2), centerTitle: false),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: PestanasSegmentadas(
                etiquetas: const ['Mundo', 'Colombia', 'Fuera'],
                indice: _pestana,
                onCambiar: (i) => setState(() => _pestana = i),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(sismosProvider(region).future),
                child: contenido is ListView ? contenido : ListView(children: [SizedBox(height: 320, child: contenido)]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaSismo extends StatelessWidget {
  final SismoModel sismo;

  const _TarjetaSismo({required this.sismo});

  @override
  Widget build(BuildContext context) {
    final color = colorMagnitud(sismo.magnitud);
    final detalle = [
      sismo.haceCuanto,
      if (sismo.profundidadKm != null) '${sismo.profundidadKm!.round()} km de profundidad',
      if (sismo.distanciaTexto != null) sismo.distanciaTexto!,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Text(
              sismo.magnitud.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sismo.lugar, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(detalle, style: AppTextStyles.caption),
                if (sismo.enColombia) ...[
                  const SizedBox(height: 6),
                  Text(
                    sismo.alerto ? 'Colombia · se envió alerta' : 'Colombia',
                    style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
