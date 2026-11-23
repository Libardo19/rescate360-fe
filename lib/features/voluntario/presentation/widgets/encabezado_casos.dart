import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/curvas_de_nivel.dart';

/// Misma composición, paleta, curvas y pestañas de Reportes del ciudadano.
class EncabezadoCasos extends StatelessWidget {
  const EncabezadoCasos(
      {super.key,
      required this.titulo,
      required this.subtitulo,
      required this.cifras,
      required this.etiquetas,
      required this.indice,
      required this.onCambiar});
  final String titulo, subtitulo;
  final List<({int? valor, String etiqueta, IconData icono})> cifras;
  final List<String> etiquetas;
  final int indice;
  final ValueChanged<int> onCambiar;
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(28)),
          child: DecoratedBox(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF14336F),
                AppColors.primary,
                AppColors.primaryDark
              ],
              stops: [0, .5, 1],
            )),
            child: Stack(children: [
              const Positioned.fill(
                  child: RepaintBoundary(
                      child: CustomPaint(painter: CurvasDeNivelPainter()))),
              SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(subtitulo,
                              style: const TextStyle(
                                  color: Color(0xFFC3D2F2), fontSize: 13.5)),
                          const SizedBox(height: 14),
                          Row(children: [
                            for (var i = 0; i < cifras.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                  child: _Cifra(
                                      valor: cifras[i].valor,
                                      etiqueta: cifras[i].etiqueta,
                                      icono: cifras[i].icono)),
                            ]
                          ]),
                          const SizedBox(height: 14),
                          _Segmentos(
                              etiquetas: etiquetas,
                              indice: indice,
                              onCambiar: onCambiar),
                        ]),
                  )),
            ]),
          ),
        ),
      );
}

class _Cifra extends StatelessWidget {
  final int? valor;
  final String etiqueta;
  final IconData icono;

  const _Cifra(
      {required this.valor, required this.etiqueta, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icono, color: const Color(0xFF8FB8FF), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${valor ?? '—'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(etiqueta,
                      style: const TextStyle(
                          color: Color(0xFFC3D2F2), fontSize: 11.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dos pestañas sobre el encabezado azul: la activa es una píldora blanca que se desliza.
class _Segmentos extends StatelessWidget {
  final List<String> etiquetas;
  final int indice;
  final ValueChanged<int> onCambiar;

  const _Segmentos(
      {required this.etiquetas, required this.indice, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    final duracion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: duracion,
            curve: Curves.easeOutCubic,
            alignment: Alignment(
                etiquetas.length == 1
                    ? 0
                    : -1 + 2 * indice / (etiquetas.length - 1),
                0),
            child: FractionallySizedBox(
              widthFactor: 1 / etiquetas.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 8,
                        offset: Offset(0, 2))
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < etiquetas.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: indice == i,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (indice != i) HapticFeedback.selectionClick();
                        onCambiar(i);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: duracion,
                          style: TextStyle(
                            color:
                                indice == i ? AppColors.primary : Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            fontFamily:
                                DefaultTextStyle.of(context).style.fontFamily,
                          ),
                          child: Text(etiquetas[i]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
