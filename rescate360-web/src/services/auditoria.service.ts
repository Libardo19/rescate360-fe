import { api, USE_MOCK } from './api'
import type { EventoAuditoria } from '../types/auditoria'

// Datos de prueba inventados, SOLO para desarrollo de la interfaz.
const MOCK: EventoAuditoria[] = [
  { id: '1', fecha: '2026-10-08T10:24:00', usuario: 'Admin Demo', accion: 'Inició sesión', tipo: 'acceso', modulo: 'acceso', detalle: 'Inicio de sesión en el panel', ip: '192.168.1.10' },
  { id: '2', fecha: '2026-10-08T09:52:00', usuario: 'Marta Salcedo', accion: 'Creó reporte', tipo: 'cambio', modulo: 'reportes', detalle: 'Reporte de accidente en Calle 10', ip: '192.168.1.21' },
  { id: '3', fecha: '2026-10-08T09:18:00', usuario: 'Carlos Peñaranda', accion: 'Actualizó solicitud', tipo: 'cambio', modulo: 'solicitudes', detalle: 'Estado cambiado a "En proceso"', ip: '192.168.1.33' },
  { id: '4', fecha: '2026-10-08T08:45:00', usuario: 'Laura Mejía', accion: 'Añadió usuario', tipo: 'cambio', modulo: 'usuarios', detalle: 'Nuevo voluntario invitado', ip: '192.168.1.45' },
  { id: '5', fecha: '2026-10-07T21:12:00', usuario: 'Admin Demo', accion: 'Eliminó zona peligrosa', tipo: 'cambio', modulo: 'zonas', detalle: 'Zona: Pastizales del borde urbano', ip: '192.168.1.10' },
  { id: '6', fecha: '2026-10-07T18:43:00', usuario: 'Daniela Torres', accion: 'Descargó reporte', tipo: 'acceso', modulo: 'reportes', detalle: 'Resumen semanal de incidencias', ip: '192.168.1.18' },
  { id: '7', fecha: '2026-10-07T17:05:00', usuario: 'Desconocido', accion: 'Intento de acceso fallido', tipo: 'error', modulo: 'acceso', detalle: 'Contraseña incorrecta (3 intentos)', ip: '10.0.0.77' },
  { id: '8', fecha: '2026-10-07T16:30:00', usuario: 'Marta Salcedo', accion: 'Verificó reporte', tipo: 'cambio', modulo: 'reportes', detalle: 'Reporte de inundación confirmado', ip: '192.168.1.21' },
  { id: '9', fecha: '2026-10-07T15:12:00', usuario: 'Admin Demo', accion: 'Publicó alerta', tipo: 'cambio', modulo: 'alertas', detalle: 'Alerta de inundación en zona urbana', ip: '192.168.1.10' },
  { id: '10', fecha: '2026-10-07T14:20:00', usuario: 'Carlos Peñaranda', accion: 'Inició sesión', tipo: 'acceso', modulo: 'acceso', detalle: 'Inicio de sesión en el panel', ip: '192.168.1.33' },
  { id: '11', fecha: '2026-10-07T12:40:00', usuario: 'Sistema', accion: 'Error al enviar notificación', tipo: 'error', modulo: 'alertas', detalle: 'Tiempo de espera agotado en el servicio de envío', ip: '127.0.0.1' },
  { id: '12', fecha: '2026-10-07T11:02:00', usuario: 'Laura Mejía', accion: 'Registró centro de ayuda', tipo: 'cambio', modulo: 'centros', detalle: 'Centro de Acopio San José', ip: '192.168.1.45' },
  { id: '13', fecha: '2026-10-06T19:30:00', usuario: 'Admin Demo', accion: 'Cambió prioridad', tipo: 'cambio', modulo: 'solicitudes', detalle: 'Prioridad manual: Alta (la IA sugería Media)', ip: '192.168.1.10' },
  { id: '14', fecha: '2026-10-06T16:48:00', usuario: 'Daniela Torres', accion: 'Inició sesión', tipo: 'acceso', modulo: 'acceso', detalle: 'Inicio de sesión en el panel', ip: '192.168.1.18' },
  { id: '15', fecha: '2026-10-06T10:15:00', usuario: 'Marta Salcedo', accion: 'Actualizó estado de caso', tipo: 'cambio', modulo: 'desaparecidos', detalle: 'Caso marcado como encontrada', ip: '192.168.1.21' },
  { id: '16', fecha: '2026-10-05T20:00:00', usuario: 'Sistema', accion: 'Error de sincronización', tipo: 'error', modulo: 'donaciones', detalle: 'No se pudo actualizar el avance de la campaña', ip: '127.0.0.1' },
  { id: '17', fecha: '2026-10-05T13:25:00', usuario: 'Admin Demo', accion: 'Creó campaña', tipo: 'cambio', modulo: 'donaciones', detalle: 'Campaña: Ropa y abrigo', ip: '192.168.1.10' },
  { id: '18', fecha: '2026-10-04T09:40:00', usuario: 'Carlos Peñaranda', accion: 'Bloqueó usuario', tipo: 'cambio', modulo: 'usuarios', detalle: 'Cuenta suspendida por inactividad', ip: '192.168.1.33' },
]

export async function listarEventos(): Promise<EventoAuditoria[]> {
  if (USE_MOCK) return MOCK.map((e) => ({ ...e }))

  // BACKEND: confirmar la ruta real. Con miles de eventos conviene que el filtrado
  // (fechas, tipo, usuario, módulo) y la paginación los haga el servidor, no el navegador.
  // El administrador solo debe recibir eventos de su propia organización.
  return api<EventoAuditoria[]>('/auditoria')
}