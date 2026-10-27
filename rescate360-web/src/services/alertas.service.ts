import { api, USE_MOCK } from './api'
import type { Alerta, NuevaAlerta } from '../types/alerta'

// Datos de prueba, SOLO para desarrollo de la interfaz.
let mock: Alerta[] = [
  { id: '1', tipo: 'inundacion', titulo: 'Alerta de inundación', descripcion: 'Crecida del río en la zona urbana. Evite acercarse a las orillas.', zona: 'Río y zona urbana', fecha: '2026-10-05T09:00:00', activa: true },
  { id: '2', tipo: 'deslizamiento', titulo: 'Riesgo de deslizamiento', descripcion: 'Terreno inestable en la vía al corregimiento. Se recomienda no transitar.', zona: 'Vía al corregimiento', fecha: '2026-10-05T07:30:00', activa: true },
  { id: '3', tipo: 'seguridad', titulo: 'Alerta de seguridad', descripcion: 'Aumento de robos en el sector centro durante la noche.', zona: 'Sector centro', fecha: '2026-10-04T20:00:00', activa: true },
  { id: '4', tipo: 'clima', titulo: 'Alerta de clima', descripcion: 'Lluvias fuertes previstas para las próximas horas en la región.', zona: 'Toda la región', fecha: '2026-10-03T15:00:00', activa: false },
  { id: '5', tipo: 'inundacion', titulo: 'Alerta de inundación', descripcion: 'Calles anegadas tras la tormenta. Ya fue superada.', zona: 'Barrio El Prado', fecha: '2026-10-01T10:00:00', activa: false },
]

export async function listarAlertas(): Promise<Alerta[]> {
  if (USE_MOCK) return mock.map((a) => ({ ...a }))

  // BACKEND: confirmar la ruta real y la forma de la respuesta.
  return api<Alerta[]>('/alertas')
}

export async function crearAlerta(datos: NuevaAlerta): Promise<Alerta> {
  if (USE_MOCK) {
    const nueva: Alerta = { ...datos, id: String(Date.now()), fecha: new Date().toISOString(), activa: true }
    mock = [nueva, ...mock]
    return { ...nueva }
  }

  // BACKEND: endpoint para publicar una alerta.
  return api<Alerta>('/alertas', { method: 'POST', body: JSON.stringify(datos) })
}

export async function finalizarAlerta(id: string): Promise<Alerta> {
  if (USE_MOCK) {
    mock = mock.map((a) => (a.id === id ? { ...a, activa: false } : a))
    const alerta = mock.find((a) => a.id === id)
    if (!alerta) throw new Error('Alerta no encontrada')
    return { ...alerta }
  }

  // BACKEND: endpoint para desactivar o cerrar una alerta.
  return api<Alerta>(`/alertas/${id}/finalizar`, { method: 'PATCH' })
}