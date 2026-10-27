import { api, USE_MOCK } from './api'
import type { Solicitud, CambiosSolicitud } from '../types/solicitud'

// Datos de prueba, SOLO para desarrollo de la interfaz.
let mock: Solicitud[] = [
  { id: '1', tipo: 'medica', descripcion: 'Adulto mayor con dificultad para respirar, necesita atención.', ubicacion: 'Barrio El Prado', solicitante: 'María López', telefono: '+57 300 111 2233', fecha: '2026-10-05T09:50:00', estado: 'pendiente', prioridadIA: 'alta', motivoIA: 'Posible emergencia respiratoria en persona vulnerable.', prioridadManual: null },
  { id: '2', tipo: 'refugio', descripcion: 'Familia de cinco personas sin vivienda tras la inundación.', ubicacion: 'Vereda La Esperanza', solicitante: 'Carlos Rojas', telefono: '+57 301 222 3344', fecha: '2026-10-05T08:30:00', estado: 'en_proceso', prioridadIA: 'media', motivoIA: 'Hay menores en el grupo, pero sin riesgo inmediato.', prioridadManual: 'alta' },
  { id: '3', tipo: 'alimentaria', descripcion: 'Se necesitan alimentos para una comunidad aislada por el derrumbe.', ubicacion: 'Vereda San José', solicitante: 'Lucía Herrera', telefono: '+57 302 333 4455', fecha: '2026-10-04T19:10:00', estado: 'pendiente', prioridadIA: 'media', motivoIA: 'Vía bloqueada, la necesidad crece con el tiempo.', prioridadManual: null },
  { id: '4', tipo: 'rescate', descripcion: 'Persona atrapada en un vehículo en una zona inundada.', ubicacion: 'Vía Nacional km 3', solicitante: 'Andrés Gómez', telefono: '+57 303 444 5566', fecha: '2026-10-05T10:05:00', estado: 'pendiente', prioridadIA: 'alta', motivoIA: 'Riesgo de vida por la crecida del agua.', prioridadManual: null },
  { id: '5', tipo: 'medica', descripcion: 'Herida leve por caída, requiere curación.', ubicacion: 'Cra. 19 #12-45', solicitante: 'Sofía Mora', telefono: '+57 304 555 6677', fecha: '2026-10-04T14:20:00', estado: 'atendida', prioridadIA: 'baja', motivoIA: 'Lesión leve sin signos de gravedad.', prioridadManual: null },
  { id: '6', tipo: 'otro', descripcion: 'Solicitud de apoyo para despejar un árbol caído.', ubicacion: 'Av. Simón Bolívar #45', solicitante: 'Pedro Díaz', telefono: '+57 305 666 7788', fecha: '2026-10-03T11:00:00', estado: 'cancelada', prioridadIA: 'baja', motivoIA: 'No hay personas en riesgo.', prioridadManual: null },
]

export async function listarSolicitudes(): Promise<Solicitud[]> {
  if (USE_MOCK) return mock.map((s) => ({ ...s }))

  // BACKEND: confirmar la ruta real, los filtros y la forma de la respuesta.
  return api<Solicitud[]>('/admin/solicitudes')
}

export async function actualizarSolicitud(id: string, cambios: CambiosSolicitud): Promise<Solicitud> {
  if (USE_MOCK) {
    mock = mock.map((s) => (s.id === id ? { ...s, ...cambios } : s))
    const actualizada = mock.find((s) => s.id === id)
    if (!actualizada) throw new Error('Solicitud no encontrada')
    return { ...actualizada }
  }

  // BACKEND: aquí van los endpoints para cambiar el estado y fijar la prioridad manual.
  // prioridadManual = null significa "volver a usar la sugerencia de la IA".
  return api<Solicitud>(`/admin/solicitudes/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(cambios),
  })
}