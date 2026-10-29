import 'package:flutter/widgets.dart';

/// Textos de las pantallas traducidas (español e inglés).
/// Uso: context.t('clave'). Si falta una clave en un idioma, usa el español.
class Textos {
  Textos._();

  static String de(String idioma, String clave) {
    return _datos[idioma]?[clave] ?? _datos['es']?[clave] ?? clave;
  }

  static const Map<String, Map<String, String>> _datos = {
    'es': {
      // Configuración
      'cfg_titulo': 'Configuración',
      'cfg_seccion_apariencia': 'Apariencia',
      'cfg_seccion_preferencias': 'Preferencias',
      'cfg_seccion_legal': 'Legal',
      'cfg_tema_claro': 'Claro',
      'cfg_tema_oscuro': 'Oscuro',
      'cfg_tema_sistema': 'Auto',
      'cfg_tema_ayuda': 'Auto sigue la apariencia de tu celular.',
      'cfg_idioma': 'Idioma',
      'cfg_elige_idioma': 'Elige el idioma',
      'cfg_notif': 'Notificaciones',
      'cfg_notif_sub': 'Alertas, reportes y actualizaciones',
      'cfg_ubicacion': 'Ubicación',
      'cfg_ubicacion_sub': 'Permisos de ubicación de la app',
      'cfg_sin_conexion': 'Modo sin conexión',
      'cfg_sin_conexion_sub': 'Pasar mensajes de emergencia por Bluetooth',
      'cfg_ubicacion_web': 'Esta opción solo funciona en el celular.',
      'cfg_privacidad': 'Privacidad',
      'cfg_privacidad_sub': 'Política de privacidad y datos',
      'cfg_terminos': 'Términos y condiciones',
      'cfg_legal_aviso':
          'Texto de ejemplo. El equipo debe revisarlo antes de publicar la app.',
      'legal_priv_1':
          'RESCATE360 usa tu ubicación para mostrar el mapa y ubicar tus reportes y solicitudes de ayuda.',
      'legal_priv_2':
          'Las fotos y videos que adjuntas se usan para documentar tus reportes.',
      'legal_priv_3':
          'Tus datos de contacto solo se comparten en los reportes que decides publicar.',
      'legal_term_1':
          'Usa la app de forma responsable: un reporte falso puede afectar a otras personas.',
      'legal_term_2': 'En una emergencia real, llama primero a la línea 123.',
      'legal_term_3':
          'Los administradores pueden revisar, editar o retirar reportes que incumplan las normas.',
      // Notificaciones
      'not_titulo': 'Notificaciones',
      'not_comunidad': 'Alertas de la comunidad',
      'not_comunidad_sub': 'Incidentes, zonas de riesgo, etc.',
      'not_reportes': 'Mis reportes',
      'not_reportes_sub': 'Cambios de estado y actualizaciones',
      'not_solicitudes': 'Solicitudes de ayuda',
      'not_solicitudes_sub': 'Cerca de mi ubicación',
      'not_importantes': 'Mensajes importantes',
      'not_importantes_sub': 'Comunicados de autoridades',
      'not_aviso':
          'Tus preferencias se guardan en este celular. Las notificaciones llegarán cuando el backend empiece a enviarlas.',
    },
    'en': {
      // Settings
      'cfg_titulo': 'Settings',
      'cfg_seccion_apariencia': 'Appearance',
      'cfg_seccion_preferencias': 'Preferences',
      'cfg_seccion_legal': 'Legal',
      'cfg_tema_claro': 'Light',
      'cfg_tema_oscuro': 'Dark',
      'cfg_tema_sistema': 'Auto',
      'cfg_tema_ayuda': 'Auto follows your phone appearance.',
      'cfg_idioma': 'Language',
      'cfg_elige_idioma': 'Choose a language',
      'cfg_notif': 'Notifications',
      'cfg_notif_sub': 'Alerts, reports and updates',
      'cfg_ubicacion': 'Location',
      'cfg_ubicacion_sub': 'App location permissions',
      'cfg_sin_conexion': 'Offline mode',
      'cfg_sin_conexion_sub': 'Relay emergency messages over Bluetooth',
      'cfg_ubicacion_web': 'This option only works on the phone.',
      'cfg_privacidad': 'Privacy',
      'cfg_privacidad_sub': 'Privacy policy and data',
      'cfg_terminos': 'Terms and conditions',
      'cfg_legal_aviso':
          'Sample text. The team must review it before publishing the app.',
      'legal_priv_1':
          'RESCATE360 uses your location to show the map and place your reports and help requests.',
      'legal_priv_2':
          'The photos and videos you attach are used to document your reports.',
      'legal_priv_3':
          'Your contact details are only shared in the reports you choose to publish.',
      'legal_term_1':
          'Use the app responsibly: a false report can affect other people.',
      'legal_term_2': 'In a real emergency, call 123 first.',
      'legal_term_3':
          'Administrators may review, edit or remove reports that break the rules.',
      // Notifications
      'not_titulo': 'Notifications',
      'not_comunidad': 'Community alerts',
      'not_comunidad_sub': 'Incidents, risk areas, etc.',
      'not_reportes': 'My reports',
      'not_reportes_sub': 'Status changes and updates',
      'not_solicitudes': 'Help requests',
      'not_solicitudes_sub': 'Near my location',
      'not_importantes': 'Important messages',
      'not_importantes_sub': 'Announcements from authorities',
      'not_aviso':
          'Your preferences are saved on this phone. Notifications will arrive once the backend starts sending them.',
    },
  };
}

extension TextosContexto on BuildContext {
  /// Texto traducido según el idioma elegido en Configuración.
  String t(String clave) =>
      Textos.de(Localizations.localeOf(this).languageCode, clave);
}
