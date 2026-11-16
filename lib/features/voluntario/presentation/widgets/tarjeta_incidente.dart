import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/galeria_fotos.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../reportes/presentation/widgets/selector_tipo_incidente.dart';
import '../../../solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import 'voluntario_ui.dart';

class TarjetaIncidente extends StatelessWidget {
  const TarjetaIncidente(
      {super.key,
      required this.solicitud,
      required this.onTap,
      this.distancia,
      this.etiqueta,
      this.etiquetaColor = AppColors.danger,
      this.pie});
  final SolicitudAyudaModel solicitud;
  final String? distancia, etiqueta, pie;
  final Color etiquetaColor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final tipo = s.esReporte ? buscarTipoIncidente(s.tipo) : null;
    final color = tipo?.color ?? s.colorTipo;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D081C42), blurRadius: 16, offset: Offset(0, 6)),
          ]),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: AppColors.surfaceBorder.withValues(alpha: .7))),
        child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: 72,
                                height: 72,
                                child: s.evidenciaImagenes.isNotEmpty
                                    ? FotoRed(url: s.evidenciaImagenes.first)
                                    : DecoratedBox(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            color.withValues(alpha: .10),
                                            color.withValues(alpha: .22)
                                          ],
                                        )),
                                        child: Icon(tipo?.icono ?? s.icono,
                                            color: color, size: 30)),
                              )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    s.esReporte
                                        ? 'REPORTE CIUDADANO'
                                        : s.esSos
                                            ? 'EMERGENCIA SOS'
                                            : 'SOLICITUD DE AYUDA',
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: .7)),
                                const SizedBox(height: 4),
                                Text(tipo?.etiqueta ?? s.titulo,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 5),
                                Text(s.descripcion,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.35)),
                              ])),
                        ]),
                    const SizedBox(height: 12),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      EtiquetaEstado(
                          texto: s.nivel.textoCompleto, color: s.nivel.color),
                      EtiquetaEstado(
                          texto: etiqueta ?? s.estadoEtiqueta,
                          color: etiqueta == null ? color : etiquetaColor),
                      if (s.evidenciaImagenes.isNotEmpty)
                        EtiquetaEstado(
                            texto: s.evidenciaImagenes.length.toString() +
                                ' fotos',
                            color: AppColors.textSecondary),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(s.ubicacionTexto,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary))),
                      if (distancia != null)
                        Text(distancia!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                    ]),
                    const Divider(height: 22, color: AppColors.surfaceBorder),
                    Row(children: [
                      const Icon(Icons.schedule_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 5),
                      Expanded(
                          child: Text(pie ?? s.haceCuanto,
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.textMuted))),
                      const Text('Ver caso',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppColors.primary),
                    ]),
                  ]),
            )),
      ),
    );
  }
}
