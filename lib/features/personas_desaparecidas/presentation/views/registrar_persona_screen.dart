import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/persona_desaparecida.dart';
import '../viewmodels/personas_desaparecidas_viewmodel.dart';

/// Formulario para reportar una persona desaparecida. Al publicarse, vuelve
/// a la lista con `true`.
class RegistrarPersonaScreen extends ConsumerStatefulWidget {
  const RegistrarPersonaScreen({super.key});

  @override
  ConsumerState<RegistrarPersonaScreen> createState() =>
      _RegistrarPersonaScreenState();
}

class _RegistrarPersonaScreenState
    extends ConsumerState<RegistrarPersonaScreen> {
  static final List<String> _sexos = sexosPersona.keys.toList();

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _nombreCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _estaturaCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();
  final _vestimentaCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _senasCtrl = TextEditingController();
  final _contactoNombreCtrl = TextEditingController();
  final _contactoTelefonoCtrl = TextEditingController();

  Uint8List? _foto;
  String? _sexo;
  DateTime? _fecha;
  bool _acepta = false;
  bool _intentoEnviar = false;
  bool _enviando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _edadCtrl.dispose();
    _estaturaCtrl.dispose();
    _lugarCtrl.dispose();
    _vestimentaCtrl.dispose();
    _descripcionCtrl.dispose();
    _senasCtrl.dispose();
    _contactoNombreCtrl.dispose();
    _contactoTelefonoCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ foto
  Future<void> _elegirFoto(ImageSource fuente) async {
    try {
      final archivo = await _picker.pickImage(
        source: fuente,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (archivo == null) return;
      final bytes = await archivo.readAsBytes();
      if (!mounted) return;
      setState(() => _foto = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la cámara o la galería.'),
        ),
      );
    }
  }

  void _opcionesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.primary),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.of(ctx).pop();
                _elegirFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.of(ctx).pop();
                _elegirFoto(ImageSource.gallery);
              },
            ),
            if (_foto != null)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Quitar foto'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _foto = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ fecha
  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy,
      firstDate: DateTime(hoy.year - 5),
      lastDate: hoy,
      helpText: 'Última vez que se le vio',
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  // ------------------------------------------------------------ validaciones
  String? _validarEdad(String? valor) {
    final req = Validators.requerido(valor, campo: 'La edad');
    if (req != null) return req;
    final n = int.tryParse(valor!.trim());
    if (n == null || n < 0 || n > 120) return 'Edad no válida';
    return null;
  }

  String? _validarDescripcion(String? valor) {
    final req = Validators.requerido(valor, campo: 'La descripción');
    if (req != null) return req;
    if (valor!.trim().length < 15) {
      return 'Cuéntanos un poco más (mínimo 15 caracteres)';
    }
    return null;
  }

  String? _validarTelefono(String? valor) {
    final req = Validators.requerido(valor, campo: 'El teléfono');
    if (req != null) return req;
    return Validators.telefono(valor);
  }

  String? _opcional(TextEditingController ctrl) {
    final texto = ctrl.text.trim();
    return texto.isEmpty ? null : texto;
  }

  // ------------------------------------------------------------ envío
  Future<void> _publicar() async {
    setState(() => _intentoEnviar = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _sexo == null || _fecha == null || !_acepta) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos marcados en rojo')),
      );
      return;
    }

    setState(() => _enviando = true);

    final error = await ref.read(personasViewModelProvider.notifier).crear(
          nombre: _nombreCtrl.text.trim(),
          edad: int.parse(_edadCtrl.text.trim()),
          sexo: sexosPersona[_sexo!]!,
          estatura: _opcional(_estaturaCtrl),
          fechaVista: _fecha!,
          lugar: _lugarCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim(),
          senasParticulares: _opcional(_senasCtrl),
          vestimenta: _opcional(_vestimentaCtrl),
          contactoNombre: _contactoNombreCtrl.text.trim(),
          contactoTelefono: _contactoTelefonoCtrl.text.trim(),
          foto: _foto,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reportar persona desaparecida',
            style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Encabezado(),
                const SizedBox(height: 18),
                _Seccion(
                  icono: Icons.photo_camera_outlined,
                  titulo: 'Foto',
                  hijos: [
                    _SelectorFoto(foto: _foto, onTap: _opcionesFoto),
                  ],
                ),
                _Seccion(
                  icono: Icons.person_outline,
                  titulo: 'Datos de la persona',
                  hijos: [
                    CampoTexto(
                      etiqueta: 'Nombre completo',
                      controlador: _nombreCtrl,
                      hint: 'Nombre y apellidos',
                      capitalizacion: TextCapitalization.words,
                      validador: Validators.nombre,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CampoTexto(
                            etiqueta: 'Edad',
                            controlador: _edadCtrl,
                            hint: 'Años',
                            tipoTeclado: TextInputType.number,
                            validador: _validarEdad,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CampoTexto(
                            etiqueta: 'Estatura',
                            controlador: _estaturaCtrl,
                            hint: 'Ej: 1.65 m',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Sexo', style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 0; i < _sexos.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _ChipOpcion(
                              etiqueta: _sexos[i],
                              activo: _sexo == _sexos[i],
                              onTap: () => setState(() => _sexo = _sexos[i]),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_intentoEnviar && _sexo == null) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Selecciona una opción',
                        style: TextStyle(color: AppColors.danger, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                _Seccion(
                  icono: Icons.event_outlined,
                  titulo: 'Última vez que se le vio',
                  hijos: [
                    _CampoFecha(
                      fecha: _fecha,
                      onTap: _elegirFecha,
                      errorText: (_intentoEnviar && _fecha == null)
                          ? 'Selecciona la fecha'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      etiqueta: 'Lugar',
                      controlador: _lugarCtrl,
                      hint: 'Barrio, sector o dirección',
                      capitalizacion: TextCapitalization.sentences,
                      validador: (v) =>
                          Validators.requerido(v, campo: 'El lugar'),
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      etiqueta: 'Vestimenta (opcional)',
                      controlador: _vestimentaCtrl,
                      hint: 'Ej: camiseta roja, jean y tenis blancos',
                      capitalizacion: TextCapitalization.sentences,
                    ),
                  ],
                ),
                _Seccion(
                  icono: Icons.description_outlined,
                  titulo: 'Descripción',
                  hijos: [
                    CampoTexto(
                      etiqueta: 'Descripción física y circunstancias',
                      controlador: _descripcionCtrl,
                      hint: 'Cabello, contextura, cómo desapareció...',
                      maxLineas: 4,
                      capitalizacion: TextCapitalization.sentences,
                      validador: _validarDescripcion,
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      etiqueta: 'Señas particulares (opcional)',
                      controlador: _senasCtrl,
                      hint: 'Tatuajes, cicatrices, lunares, lentes...',
                      maxLineas: 2,
                      capitalizacion: TextCapitalization.sentences,
                    ),
                  ],
                ),
                _Seccion(
                  icono: Icons.contact_phone_outlined,
                  titulo: 'Contacto',
                  hijos: [
                    CampoTexto(
                      etiqueta: 'Nombre de quien reporta',
                      controlador: _contactoNombreCtrl,
                      hint: 'Ej: Sandra López (madre)',
                      capitalizacion: TextCapitalization.words,
                      validador: (v) =>
                          Validators.requerido(v, campo: 'El nombre'),
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      etiqueta: 'Teléfono de contacto',
                      controlador: _contactoTelefonoCtrl,
                      hint: '+57 300 123 4567',
                      tipoTeclado: TextInputType.phone,
                      validador: _validarTelefono,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => setState(() => _acepta = !_acepta),
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acepta,
                        onChanged: (v) => setState(() => _acepta = v ?? false),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Confirmo que la información es verídica, que '
                            'tengo relación con la persona o autorización '
                            'para reportarla y, si adjunto una foto, autorizo '
                            'publicarla.',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_intentoEnviar && !_acepta)
                  const Padding(
                    padding: EdgeInsets.only(left: 12, top: 2),
                    child: Text(
                      'Debes confirmar para publicar el reporte',
                      style: TextStyle(color: AppColors.danger, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 14),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tu reporte quedará marcado como «En revisión» hasta '
                        'que sea verificado.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Publicar reporte',
                  icon: Icons.send_outlined,
                  loading: _enviando,
                  onPressed: _publicar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- widgets

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Color(0x330F2A5C),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0x26FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_search_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cada dato cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mientras más completo sea el reporte, más fácil será '
                  'encontrar a la persona.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final List<Widget> hijos;

  const _Seccion({
    required this.icono,
    required this.titulo,
    required this.hijos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(titulo, style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: 14),
          ...hijos,
        ],
      ),
    );
  }
}

class _SelectorFoto extends StatelessWidget {
  final Uint8List? foto;
  final VoidCallback onTap;

  const _SelectorFoto({required this.foto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: foto == null
                ? AppColors.primary.withOpacity(0.35)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: foto == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_outlined,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('Agregar foto', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Una foto reciente y clara del rostro ayuda mucho',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(foto!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xCC0F2A5C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Cambiar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ChipOpcion extends StatelessWidget {
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _ChipOpcion({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: activo ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activo ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          etiqueta,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _CampoFecha extends StatelessWidget {
  final DateTime? fecha;
  final VoidCallback onTap;
  final String? errorText;

  const _CampoFecha({
    required this.fecha,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha en que se le vio', style: AppTextStyles.body),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: errorText != null
                    ? AppColors.danger
                    : AppColors.surfaceBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fecha == null
                        ? 'Selecciona la fecha'
                        : formatearFecha(fecha!),
                    style: fecha == null
                        ? AppTextStyles.bodySecondary
                            .copyWith(color: AppColors.textMuted)
                        : AppTextStyles.body,
                  ),
                ),
                const Icon(Icons.expand_more, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ],
      ],
    );
  }
}
