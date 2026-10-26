import 'package:flutter/material.dart';
import '../../app/theme/app_text_styles.dart';

/// Campo de formulario con etiqueta encima, reutilizable en toda la app.
/// Toma el estilo de entrada (relleno, bordes) del InputDecorationTheme global.
class CampoTexto extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controlador;
  final String? hint;
  final String? Function(String?)? validador;
  final TextInputType? tipoTeclado;
  final TextCapitalization capitalizacion;
  final bool ocultarTexto;
  final Widget? sufijo;
  final int maxLineas;

  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.hint,
    this.validador,
    this.tipoTeclado,
    this.capitalizacion = TextCapitalization.none,
    this.ocultarTexto = false,
    this.sufijo,
    this.maxLineas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: AppTextStyles.body),
        const SizedBox(height: 8),
        TextFormField(
          controller: controlador,
          style: AppTextStyles.body,
          keyboardType: tipoTeclado,
          textCapitalization: capitalizacion,
          obscureText: ocultarTexto,
          maxLines: ocultarTexto ? 1 : maxLineas,
          decoration: InputDecoration(hintText: hint, suffixIcon: sufijo),
          validator: validador,
        ),
      ],
    );
  }
}
