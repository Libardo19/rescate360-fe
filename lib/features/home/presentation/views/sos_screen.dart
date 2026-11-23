import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../check_in/presentation/viewmodels/check_in_viewmodel.dart';
import '../../../sin_conexion/presentation/viewmodels/sin_conexion_viewmodel.dart';
import '../../../solicitudes_ayuda/presentation/viewmodels/solicitudes_ayuda_viewmodel.dart';

/// Botón SOS (mockup 16). Se activa manteniendo presionado 3 segundos para
/// evitar activaciones por error.
///
/// Al activarse lee el GPS y envía POST /solicitudes-ayuda/sos: el backend la crea
/// con prioridad crítica. "Cancelar alerta" la cancela en el backend.
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progreso;
  bool _activado = false;
  // Id de la solicitud SOS creada, para poder cancelarla
  String? _solicitudId;

  @override
  void initState() {
    super.initState();
    _progreso = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((estado) {
        if (estado == AnimationStatus.completed) _activar();
      });
  }

  @override
  void dispose() {
    _progreso.dispose();
    super.dispose();
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _activar() async {
    if (mounted) setState(() => _activado = true);
    final resultado =
        await ref.read(solicitudesAyudaViewModelProvider).enviarSos();
    if (!mounted) return;
    if (resultado.error == ApiException.sinConexion.mensaje) {
      // Sin internet: se firma, se guarda y sale por Bluetooth hacia quien tenga red
      final problema =
          await ref.read(sinConexionProvider.notifier).encolar('sos');
      if (!mounted) return;
      if (problema == null) {
        final estado = ref.read(sinConexionProvider);
        _avisar(estado.relevoActivo
            ? 'Tu SOS quedó guardado. Revisa los teléfonos conectados en Modo sin conexión.'
            : estado.aviso ??
                'Tu SOS quedó guardado. Activa el relevo en Modo sin conexión.');
        return;
      }
    }
    if (resultado.error != null) {
      // No salió: se vuelve a dejar el botón listo para intentarlo otra vez
      _progreso.reset();
      setState(() => _activado = false);
      _avisar('No se pudo enviar el SOS: ${resultado.error}');
      return;
    }
    _solicitudId = resultado.solicitud!.id;
  }

  void _iniciar() {
    if (!_activado) _progreso.forward();
  }

  void _soltar() {
    if (!_activado) _progreso.reverse();
  }

  Future<void> _cancelarAlerta() async {
    final id = _solicitudId;
    if (id != null) {
      final resultado =
          await ref.read(solicitudesAyudaViewModelProvider).cancelar(id);
      if (!mounted) return;
      if (resultado.error != null) return _avisar(resultado.error!);
    }
    _solicitudId = null;
    _progreso.reset();
    setState(() => _activado = false);
  }

  Future<void> _activarModoEmergencia() async {
    final error =
        await ref.read(checkInProvider.notifier).activarModoEmergencia();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ??
          'Modo emergencia activado: si no respondes a tiempo, avisaremos a tus contactos de emergencia.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF3B0A10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B0A10), Color(0xFF8B1A24)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'En caso de emergencia, mantén la calma',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Listener(
                  onPointerDown: (_) => _iniciar(),
                  onPointerUp: (_) => _soltar(),
                  onPointerCancel: (_) => _soltar(),
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _progreso,
                          builder: (_, __) => SizedBox(
                            width: 230,
                            height: 230,
                            child: CircularProgressIndicator(
                              value: _activado ? 1 : _progreso.value,
                              strokeWidth: 8,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ),
                        Container(
                          width: 188,
                          height: 188,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFF5A52), Color(0xFFC2413A)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x80FF5A52),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _activado
                      ? 'SOS activado'
                      : 'Mantén presionado 3 segundos para activar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_activado) ...[
                  const SizedBox(height: 14),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.2),
                    ),
                    onPressed: _cancelarAlerta,
                    child: const Text('Cancelar alerta'),
                  ),
                ],
                const Spacer(),
                // Modo emergencia: si no responde el "¿Estás bien?", se avisa a sus contactos
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: _activarModoEmergencia,
                  icon: const Icon(Icons.timer_outlined),
                  label:
                      const Text('Modo emergencia: pregúntame si estoy bien'),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tu ubicación será compartida con los organismos '
                          'de atención y voluntarios cercanos.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
