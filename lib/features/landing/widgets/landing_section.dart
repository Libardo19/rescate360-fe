import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

/// Contenedor de sección: centra el contenido a 1120 px máx. y ajusta márgenes.
class SectionContainer extends StatelessWidget {
  final Widget child;
  final bool banda; // fondo `surface` con bordes arriba y abajo
  final bool sinPaddingSuperior;
  final double? vertical;

  const SectionContainer({
    super.key,
    required this.child,
    this.banda = false,
    this.sinPaddingSuperior = false,
    this.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final double v =
        vertical ?? Responsive.valor(context, movil: 52.0, escritorio: 72.0);
    return Container(
      width: double.infinity,
      decoration: banda
          ? const BoxDecoration(
              color: AppColors.surface,
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.surfaceBorder),
              ),
            )
          : null,
      padding: EdgeInsets.only(top: sinPaddingSuperior ? 0 : v, bottom: v),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.esMovil(context) ? 16 : 20,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Título + subtítulo de sección (el título se anuncia como encabezado).
class SectionHeader extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  const SectionHeader({super.key, required this.titulo, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: Responsive.valor(context,
                        movil: 26.0, escritorio: 36.0),
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitulo!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rejilla que cambia de columnas según el ancho (móvil / tablet / escritorio).
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int movil;
  final int tablet;
  final int escritorio;
  final double espacio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.movil = 1,
    this.tablet = 2,
    this.escritorio = 3,
    this.espacio = 16,
  });

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.valor(
      context,
      movil: movil,
      tablet: tablet,
      escritorio: escritorio,
    );
    return LayoutBuilder(
      builder: (context, c) {
        final ancho = (c.maxWidth - espacio * (cols - 1)) / cols;
        return Wrap(
          spacing: espacio,
          runSpacing: espacio,
          children: [
            for (final w in children) SizedBox(width: ancho, child: w)
          ],
        );
      },
    );
  }
}

/// Tarjeta con ícono, título, texto y (opcional) etiqueta y acción.
class InfoCard extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String texto;
  final String? etiqueta;
  final String? accion;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icono,
    required this.color,
    required this.titulo,
    required this.texto,
    this.etiqueta,
    this.accion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.18),
                  ),
                  child: Icon(icono, color: color),
                ),
                const SizedBox(height: 14),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (etiqueta != null) _Etiqueta(etiqueta!),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (accion != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    accion!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}
