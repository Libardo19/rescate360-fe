import 'package:flutter/material.dart';
import 'package:rescate360/features/landing/presentation/landing_actions.dart';
import '../widgets/home_sections.dart';
import '../widgets/landing_scaffold.dart';

/// Landing principal (solo web). Ruta: '/'
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _funcionesKey = GlobalKey();

  void _irAFunciones() {
    final ctx = _funcionesKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LandingScaffold(
      rutaActual: LandingActions.rutaInicio,
      onFunciones: _irAFunciones,
      secciones: [
        const HeroSection(),
        FuncionesSection(key: _funcionesKey),
        const PasosSection(),
        const AudienciasSection(),
        const LegalSection(),
        const CtaSection(),
      ],
    );
  }
}
