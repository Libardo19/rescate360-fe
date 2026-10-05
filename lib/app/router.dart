import 'package:flutter/material.dart';
import '../features/alertas/presentation/views/alertas_screen.dart';
import '../features/auth/presentation/views/bienvenida_screen.dart';
import '../features/auth/presentation/views/login_screen.dart';
import '../features/auth/presentation/views/registro_screen.dart';
import '../features/home/presentation/views/principal_screen.dart';
import '../features/personas_desaparecidas/presentation/views/personas_desaparecidas_screen.dart';
import '../features/reportes/presentation/views/reportar_incidente_screen.dart';
import '../features/solicitudes_ayuda/presentation/views/solicitar_ayuda_screen.dart';

/// Rutas nombradas de la app.
/// Navegación inicial (según lo pedido):
///   Bienvenida -> Login -> Home
///   Bienvenida -> Registro -> Home
class AppRouter {
  AppRouter._();

  static const inicial = '/';
  static const login = '/login';
  static const registro = '/registro';
  static const home = '/home';
  static const reportarIncidente = '/reportar-incidente';
  static const personasDesaparecidas = '/personas-desaparecidas';
  static const solicitarAyuda = '/solicitar-ayuda';
  static const alertas = '/alertas';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case inicial:
        return _build(const BienvenidaScreen(), settings);
      case login:
        return _build(const LoginScreen(), settings);
      case registro:
        return _build(const RegistroScreen(), settings);
      case home:
        return _build(const PrincipalScreen(), settings);
      case reportarIncidente:
        return _build(const ReportarIncidenteScreen(), settings);
      case personasDesaparecidas:
        return _build(const PersonasDesaparecidasScreen(), settings);
      case solicitarAyuda:
        return _build(const SolicitarAyudaScreen(), settings);
      case alertas:
        return _build(const AlertasScreen(), settings);
      default:
        return _build(
          Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute _build(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
