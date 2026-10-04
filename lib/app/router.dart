import 'package:flutter/material.dart';
import '../features/auth/presentation/views/bienvenida_screen.dart';
import '../features/auth/presentation/views/login_screen.dart';
import '../features/auth/presentation/views/registro_screen.dart';
import '../features/home/presentation/views/principal_screen.dart';

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
