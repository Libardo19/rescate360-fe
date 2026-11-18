import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rescate360/features/landing/views/landing_screen.dart';
import '../features/alertas/presentation/views/alertas_screen.dart';
import '../features/auth/presentation/views/activar_cuenta_screen.dart';
import '../features/auth/presentation/views/bienvenida_screen.dart';
import '../features/auth/presentation/views/login_screen.dart';
import '../features/auth/presentation/views/recuperar_contrasena_screen.dart';
import '../features/auth/presentation/views/registro_screen.dart';
import '../features/centros_ayuda/presentation/views/centros_ayuda_screen.dart';
import '../features/donaciones/presentation/views/donaciones_screen.dart';
import '../features/guia_emergencia/presentation/views/guia_emergencia_screen.dart';
import '../features/home/presentation/views/principal_screen.dart';
import '../features/home/presentation/views/sos_screen.dart';
import '../features/perfil/presentation/views/configuracion_screen.dart';
import '../features/perfil/presentation/views/mi_perfil_screen.dart';
import '../features/perfil/presentation/views/contactos_emergencia_screen.dart';
import '../features/perfil/presentation/views/notificaciones_screen.dart';
import '../features/perfil/presentation/views/privacidad_datos_screen.dart';
import '../features/personas_desaparecidas/presentation/views/personas_desaparecidas_screen.dart';
import '../features/reportes/presentation/views/reportar_incidente_screen.dart';
import '../features/solicitudes_ayuda/presentation/views/mis_solicitudes_screen.dart';
import '../features/voluntario/presentation/views/voluntario_screen.dart';
import '../features/solicitudes_ayuda/presentation/views/solicitar_ayuda_screen.dart';

/// Rutas nombradas de la app.
/// Navegación inicial (según lo pedido):
///   Bienvenida -> Login -> Home
///   Bienvenida -> Registro -> Home
class AppRouter {
  AppRouter._();

  /// Permite navegar sin context (p. ej. volver al inicio cuando vence la sesión).
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const inicial = '/';
  static const login = '/login';
  static const registro = '/registro';
  static const activar = '/activar';
  static const recuperar = '/recuperar';
  static const home = '/home';
  static const voluntario = '/voluntario';
  static const reportarIncidente = '/reportar-incidente';
  static const personasDesaparecidas = '/personas-desaparecidas';
  static const solicitarAyuda = '/solicitar-ayuda';
  static const misSolicitudes = '/mis-solicitudes';
  static const alertas = '/alertas';
  static const sos = '/sos';
  static const contactosEmergencia = '/contactos-emergencia';
  static const configuracion = '/configuracion';
  static const miPerfil = '/mi-perfil';
  static const privacidadDatos = '/privacidad-datos';
  static const notificaciones = '/notificaciones';
  static const guiaEmergencia = '/guia-emergencia';
  static const donaciones = '/donaciones';
  static const centrosAyuda = '/centros-ayuda';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case inicial:
        // En la web se abre la landing; en el móvil, la bienvenida.
        return _build(kIsWeb ? const LandingScreen() : const BienvenidaScreen(), settings);
      case login:
        return _build(const LoginScreen(), settings);
      case registro:
        return _build(const RegistroScreen(), settings);
      case activar:
        return _build(const ActivarCuentaScreen(), settings);
      case recuperar:
        return _build(RecuperarContrasenaScreen(correoInicial: settings.arguments as String?), settings);
      case home:
        return _build(const PrincipalScreen(), settings);
      case voluntario:
        return _build(const VoluntarioScreen(), settings);
      case reportarIncidente:
        return _build(const ReportarIncidenteScreen(), settings);
      case personasDesaparecidas:
        return _build(const PersonasDesaparecidasScreen(), settings);
      case solicitarAyuda:
        return _build(const SolicitarAyudaScreen(), settings);
      case misSolicitudes:
        return _build(const MisSolicitudesScreen(), settings);
      case alertas:
        return _build(const AlertasScreen(), settings);
      case sos:
        return _build(const SosScreen(), settings);
      case contactosEmergencia:
        return _build(const ContactosEmergenciaScreen(), settings);
      case configuracion:
        return _build(const ConfiguracionScreen(), settings);
      case miPerfil:
        return _build(const MiPerfilScreen(), settings);
      case privacidadDatos:
        return _build(const PrivacidadDatosScreen(), settings);
      case notificaciones:
        return _build(const NotificacionesScreen(), settings);
      case guiaEmergencia:
        return _build(const GuiaEmergenciaScreen(), settings);
      case donaciones:
        return _build(const DonacionesScreen(), settings);
      case centrosAyuda:
        return _build(const CentrosAyudaScreen(), settings);
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
