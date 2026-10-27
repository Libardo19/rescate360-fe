import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_password.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/auth_viewmodel.dart';

/// "¿Olvidaste tu contraseña?" en dos pasos:
/// 1) correo + por dónde quiere el código (SMS o correo electrónico);
/// 2) código recibido + contraseña nueva. Al terminar, queda con la sesión abierta.
class RecuperarContrasenaScreen extends ConsumerStatefulWidget {
  /// Correo que ya había escrito en el login (opcional).
  final String? correoInicial;

  const RecuperarContrasenaScreen({super.key, this.correoInicial});

  @override
  ConsumerState<RecuperarContrasenaScreen> createState() => _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends ConsumerState<RecuperarContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _correoCtrl = TextEditingController(text: widget.correoInicial);
  final _codigoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmacionCtrl = TextEditingController();
  String _canal = 'sms';
  String? _aviso; // con aviso = paso 2

  @override
  void dispose() {
    _correoCtrl.dispose();
    _codigoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pedirCodigo() async {
    if (!_formKey.currentState!.validate()) return;
    final mensaje = await ref
        .read(authViewModelProvider.notifier)
        .pedirCodigoRecuperacion(correo: _correoCtrl.text.trim(), canal: _canal);
    if (mensaje != null && mounted) setState(() => _aviso = mensaje);
  }

  Future<void> _cambiar() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authViewModelProvider.notifier).restablecer(
          correo: _correoCtrl.text.trim(),
          codigo: _codigoCtrl.text.trim().toUpperCase(),
          password: _passwordCtrl.text,
        );
    if (ok && mounted) {
      final rol = ref.read(authViewModelProvider).usuario!.rol;
      Navigator.of(context).pushNamedAndRemoveUntil(rutaInicio(rol), (_) => false);
    }
  }

  Widget _opcionCanal(String valor, String etiqueta, IconData icono) {
    final elegido = _canal == valor;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _canal = valor),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: elegido ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: elegido ? AppColors.primary : AppColors.surfaceBorder),
          ),
          child: Column(
            children: [
              Icon(icono, color: elegido ? AppColors.primary : AppColors.textMuted),
              const SizedBox(height: 6),
              Text(etiqueta, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final paso2 = _aviso != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recuperar contraseña', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Text(
                  paso2
                      ? '$_aviso El código vence en 15 minutos.'
                      : 'Te enviaremos un código para crear una contraseña nueva.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controlador: _correoCtrl,
                  hint: 'tucorreo@ejemplo.com',
                  tipoTeclado: TextInputType.emailAddress,
                  validador: Validators.correo,
                ),
                const SizedBox(height: 16),
                if (!paso2) ...[
                  const Text('¿Dónde quieres recibir el código?', style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _opcionCanal('sms', 'SMS a mi celular', Icons.sms_outlined),
                      const SizedBox(width: 12),
                      _opcionCanal('correo', 'Correo', Icons.mail_outline),
                    ],
                  ),
                ] else ...[
                  CampoTexto(
                    etiqueta: 'Código',
                    controlador: _codigoCtrl,
                    hint: 'XXXX-XXXX',
                    capitalizacion: TextCapitalization.characters,
                    validador: (v) => Validators.requerido(v, campo: 'El código'),
                  ),
                  const SizedBox(height: 16),
                  CampoPassword(
                    controlador: _passwordCtrl,
                    hint: 'Nueva contraseña (mín. 8 caracteres)',
                    validador: Validators.passwordNueva,
                  ),
                  const SizedBox(height: 16),
                  CampoPassword(
                    controlador: _confirmacionCtrl,
                    hint: 'Repite la contraseña',
                    validador: (v) => Validators.confirmarPassword(v, _passwordCtrl.text),
                  ),
                ],
                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Text(authState.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: paso2 ? 'Cambiar contraseña' : 'Enviar código',
                  loading: authState.loading,
                  onPressed: paso2 ? _cambiar : _pedirCodigo,
                ),
                if (paso2) ...[
                  const SizedBox(height: 14),
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _aviso = null),
                      child: const Text('Pedir otro código', style: AppTextStyles.link),
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
