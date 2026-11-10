import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/offline/mensaje_offline.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/campo_texto.dart';
import '../../../../shared/widgets/campos_reporte.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/selector_tipo.dart';
import '../../../sin_conexion/presentation/viewmodels/sin_conexion_viewmodel.dart';
import '../viewmodels/reportes_viewmodel.dart';
import '../widgets/selector_tipo_incidente.dart';

class ReportarIncidenteScreen extends ConsumerStatefulWidget {
  const ReportarIncidenteScreen({super.key});

  @override
  ConsumerState<ReportarIncidenteScreen> createState() =>
      _ReportarIncidenteScreenState();
}

class _ReportarIncidenteScreenState
    extends ConsumerState<ReportarIncidenteScreen> {
  static const int _maxAdjuntos = 4;

  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  // Cuando elige "Otro": el tipo de emergencia escrito por el ciudadano
  final _otroTipoCtrl = TextEditingController();
  final _picker = ImagePicker();
  final List<AdjuntoReporte> _adjuntos = [];

  String? _tipoSeleccionado;
  ({double lat, double lng})? _posicion;
  bool get _ubicacionActual => _posicion != null;
  bool _intentoEnviar = false;
  bool _enviando = false;

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _otroTipoCtrl.dispose();
    super.dispose();
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // ------------------------------------------------------------ adjuntos
  void _opcionesAdjuntar() {
    if (_adjuntos.length >= _maxAdjuntos) {
      _avisar('Puedes adjuntar máximo $_maxAdjuntos archivos.');
      return;
    }

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
                _tomarFoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Elegir fotos de la galería'),
              onTap: () {
                Navigator.of(ctx).pop();
                _elegirFotos();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.videocam_outlined, color: AppColors.primary),
              title: const Text('Grabar video (máx. 1 min)'),
              onTap: () {
                Navigator.of(ctx).pop();
                _elegirVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined,
                  color: AppColors.primary),
              title: const Text('Elegir video de la galería'),
              onTap: () {
                Navigator.of(ctx).pop();
                _elegirVideo(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _agregarFoto(XFile archivo) async {
    final bytes = await archivo.readAsBytes();
    if (!mounted) return;
    setState(() {
      _adjuntos.add(
        AdjuntoReporte(archivo: archivo, esVideo: false, vistaPrevia: bytes),
      );
    });
  }

  Future<void> _tomarFoto() async {
    try {
      final archivo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (archivo != null) await _agregarFoto(archivo);
    } catch (_) {
      _avisar('No pudimos abrir la cámara.');
    }
  }

  Future<void> _elegirFotos() async {
    try {
      final archivos = await _picker.pickMultiImage(
        maxWidth: 1280,
        imageQuality: 85,
      );
      for (final archivo in archivos) {
        if (_adjuntos.length >= _maxAdjuntos) {
          _avisar('Puedes adjuntar máximo $_maxAdjuntos archivos.');
          break;
        }
        await _agregarFoto(archivo);
      }
    } catch (_) {
      _avisar('No pudimos abrir la galería.');
    }
  }

  Future<void> _elegirVideo(ImageSource fuente) async {
    try {
      final archivo = await _picker.pickVideo(
        source: fuente,
        maxDuration: const Duration(seconds: 60),
      );
      if (archivo == null || !mounted) return;
      setState(() {
        _adjuntos.add(AdjuntoReporte(archivo: archivo, esVideo: true));
      });
    } catch (_) {
      _avisar('No pudimos abrir la cámara o la galería de videos.');
    }
  }

  /// Lee el GPS real del teléfono
  Future<void> _usarUbicacion() async {
    try {
      final posicion =
          await ref.read(locationServiceProvider).ubicacionActual();
      if (mounted) setState(() => _posicion = posicion);
    } on UbicacionException catch (e) {
      _avisar(e.mensaje);
    }
  }

  String? _validarOtroTipo(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.length < 3)
      return 'Escribe qué tipo de emergencia es (mínimo 3 letras)';
    if (texto.length > 30) return 'Máximo 30 caracteres';
    if (!RegExp(r'^[a-zA-Z0-9áéíóúüñÁÉÍÓÚÜÑ ]+$').hasMatch(texto))
      return 'Usa solo letras, números y espacios';
    return null;
  }

  // ------------------------------------------------------------ envío
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
    final tipo = _tipoSeleccionado == 'otro'
        ? _otroTipoCtrl.text.trim()
        : _tipoSeleccionado!;
    final error = await ref.read(reportesCiudadanoProvider.notifier).crear(
      tipo: tipo,
      descripcion: _descripcionCtrl.text.trim(),
      lat: _posicion!.lat,
      lng: _posicion!.lng,
      archivos: [for (final a in _adjuntos) a.archivo],
    );
    if (!mounted) return;
    if (error == ApiException.sinConexion.mensaje) return _guardarSinConexion(tipo);
    setState(() => _enviando = false);
    if (error != null) return _avisar(error);
    _avisar('Reporte enviado. Míralo en la pestaña Reportes.');
    Navigator.of(context).pop();
  }

  /// Sin internet: el reporte (sin fotos) se firma, se guarda y sale por Bluetooth hacia
  /// teléfonos cercanos con RESCATE360; el primero que tenga internet lo sube.
  Future<void> _guardarSinConexion(String tipo) async {
    final descripcion = _descripcionCtrl.text.trim();
    final problema = await ref.read(sinConexionProvider.notifier).encolar(
          'reporte',
          reporte: ReporteOffline(
            tipo: tipo,
            descripcion: descripcion.length > ReporteOffline.maximoDescripcion
                ? descripcion.substring(0, ReporteOffline.maximoDescripcion)
                : descripcion,
          ),
          lat: _posicion!.lat,
          lng: _posicion!.lng,
        );
    if (!mounted) return;
    setState(() => _enviando = false);
    if (problema != null) return _avisar(problema);
    _avisar(_adjuntos.isEmpty
        ? 'Sin internet: tu reporte se guardó y se está pasando por Bluetooth a teléfonos cercanos.'
        : 'Sin internet: tu reporte se guardó sin las fotos y se está pasando por Bluetooth a teléfonos cercanos.');
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
                  opciones: ref.watch(tiposReporteProvider).maybeWhen(
                        data: opcionesTipo,
                        orElse: () => tiposIncidente,
                      ),
                  seleccionado: _tipoSeleccionado,
                  onSeleccionar: (id) => setState(() => _tipoSeleccionado = id),
                  errorText: (_intentoEnviar && _tipoSeleccionado == null)
                      ? 'Selecciona el tipo de incidente'
                      : null,
                ),
                if (_tipoSeleccionado == 'otro') ...[
                  const SizedBox(height: 14),
                  CampoTexto(
                    etiqueta: '¿Qué tipo de emergencia es?',
                    controlador: _otroTipoCtrl,
                    hint: 'Ej: fuga de gas, árbol caído',
                    capitalizacion: TextCapitalization.sentences,
                    validador: _validarOtroTipo,
                  ),
                ],
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
                  onTap: _usarUbicacion,
                  errorText: (_intentoEnviar && !_ubicacionActual)
                      ? 'Indica la ubicación del incidente'
                      : null,
                ),
                const SizedBox(height: 20),
                CampoAdjuntos(
                  adjuntos: _adjuntos,
                  maximo: _maxAdjuntos,
                  onAgregar: _opcionesAdjuntar,
                  onQuitar: (i) => setState(() => _adjuntos.removeAt(i)),
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
