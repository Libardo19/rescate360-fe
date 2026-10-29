import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rescate360/features/landing/views/landing_screen.dart';
import '../features/auth/presentation/views/bienvenida_screen.dart';
import '../features/auth/presentation/views/login_screen.dart';
import '../features/auth/presentation/views/registro_screen.dart';
import '../features/home/presentation/views/home_screen.dart';

/// Rutas nombradas de la app.
///   Móvil: Bienvenida -> Login/Registro -> Home
///   Web:   Landing (/) -> Login/Registro -> Home
class AppRouter {
  AppRouter._();

  static const inicial = '/';
  static const login = '/login';
  static const registro = '/registro';
  static const home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case inicial:
        return _build(
          kIsWeb ? const LandingScreen() : const BienvenidaScreen(),
          settings,
        );
      case login:
        return _build(const LoginScreen(), settings);
      case registro:
        return _build(const RegistroScreen(), settings);
      case home:
        return _build(const HomeScreen(), settings);
      // TODO(landing): descomentar al crear cada página
      // case '/como-funciona':  return _build(const ComoFuncionaScreen(), settings);
      // case '/ciudadanos':     return _build(const CiudadanosScreen(), settings);
      // case '/organizaciones': return _build(const OrganizacionesScreen(), settings);
      default:
        return _build(
          Scaffold(
              body:
                  Center(child: Text('Ruta no encontrada: ${settings.name}'))),
          settings,
        );
    }
  }

  static MaterialPageRoute _build(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
