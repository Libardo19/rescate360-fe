import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { Solicitud, SolicitudApi, CambiosSolicitud } from '../types/solicitud'

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
const base = { origen: 'manual', lat: 10.4631, lng: -73.2532, organizacionId: null } as const
let mock: Solicitud[] = [
  { ...base, id: '1', tipo: 'medica', descripcion: 'Adulto mayor con dificultad para respirar, necesita atención.', ubicacion: 'Barrio El Prado', solicitante: 'María López', telefono: '+57 300 111 2233', fecha: '2026-10-05T09:50:00', estado: 'pendiente', prioridadIA: 'alta', motivoIA: 'Posible emergencia respiratoria en persona vulnerable.', prioridadManual: null },
  { ...base, id: '2', tipo: 'refugio', descripcion: 'Familia de cinco personas sin vivienda tras la inundación.', ubicacion: 'Vereda La Esperanza', solicitante: 'Carlos Rojas', telefono: '+57 301 222 3344', fecha: '2026-10-05T08:30:00', estado: 'en_proceso', prioridadIA: 'media', motivoIA: 'Hay menores en el grupo, pero sin riesgo inmediato.', prioridadManual: 'alta' },
  { ...base, id: '3', tipo: 'rescate', origen: 'sos', descripcion: 'Solicitud de emergencia (SOS)', ubicacion: '10.46310, -73.25320', solicitante: 'Andrés Gómez', telefono: '+57 303 444 5566', fecha: '2026-10-05T10:05:00', estado: 'pendiente', prioridadIA: 'critica', motivoIA: 'SOS: nace con prioridad crítica.', prioridadManual: null },
  { ...base, id: '4', tipo: 'alimentaria', descripcion: 'Se necesitan alimentos para una comunidad aislada por el derrumbe.', ubicacion: 'Vereda San José', solicitante: 'Lucía Herrera', telefono: '+57 302 333 4455', fecha: '2026-10-04T19:10:00', estado: 'pendiente', prioridadIA: 'pendiente', motivoIA: '', prioridadManual: null },
]

const SIN_IA = 'La IA todavía no ha clasificado esta solicitud.'

// Del contrato del backend (snake_case) al modelo de la pantalla
export const aSolicitud = (s: SolicitudApi): Solicitud => ({
  id: s.id,
  tipo: s.tipo,
  origen: s.origen,
  descripcion: s.descripcion,
  ubicacion: s.direccion ?? `${s.ubicacion.lat.toFixed(5)}, ${s.ubicacion.lng.toFixed(5)}`,
  lat: s.ubicacion.lat,
  lng: s.ubicacion.lng,
  solicitante: s.solicitante?.nombre ?? '—',
  telefono: s.solicitante?.telefono ?? '—',
  fecha: s.creado_en,
  estado: s.estado,
  prioridadIA: s.prioridad_ia,
  motivoIA: s.razonamiento_ia ?? (s.origen === 'sos' ? 'SOS: nace con prioridad crítica.' : SIN_IA),
  prioridadManual: s.prioridad_manual,
  organizacionId: s.organizacion_manual_id ?? s.organizacion_objetivo_id,
})

// El backend pagina; la pantalla filtra y ordena en el navegador, así que trae la página más grande.
// El administrador recibe las de su organización; el super admin, todas.
export async function listarSolicitudes(): Promise<Solicitud[]> {
  if (USE_MOCK) return mock.map((s) => ({ ...s }))
  const pagina = await api<Pagina<SolicitudApi>>(`/solicitudes-ayuda${consulta({ por_pagina: 100 })}`)
  return pagina.items.map(aSolicitud)
}

// El backend tiene un endpoint por cambio: PATCH /{id}/estado y PATCH /{id}/prioridad
export async function actualizarSolicitud(id: string, cambios: CambiosSolicitud): Promise<Solicitud> {
  if (USE_MOCK) {
    mock = mock.map((s) => (s.id === id ? { ...s, ...cambios } : s))
    const actualizada = mock.find((s) => s.id === id)
    if (!actualizada) throw new Error('Solicitud no encontrada')
    return { ...actualizada }
  }
  let respuesta: SolicitudApi | null = null
  if (cambios.prioridadManual) {
    respuesta = await api<SolicitudApi>(`/solicitudes-ayuda/${id}/prioridad`, {
      method: 'PATCH',
      body: JSON.stringify({ prioridad_manual: cambios.prioridadManual }),
    })
  }
  if (cambios.estado) {
    respuesta = await api<SolicitudApi>(`/solicitudes-ayuda/${id}/estado`, {
      method: 'PATCH',
      body: JSON.stringify({ estado: cambios.estado }),
    })
  }
  if (!respuesta) throw new Error('No hay cambios para guardar')
  return aSolicitud(respuesta)
}

// Solo el super admin: si la IA no enrutó el caso, así se asigna a mano a una organización
export async function asignarOrganizacion(id: string, organizacionId: string): Promise<Solicitud> {
  if (USE_MOCK) {
    mock = mock.map((s) => (s.id === id ? { ...s, organizacionId } : s))
    return { ...mock.find((s) => s.id === id)! }
  }
  const respuesta = await api<SolicitudApi>(`/solicitudes-ayuda/${id}/organizacion`, {
    method: 'PATCH',
    body: JSON.stringify({ organizacion_id: organizacionId }),
  })
  return aSolicitud(respuesta)
}
