import { api, USE_MOCK } from './api'
import { organizacionEfectiva, type Solicitud, type CambiosSolicitud } from '../types/solicitud'

// Organización del administrador de prueba (admin@demo.com).
const ORG_MOCK = 'org-1'

// Datos de prueba, SOLO para desarrollo de la interfaz.
let mock: Solicitud[] = [
  { id: '1', descripcion: 'Adulto mayor con dificultad para respirar, necesita atención médica.', ubicacion: 'Barrio El Prado', solicitante: 'María López', telefono: '+57 300 111 2233', fecha: '2026-10-05T09:50:00', origen: 'manual', estado: 'pendiente', prioridadIA: 'critica', confianzaIA: 0.91, motivoIA: 'Posible emergencia respiratoria en persona vulnerable.', prioridadManual: null, organizacionObjetivoId: 'org-1', organizacionManualId: null },
  { id: '2', descripcion: 'Familia de cinco personas sin vivienda tras la inundación.', ubicacion: 'Vereda La Esperanza', solicitante: 'Carlos Rojas', telefono: '+57 301 222 3344', fecha: '2026-10-05T08:30:00', origen: 'manual', estado: 'en_atencion', prioridadIA: 'media', confianzaIA: 0.74, motivoIA: 'Hay menores en el grupo, pero sin riesgo inmediato.', prioridadManual: 'alta', organizacionObjetivoId: 'org-1', organizacionManualId: null },
  { id: '3', descripcion: 'Se necesitan alimentos para una comunidad aislada por el derrumbe.', ubicacion: 'Vereda San José', solicitante: 'Lucía Herrera', telefono: '+57 302 333 4455', fecha: '2026-10-04T19:10:00', origen: 'manual', estado: 'pendiente', prioridadIA: 'media', confianzaIA: 0.68, motivoIA: 'Vía bloqueada, la necesidad crece con el tiempo.', prioridadManual: null, organizacionObjetivoId: 'org-1', organizacionManualId: null },
  { id: '4', descripcion: 'Persona atrapada en un vehículo en una zona inundada.', ubicacion: 'Vía Nacional km 3', solicitante: 'Andrés Gómez', telefono: '+57 303 444 5566', fecha: '2026-10-05T10:05:00', origen: 'manual', estado: 'pendiente', prioridadIA: 'alta', confianzaIA: 0.88, motivoIA: 'Riesgo de vida por la crecida del agua.', prioridadManual: null, organizacionObjetivoId: 'org-1', organizacionManualId: null },
  { id: '5', descripcion: 'Detección automática de caída fuerte. El usuario no respondió a la confirmación.', ubicacion: 'Cra. 19 #12-45', solicitante: 'Sofía Mora', telefono: '+57 304 555 6677', fecha: '2026-10-05T10:22:00', origen: 'acelerometro', estado: 'pendiente', prioridadIA: 'pendiente', confianzaIA: null, motivoIA: 'La IA todavía no ha clasificado esta solicitud.', prioridadManual: null, organizacionObjetivoId: 'org-1', organizacionManualId: null },
  { id: '6', descripcion: 'Herida leve por caída, requiere curación.', ubicacion: 'Calle 7 #3-10', solicitante: 'Pedro Díaz', telefono: '+57 305 666 7788', fecha: '2026-10-04T14:20:00', origen: 'manual', estado: 'resuelta', prioridadIA: 'baja', confianzaIA: 0.83, motivoIA: 'Lesión leve sin signos de gravedad.', prioridadManual: null, organizacionObjetivoId: 'org-1', organizacionManualId: null },
]

export async function listarSolicitudes(): Promise<Solicitud[]> {
  // En el mock se imita el filtro del backend: una solicitud reasignada a otra organización deja de verse.
  if (USE_MOCK) return mock.filter((s) => organizacionEfectiva(s) === ORG_MOCK).map((s) => ({ ...s }))

  // BACKEND: confirmar la ruta real, los filtros y la forma de la respuesta.
  // Debe devolver SOLO las solicitudes cuya organización efectiva
  // (organizacion_manual_id, o si es NULL organizacion_objetivo_id) es la del administrador.
  return api<Solicitud[]>('/admin/solicitudes')
}

export async function actualizarSolicitud(id: string, cambios: CambiosSolicitud): Promise<Solicitud> {
  if (USE_MOCK) {
    mock = mock.map((s) => (s.id === id ? { ...s, ...cambios } : s))
    const actualizada = mock.find((s) => s.id === id)
    if (!actualizada) throw new Error('Solicitud no encontrada')
    return { ...actualizada }
  }

  // BACKEND: aquí van los endpoints para cambiar el estado, fijar la prioridad manual
  // y reasignar la organización (organizacion_manual_id). El backend guarda modificado_por.
  // prioridadManual = null significa "volver a usar la sugerencia de la IA".
  return api<Solicitud>(`/admin/solicitudes/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(cambios),
  })
}
