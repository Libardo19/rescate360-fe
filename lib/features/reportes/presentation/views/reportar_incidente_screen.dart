import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/campos_reporte.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/selector_tipo.dart';

class ReportarIncidenteScreen extends StatefulWidget {
  const ReportarIncidenteScreen({super.key});

  @override
  State<ReportarIncidenteScreen> createState() =>
      _ReportarIncidenteScreenState();
}

class _ReportarIncidenteScreenState extends State<ReportarIncidenteScreen> {
  static const List<OpcionTipo> _tipos = [
    OpcionTipo(
        id: 'accidente',
        etiqueta: 'Accidente',
        icono: Icons.directions_car_outlined,
        color: AppColors.danger),
    OpcionTipo(
        id: 'robo',
        etiqueta: 'Robo',
        icono: Icons.shopping_bag_outlined,
        color: AppColors.primary),
    OpcionTipo(
        id: 'inundacion',
        etiqueta: 'Inundación',
        icono: Icons.water_drop_outlined,
        color: AppColors.info),
    OpcionTipo(
        id: 'deslizamiento',
        etiqueta: 'Deslizamiento',
        icono: Icons.terrain,
        color: AppColors.warning),
    OpcionTipo(
        id: 'incendio',
        etiqueta: 'Incendio',
        icono: Icons.local_fire_department_outlined,
        color: AppColors.danger),
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
    // TODO: enviar a la API (rescate360-be) desde el viewmodel de reportes.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _enviando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte enviado')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reportar incidente', style: AppTextStyles.h2),
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
                const Text('Tipo de incidente', style: AppTextStyles.body),
                const SizedBox(height: 10),
                SelectorTipo(
                  opciones: _tipos,
                  seleccionado: _tipoSeleccionado,
                  onSeleccionar: (id) => setState(() => _tipoSeleccionado = id),
                  errorText: (_intentoEnviar && _tipoSeleccionado == null)
                      ? 'Selecciona el tipo de incidente'
                      : null,
                ),
                const SizedBox(height: 20),
                CampoTexto(
                  etiqueta: 'Descripción',
                  controlador: _descripcionCtrl,
                  hint: 'Describe lo que está sucediendo...',
                  maxLineas: 4,
                  capitalizacion: TextCapitalization.sentences,
                  validador: _validarDescripcion,
                ),
                const SizedBox(height: 20),
                CampoUbicacion(
                  seleccionada: _ubicacionActual,
                  onTap: () => setState(() => _ubicacionActual = true),
                  errorText: (_intentoEnviar && !_ubicacionActual)
                      ? 'Indica la ubicación del incidente'
                      : null,
                ),
                const SizedBox(height: 20),
                CampoAdjuntos(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente')),
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Enviar reporte',
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
