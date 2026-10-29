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
  static const misContactos = '/usuarios/me/contactos-emergencia';
  static String miContacto(String id) => '/usuarios/me/contactos-emergencia/$id';
  static const misDatos = '/usuarios/me/datos';

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
  static String tomarReporte(String id) => '/reportes/$id/asignar';

  // Personas desaparecidas
  static const personas = '/personas-desaparecidas';
  static String persona(String id) => '/personas-desaparecidas/$id';
  static String estadoPersona(String id) => '/personas-desaparecidas/$id/estado';

  // Alertas por zona
  static const alertas = '/alertas';

  // Sismos y "¿Estás bien?" (check-ins)
  static const checkIns = '/check-ins';
  static const checkInPendiente = '/check-ins/pendiente';
  static String responderCheckIn(String id) => '/check-ins/$id/responder';

  // Modo sin conexión
  static const llaveOffline = '/usuarios/me/llave-offline';
  static const offlineSync = '/offline/sync';
  static const offlineRelevo = '/offline/relevo';

  // Guía de emergencia
  static const guia = '/guia-emergencia';

  // Mapa en vivo
  static const mapa = '/mapa';
}
