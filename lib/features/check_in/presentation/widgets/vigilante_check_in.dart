import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sin_conexion/presentation/viewmodels/sin_conexion_viewmodel.dart';
import '../../../sismos/presentation/views/alerta_sismo_screen.dart';
import '../viewmodels/check_in_viewmodel.dart';
import '../views/estas_bien_screen.dart';

/// Envuelve la pantalla principal: consulta el "¿Estás bien?" cada minuto mientras la app está
/// abierta y, si aparece uno pendiente, abre la pantalla completa (una sola vez por check-in).
/// Al arrancar también inicia el modo sin conexión.
class VigilanteCheckIn extends ConsumerStatefulWidget {
  final Widget child;

  const VigilanteCheckIn({super.key, required this.child});

  @override
  ConsumerState<VigilanteCheckIn> createState() => _VigilanteCheckInState();
}

class _VigilanteCheckInState extends ConsumerState<VigilanteCheckIn> with WidgetsBindingObserver {
  String? _mostrado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(checkInProvider.notifier).iniciar();
      // También arranca el modo sin conexión: guarda la llave offline y entrega lo que haya en cola
      ref.read(sinConexionProvider.notifier).iniciar();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    final vm = ref.read(checkInProvider.notifier);
    if (estado == AppLifecycleState.resumed) {
      vm.iniciar();
    } else {
      vm.detener();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(checkInProvider, (_, actual) {
      if (actual == null || !actual.pendiente || actual.id == _mostrado) return;
      _mostrado = actual.id;
      // La alerta SOS del sismo ya permite responderlo: no se abre otra pantalla encima
      if (AlertaSismoScreen.abierta) return;
      Navigator.of(context).push(
        MaterialPageRoute(fullscreenDialog: true, builder: (_) => const EstasBienScreen()),
      );
    });
    return widget.child;
  }
}
