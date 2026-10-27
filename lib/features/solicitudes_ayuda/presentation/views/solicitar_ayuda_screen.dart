import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/campos_reporte.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/selector_tipo.dart';
import '../viewmodels/solicitudes_ayuda_viewmodel.dart';

class SolicitarAyudaScreen extends ConsumerStatefulWidget {
  const SolicitarAyudaScreen({super.key});

  @override
  ConsumerState<SolicitarAyudaScreen> createState() => _SolicitarAyudaScreenState();
}

class _SolicitarAyudaScreenState extends ConsumerState<SolicitarAyudaScreen> {
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
  ({double lat, double lng})? _posicion;
  bool get _ubicacionActual => _posicion != null;
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

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Lee el GPS real del teléfono
  Future<void> _usarUbicacion() async {
    try {
      final posicion = await ref.read(locationServiceProvider).ubicacionActual();
      if (mounted) setState(() => _posicion = posicion);
    } on UbicacionException catch (e) {
      _avisar(e.mensaje);
    }
  }

  Future<void> _enviar() async {
    setState(() => _intentoEnviar = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _tipoSeleccionado == null || !_ubicacionActual) return;

    setState(() => _enviando = true);
    final resultado = await ref.read(solicitudesAyudaViewModelProvider).pedirAyuda(
          tipo: _tipoSeleccionado!,
          descripcion: _descripcionCtrl.text.trim(),
          lat: _posicion!.lat,
          lng: _posicion!.lng,
        );
    if (!mounted) return;
    setState(() => _enviando = false);
    if (resultado.error != null) return _avisar(resultado.error!);
    _avisar('Solicitud enviada. Puedes seguirla en "Mis solicitudes".');
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
                  onTap: _usarUbicacion,
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
