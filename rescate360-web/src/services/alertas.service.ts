import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { Alerta, AlertaApi, NuevaAlerta, TipoAlerta } from '../types/alerta'

export const aAlerta = (a: AlertaApi): Alerta => {
  const radioKm = (a.zona.radio_m / 1000).toFixed(1)
  return {
    id: a.id,
    tipo: (a.tipo as TipoAlerta) ?? 'otro',
    titulo: a.titulo,
    descripcion: a.mensaje,
    zona: `Radio de ${radioKm} km (${a.zona.lat.toFixed(4)}, ${a.zona.lng.toFixed(4)})`,
    lat: a.zona.lat,
    lng: a.zona.lng,
    radio_m: a.zona.radio_m,
    fecha: a.creado_en,
    activa: a.estado === 'activa',
    nivel: a.nivel,
  }
}

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
let mock: Alerta[] = [
  { id: '1', tipo: 'inundacion', titulo: 'Alerta de inundación', descripcion: 'Crecida del río en la zona urbana. Evite acercarse a las orillas.', zona: 'Río y zona urbana', fecha: '2026-10-05T09:00:00', activa: true },
  { id: '2', tipo: 'deslizamiento', titulo: 'Riesgo de deslizamiento', descripcion: 'Terreno inestable en la vía al corregimiento. Se recomienda no transitar.', zona: 'Vía al corregimiento', fecha: '2026-10-05T07:30:00', activa: true },
  { id: '3', tipo: 'seguridad', titulo: 'Alerta de seguridad', descripcion: 'Aumento de robos en el sector centro durante la noche.', zona: 'Sector centro', fecha: '2026-10-04T20:00:00', activa: true },
  { id: '4', tipo: 'clima', titulo: 'Alerta de clima', descripcion: 'Lluvias fuertes previstas para las próximas horas en la región.', zona: 'Toda la región', fecha: '2026-10-03T15:00:00', activa: false },
  { id: '5', tipo: 'inundacion', titulo: 'Alerta de inundación', descripcion: 'Calles anegadas tras la tormenta. Ya fue superada.', zona: 'Barrio El Prado', fecha: '2026-10-01T10:00:00', activa: false },
]

export async function listarAlertas(): Promise<Alerta[]> {
  if (USE_MOCK) return mock.map((a) => ({ ...a }))

  const pagina = await api<Pagina<AlertaApi>>(`/alertas${consulta({ por_pagina: 100 })}`)
  return pagina.items.map(aAlerta)
}

export async function crearAlerta(datos: NuevaAlerta): Promise<Alerta> {
  if (USE_MOCK) {
    const nueva: Alerta = { ...datos, id: String(Date.now()), fecha: new Date().toISOString(), activa: true }
    mock = [nueva, ...mock]
    return { ...nueva }
  }

  const payload = {
    titulo: datos.titulo,
    tipo: datos.tipo,
    mensaje: datos.descripcion,
    nivel: 'medio',
    zona: {
      lat: datos.lat ?? 10.4631,
      lng: datos.lng ?? -73.2532,
      radio_m: datos.radio_m ?? 5000,
    },
    horas_vigencia: datos.horas_vigencia ?? 24,
  }

  const respuesta = await api<AlertaApi>('/alertas', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
  return aAlerta(respuesta)
}

export async function finalizarAlerta(id: string): Promise<Alerta> {
  if (USE_MOCK) {
    mock = mock.map((a) => (a.id === id ? { ...a, activa: false } : a))
    const alerta = mock.find((a) => a.id === id)
    if (!alerta) throw new Error('Alerta no encontrada')
    return { ...alerta }
  }

  // En el backend el endpoint para desactivar/cerrar una alerta es POST /alertas/{id}/cancelar
  const respuesta = await api<AlertaApi>(`/alertas/${id}/cancelar`, { method: 'POST' })
  return aAlerta(respuesta)
}
