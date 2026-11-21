import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/env.dart';

class LandingActions {
  LandingActions._();

  static const rutaInicio = '/';
  static const rutaComoFunciona = '/como-funciona';
  static const rutaCiudadanos = '/ciudadanos';
  static const rutaOrganizaciones = '/organizaciones';
  static const rutaLogin = '/login';
  static const rutaRegistro = '/registro';

  /// Navega a [ruta] salvo que ya estemos en ella.
  static void ir(BuildContext context, String ruta) {
    if (ModalRoute.of(context)?.settings.name == ruta) return;
    Navigator.of(context).pushNamed(ruta);
  }

  /// Abre el marcador con la línea de emergencias (123).
  static Future<void> llamar123() =>
      launchUrl(Uri(scheme: 'tel', path: Env.emergencyLine));

  /// Provisional: reemplazar por launchUrl(...) cuando exista el APK o la tienda.
  static void descargarApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pronto: el enlace de descarga estará disponible cuando la app esté publicada.',
        ),
      ),
    );
  }
}
