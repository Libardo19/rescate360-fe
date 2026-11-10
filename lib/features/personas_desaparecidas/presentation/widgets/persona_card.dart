import 'package:flutter/material.dart';
import 'package:rescate360/shared/widgets/etiqueta_estado.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/persona_desaparecida.dart';
import 'estado_persona_ui.dart';

/// Tarjeta reutilizable para mostrar una persona desaparecida en la lista.
class PersonaCard extends StatelessWidget {
  final PersonaDesaparecida persona;
  final VoidCallback onTap;

  const PersonaCard({required this.persona, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foto = persona.imagen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surface,
              backgroundImage: foto,
              child: foto == null
                  ? Text(persona.iniciales, style: AppTextStyles.h2)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          persona.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      EtiquetaEstado(
                        texto: persona.estado.etiqueta,
                        color: persona.estado.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${persona.edad} años · ${persona.sexo}',
                      style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 2),
                  Text(
                      'Vista por última vez: ${persona.fechaVistaTexto} '
                      '(${persona.haceCuanto.toLowerCase()})',
                      style: AppTextStyles.caption),
                  Text(persona.lugar, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4, top: 18),
              child: Icon(Icons.chevron_right, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
