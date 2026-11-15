import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/modo_oscuro.dart';
import '../../core/network/api_client.dart';

/// Carrusel de fotos (URLs del API): se pasan de lado y al tocarlas se abren a pantalla completa.
/// Lo usan el detalle del mapa y el de la pestaña Reportes.
class GaleriaFotos extends StatefulWidget {
  final List<String> fotos;
  final double alto;
  final BorderRadius radio;

  /// Muestra "Toca para ampliar" arriba a la izquierda.
  final bool conIndicacion;

  const GaleriaFotos({
    super.key,
    required this.fotos,
    this.alto = 210,
    this.radio = const BorderRadius.all(Radius.circular(20)),
    this.conIndicacion = true,
  });

  @override
  State<GaleriaFotos> createState() => _GaleriaFotosState();
}

class _GaleriaFotosState extends State<GaleriaFotos> {
  final _paginas = PageController();
  int _actual = 0;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fotos = widget.fotos;
    return SizedBox(
      height: widget.alto,
      child: ClipRRect(
        borderRadius: widget.radio,
        child: Stack(
          children: [
            PageView.builder(
              controller: _paginas,
              itemCount: fotos.length,
              onPageChanged: (i) => setState(() => _actual = i),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => abrirVisorFotos(context, fotos, i),
                child: Hero(tag: fotos[i], child: FotoRed(url: fotos[i], ajuste: BoxFit.cover)),
              ),
            ),
            if (fotos.length > 1) ...[
              Positioned(
                top: 10,
                right: 10,
                child: _Pastilla(texto: '${_actual + 1}/${fotos.length}'),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < fotos.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _actual ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: i == _actual ? 1 : 0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (widget.conIndicacion)
              const Positioned(
                left: 10,
                top: 10,
                child: _Pastilla(texto: 'Toca para ampliar', icono: Icons.zoom_out_map_rounded),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pastilla extends StatelessWidget {
  final String texto;
  final IconData? icono;

  const _Pastilla({required this.texto, this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, color: Colors.white, size: 13),
            const SizedBox(width: 4),
          ],
          Text(texto, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Abre las fotos a pantalla completa desde la [inicial].
void abrirVisorFotos(BuildContext context, List<String> fotos, int inicial) {
  HapticFeedback.selectionClick();
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, animacion, __) => FadeTransition(
      opacity: animacion,
      child: _VisorFotos(fotos: fotos, inicial: inicial),
    ),
  ));
}

/// Fotos a pantalla completa: se pasan de lado y se amplían con dos dedos.
class _VisorFotos extends StatefulWidget {
  final List<String> fotos;
  final int inicial;

  const _VisorFotos({required this.fotos, required this.inicial});

  @override
  State<_VisorFotos> createState() => _VisorFotosState();
}

class _VisorFotosState extends State<_VisorFotos> {
  late final _paginas = PageController(initialPage: widget.inicial);
  late int _actual = widget.inicial;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _paginas,
              itemCount: widget.fotos.length,
              onPageChanged: (i) => setState(() => _actual = i),
              itemBuilder: (context, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Hero(tag: widget.fotos[i], child: FotoRed(url: widget.fotos[i], ajuste: BoxFit.contain)),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.15)),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                    const Spacer(),
                    if (widget.fotos.length > 1)
                      Text(
                        '${_actual + 1} de ${widget.fotos.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Foto del API con su carga y su error; no se invierte en modo oscuro.
class FotoRed extends StatelessWidget {
  final String url;
  final BoxFit ajuste;

  const FotoRed({super.key, required this.url, this.ajuste = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return SinFiltroOscuro(
      child: Image.network(
        urlArchivo(url),
        fit: ajuste,
        width: double.infinity,
        height: ajuste == BoxFit.cover ? double.infinity : null,
        semanticLabel: 'Foto del reporte',
        loadingBuilder: (context, hijo, progreso) => progreso == null
            ? hijo
            : const ColoredBox(
                color: AppColors.surface,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
              ),
        errorBuilder: (context, _, __) => const ColoredBox(
          color: AppColors.surface,
          child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 36)),
        ),
      ),
    );
  }
}
