import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'campo_texto.dart';

/// Campo de contraseña con botón para mostrar u ocultar el texto.
class CampoPassword extends StatefulWidget {
  final String etiqueta;
  final TextEditingController controlador;
  final String? hint;
  final String? Function(String?)? validador;

  const CampoPassword({
    super.key,
    required this.controlador,
    this.etiqueta = 'Contraseña',
    this.hint,
    this.validador,
  });

  @override
  State<CampoPassword> createState() => _CampoPasswordState();
}

class _CampoPasswordState extends State<CampoPassword> {
  bool _ocultar = true;

  @override
  Widget build(BuildContext context) {
    return CampoTexto(
      etiqueta: widget.etiqueta,
      controlador: widget.controlador,
      hint: widget.hint,
      validador: widget.validador,
      ocultarTexto: _ocultar,
      sufijo: IconButton(
        icon: Icon(
          _ocultar ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textMuted,
        ),
        onPressed: () => setState(() => _ocultar = !_ocultar),
      ),
    );
  }
}
