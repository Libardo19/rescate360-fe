import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/campos_reporte.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/selector_tipo.dart';

class SolicitarAyudaScreen extends StatefulWidget {
  const SolicitarAyudaScreen({super.key});

  @override
  State<SolicitarAyudaScreen> createState() => _SolicitarAyudaScreenState();
}

class _SolicitarAyudaScreenState extends State<SolicitarAyudaScreen> {
  static const List<OpcionTipo> _tipos = [
    OpcionTipo(
        id: 'medica',
        etiqueta: 'Médica',
        icono: Icons.medical_services_outlined,
        color: AppColors.danger),
    OpcionTipo(
        id: 'alimentaria',
        etiqueta: 'Alimentaria',
        icono: Icons.restaurant_outlined,
        color: AppColors.warning),
    OpcionTipo(
        id: 'refugio',
        etiqueta: 'Refugio',
        icono: Icons.home_outlined,
        color: AppColors.info),
    OpcionTipo(
        id: 'rescate',
        etiqueta: 'Rescate',
        icono: Icons.groups_outlined,
        color: AppColors.primary),
    OpcionTipo(
        id: 'ropa',
        etiqueta: 'Ropa',
        icono: Icons.checkroom_outlined,
        color: AppColors.success),
    OpcionTipo(
        id: 'otro',
        etiqueta: 'Otro',
        icono: Icons.more_horiz,
        color: AppColors.textSecondary),
  ];

  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  String? _tipoSeleccionado;
  bool _ubicacionActual = false;
  bool _intentoEnviar = false;
  bool _enviando = false;

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  String? _validarDescripcion(String? valor) {
    final req = Validators.requerido(valor, campo: 'La descripción');
    if (req != null) return req;
    if (valor!.trim().length < 10) {
      return 'Cuéntanos un poco más (mínimo 10 caracteres)';
    }
    return null;
  }

  Future<void> _enviar() async {
    setState(() => _intentoEnviar = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _tipoSeleccionado == null || !_ubicacionActual) return;

    setState(() => _enviando = true);
    // TODO: enviar a la API (rescate360-be) desde el viewmodel de solicitudes.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _enviando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud enviada')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Solicitar ayuda', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Qué tipo de ayuda necesitas?',
                    style: AppTextStyles.h2),
                const SizedBox(height: 14),
                SelectorTipo(
                  opciones: _tipos,
                  seleccionado: _tipoSeleccionado,
                  onSeleccionar: (id) => setState(() => _tipoSeleccionado = id),
                  errorText: (_intentoEnviar && _tipoSeleccionado == null)
                      ? 'Selecciona el tipo de ayuda'
                      : null,
                ),
                const SizedBox(height: 20),
                CampoTexto(
                  etiqueta: 'Descripción',
                  controlador: _descripcionCtrl,
                  hint: '¿Necesitas ayuda? Cuéntanos más...',
                  maxLineas: 4,
                  capitalizacion: TextCapitalization.sentences,
                  validador: _validarDescripcion,
                ),
                const SizedBox(height: 20),
                CampoUbicacion(
                  seleccionada: _ubicacionActual,
                  onTap: () => setState(() => _ubicacionActual = true),
                  errorText: (_intentoEnviar && !_ubicacionActual)
                      ? 'Indica dónde necesitas la ayuda'
                      : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Enviar solicitud',
                  loading: _enviando,
                  onPressed: _enviar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
