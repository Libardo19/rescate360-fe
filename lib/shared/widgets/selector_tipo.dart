import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Opción de una cuadrícula de selección (tipo de incidente, tipo de ayuda).
class OpcionTipo {
  final String id;
  final String etiqueta;
  final IconData icono;
  final Color color;

  const OpcionTipo({
    required this.id,
    required this.etiqueta,
    required this.icono,
    required this.color,
  });
}

/// Cuadrícula de 3 columnas con una opción seleccionable.
class SelectorTipo extends StatelessWidget {
  final List<OpcionTipo> opciones;
  final String? seleccionado;
  final ValueChanged<String> onSeleccionar;
  final String? errorText;

  const SelectorTipo({
    super.key,
    required this.opciones,
    required this.seleccionado,
    required this.onSeleccionar,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: opciones.map((opcion) {
            final activa = opcion.id == seleccionado;
            return InkWell(
              onTap: () => onSeleccionar(opcion.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activa
                      ? opcion.color.withOpacity(0.08)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: activa ? opcion.color : AppColors.surfaceBorder,
                    width: activa ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: opcion.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(opcion.icono, color: opcion.color, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opcion.etiqueta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: activa ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(errorText!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ],
      ],
    );
  }
}
