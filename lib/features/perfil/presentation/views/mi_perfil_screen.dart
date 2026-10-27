import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_password.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/perfil_viewmodel.dart';

/// "Mis datos": nombre y teléfono, autorización de ubicación (Ley 1581) y cambio de contraseña.
class MiPerfilScreen extends ConsumerStatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  ConsumerState<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends ConsumerState<MiPerfilScreen> {
  final _formDatos = GlobalKey<FormState>();
  final _formClave = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  bool _guardando = false;
  bool _cambiandoClave = false;

  @override
  void initState() {
    super.initState();
    final usuario = ref.read(authViewModelProvider).usuario;
    _nombreCtrl = TextEditingController(text: usuario?.nombre);
    _telefonoCtrl = TextEditingController(text: usuario?.telefono);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    super.dispose();
  }

  void _avisar(String? error, String ok) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? ok)));
  }

  Future<void> _guardarDatos() async {
    if (!_formDatos.currentState!.validate()) return;
    setState(() => _guardando = true);
    final telefono = _telefonoCtrl.text.trim().replaceAll(RegExp(r'[\s\-]'), '');
    final error = await ref.read(perfilViewModelProvider).guardarDatos(
          nombre: _nombreCtrl.text.trim(),
          telefono: telefono.isEmpty ? null : telefono,
        );
    if (!mounted) return;
    setState(() => _guardando = false);
    _avisar(error, 'Tus datos se guardaron.');
  }

  Future<void> _cambiarClave() async {
    if (!_formClave.currentState!.validate()) return;
    setState(() => _cambiandoClave = true);
    final error = await ref
        .read(perfilViewModelProvider)
        .cambiarContrasena(actual: _actualCtrl.text, nueva: _nuevaCtrl.text);
    if (!mounted) return;
    setState(() => _cambiandoClave = false);
    if (error == null) {
      _actualCtrl.clear();
      _nuevaCtrl.clear();
    }
    _avisar(error, 'Tu contraseña cambió.');
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authViewModelProvider).usuario;
    final ubicacion = ref.watch(autorizaUbicacionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mis datos', style: AppTextStyles.h2), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${usuario?.correo ?? ''} · ${usuario?.rol.etiqueta ?? ''}', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 16),
              Form(
                key: _formDatos,
                child: Column(
                  children: [
                    CampoTexto(
                      etiqueta: 'Nombre completo',
                      controlador: _nombreCtrl,
                      capitalizacion: TextCapitalization.words,
                      validador: Validators.nombre,
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Número de celular',
                      controlador: _telefonoCtrl,
                      hint: '300 123 4567',
                      tipoTeclado: TextInputType.phone,
                      validador: Validators.telefono,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'Guardar mis datos', loading: _guardando, onPressed: _guardarDatos),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text('Mi ubicación', style: AppTextStyles.h2),
              const SizedBox(height: 6),
              ubicacion.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('No se pudo consultar tu autorización.', style: AppTextStyles.bodySecondary),
                data: (autoriza) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: autoriza ?? false,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Compartir mi ubicación', style: AppTextStyles.body),
                  subtitle: const Text(
                    'Para recibir alertas de tu zona y que tu posición se use en el mapa. '
                    'Puedes retirarla cuando quieras: se borra la ubicación guardada.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  onChanged: (valor) async {
                    final error = await ref.read(perfilViewModelProvider).autorizarUbicacion(valor);
                    if (mounted) _avisar(error, valor ? 'Autorización guardada.' : 'Autorización retirada.');
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Cambiar contraseña', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              Form(
                key: _formClave,
                child: Column(
                  children: [
                    CampoPassword(
                      controlador: _actualCtrl,
                      hint: 'Contraseña actual',
                      validador: (v) => Validators.requerido(v, campo: 'La contraseña actual'),
                    ),
                    const SizedBox(height: 12),
                    CampoPassword(
                      controlador: _nuevaCtrl,
                      hint: 'Contraseña nueva (mín. 8 caracteres)',
                      validador: Validators.passwordNueva,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Cambiar contraseña',
                      outlined: true,
                      loading: _cambiandoClave,
                      onPressed: _cambiarClave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
