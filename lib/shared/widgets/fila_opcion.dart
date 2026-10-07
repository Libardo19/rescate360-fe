import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Fila de lista con ícono de color, título y subtítulo opcional.
/// Si tiene [onTap] y no se indica [trailing], muestra una flecha.
class FilaOpcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const FilaOpcion({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.color = AppColors.primary,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppTextStyles.body),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitulo!, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Agrupa varias [FilaOpcion] en una tarjeta con bordes redondeados y
/// divisores entre filas.
class GrupoOpciones extends StatelessWidget {
  final List<Widget> filas;

  const GrupoOpciones({super.key, required this.filas});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < filas.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: 64,
                color: AppColors.surfaceBorder,
              ),
            filas[i],
          ],
        ],
      ),
    );
  }
}
