/// Rutas de la API (el prefijo lo pone [ApiClient] con Env.apiBaseUrl).
class Endpoints {
  Endpoints._();

  // Auth
  static const login = '/auth/login';
  static const registro = '/auth/registro';
  static const refresh = '/auth/refresh-token';
  static const activar = '/auth/activar';
  static const recuperar = '/auth/recuperar';
  static const restablecer = '/auth/restablecer';

  // Mi cuenta
  static const yo = '/usuarios/me';
  static const miPassword = '/usuarios/me/password';
  static const miUbicacion = '/usuarios/me/ubicacion';
  static const misConsentimientos = '/usuarios/me/consentimientos';

  // Solicitudes de ayuda
  static const solicitudes = '/solicitudes-ayuda';
  static const sos = '/solicitudes-ayuda/sos';
  static String cancelarSolicitud(String id) => '/solicitudes-ayuda/$id/cancelar';

  // Reportes
  static const reportes = '/reportes';
  static const tiposReporte = '/reportes/tipos';
  static String reporte(String id) => '/reportes/$id';

  // Voluntario
  static const misAsignaciones = '/asignaciones/mias';
  static String asignacion(String id) => '/asignaciones/$id';
  static String tomarSolicitud(String id) => '/solicitudes-ayuda/$id/asignar';

  // Mapa en vivo
  static const mapa = '/mapa';
}
