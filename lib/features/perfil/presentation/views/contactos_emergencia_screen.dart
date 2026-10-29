import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/contacto_emergencia_model.dart';
import '../viewmodels/perfil_viewmodel.dart';

String _iniciales(String nombre) {
  final partes =
      nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (partes.isEmpty) return '?';
  final primera = partes.first[0];
  final segunda = partes.length > 1 ? partes[1][0] : '';
  return (primera + segunda).toUpperCase();
}

/// Contactos de emergencia (mockup 13). Se guardan en el backend (máximo 5) y
/// reciben un SMS con la ubicación cuando activas el SOS.
class ContactosEmergenciaScreen extends ConsumerStatefulWidget {
  const ContactosEmergenciaScreen({super.key});

  @override
  ConsumerState<ContactosEmergenciaScreen> createState() =>
      _ContactosEmergenciaScreenState();
}

class _ContactosEmergenciaScreenState extends ConsumerState<ContactosEmergenciaScreen> {
  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirFormulario({ContactoEmergencia? inicial}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormularioContacto(inicial: inicial),
    );
    if (guardado == true && mounted) {
      _avisar(inicial == null ? 'Contacto agregado' : 'Contacto actualizado');
    }
  }

  Future<void> _eliminar(ContactoEmergencia contacto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text('¿Quieres eliminar a ${contacto.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    final error = await ref.read(contactosProvider.notifier).eliminar(contacto.id);
    if (mounted) _avisar(error ?? 'Contacto eliminado');
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(contactosProvider);
    final contactos = estado.valueOrNull ?? const <ContactoEmergencia>[];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Contactos de emergencia', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: estado.isLoading && contactos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : estado.hasError && contactos.isEmpty
                  ? Center(
                      child: TextButton(
                        onPressed: () => ref.read(contactosProvider.notifier).recargar(),
                        child: Text('${ApiException.desde(estado.error!).mensaje}\nToca para reintentar',
                            textAlign: TextAlign.center),
                      ),
                    )
                  : contactos.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Aún no tienes contactos. Agrega a las personas '
                          'que deben ser avisadas en una emergencia: '
                          'les llega un SMS con tu ubicación cuando activas el SOS.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      itemCount: contactos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final c = contactos[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.surface,
                                child: Text(_iniciales(c.nombre),
                                    style: AppTextStyles.h2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.nombre,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (c.parentesco != null)
                                      Text(c.parentesco!,
                                          style: AppTextStyles.bodySecondary),
                                    Text(c.telefono,
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _abrirFormulario(inicial: c),
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20, color: AppColors.textSecondary),
                              ),
                              IconButton(
                                onPressed: () => _eliminar(c),
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: AppColors.danger),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: 'Agregar contacto',
                icon: Icons.add,
                // El backend acepta máximo 5
                onPressed: contactos.length >= 5 ? null : () => _abrirFormulario(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormularioContacto extends ConsumerStatefulWidget {
  final ContactoEmergencia? inicial;

  const _FormularioContacto({this.inicial});

  @override
  ConsumerState<_FormularioContacto> createState() => _FormularioContactoState();
}

class _FormularioContactoState extends ConsumerState<_FormularioContacto> {
  bool _guardando = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl =
      TextEditingController(text: widget.inicial?.nombre ?? '');
  late final TextEditingController _parentescoCtrl =
      TextEditingController(text: widget.inicial?.parentesco ?? '');
  late final TextEditingController _telefonoCtrl =
      TextEditingController(text: widget.inicial?.telefono ?? '');

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _parentescoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  String? _validarTelefono(String? valor) {
    final req = Validators.requerido(valor, campo: 'El teléfono');
    if (req != null) return req;
    return Validators.telefono(valor);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final parentesco = _parentescoCtrl.text.trim();
    final error = await ref.read(contactosProvider.notifier).guardar(
          id: widget.inicial?.id,
          nombre: _nombreCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          parentesco: parentesco.isEmpty ? null : parentesco,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.inicial == null
                    ? 'Agregar contacto'
                    : 'Editar contacto',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Nombre',
                controlador: _nombreCtrl,
                hint: 'Nombre y apellido',
                capitalizacion: TextCapitalization.words,
                validador: Validators.nombre,
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Parentesco',
                controlador: _parentescoCtrl,
                hint: 'Ej: Madre, hermano, amigo',
                capitalizacion: TextCapitalization.sentences,
                // Opcional; máximo 15 caracteres en el backend
                validador: (v) => (v ?? '').trim().length > 15 ? 'Máximo 15 caracteres' : null,
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Teléfono',
                controlador: _telefonoCtrl,
                hint: '+57 300 123 4567',
                tipoTeclado: TextInputType.phone,
                validador: _validarTelefono,
              ),
              const SizedBox(height: 22),
              PrimaryButton(label: 'Guardar', loading: _guardando, onPressed: _guardar),
            ],
          ),
        ),
      ),
    );
  }
}
