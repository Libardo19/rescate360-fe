import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { Zona, ZonaApi, DatosZona, EstadoZona, NivelRiesgo, TipoRiesgo } from '../types/zona'

export const aZona = (z: ZonaApi): Zona => ({
  id: z.id,
  nombre: z.nombre,
  tipoRiesgo: (z.tipo_riesgo as TipoRiesgo) ?? 'otro',
  nivel: (z.nivel as NivelRiesgo) ?? 'medio',
  estado: (z.estado as EstadoZona) ?? 'activa',
  descripcion: z.descripcion ?? '',
  lat: z.zona.lat,
  lng: z.zona.lng,
  radio: z.zona.radio_m,
})

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
let mock: Zona[] = [
  { id: '1', nombre: 'Ribera del río, sector norte', tipoRiesgo: 'inundacion', nivel: 'alto', estado: 'activa', descripcion: 'Zona baja que se inunda con las crecidas del río.', lat: 10.4792, lng: -73.2561, radio: 700 },
  { id: '2', nombre: 'Ladera La Esperanza', tipoRiesgo: 'deslizamiento', nivel: 'alto', estado: 'activa', descripcion: 'Terreno inestable con antecedentes de derrumbes.', lat: 10.4905, lng: -73.2702, radio: 550 },
  { id: '3', nombre: 'Barrio El Prado (parte baja)', tipoRiesgo: 'inundacion', nivel: 'medio', estado: 'en_monitoreo', descripcion: 'Acumulación de agua en calles tras lluvias fuertes.', lat: 10.4558, lng: -73.2611, radio: 450 },
  { id: '4', nombre: 'Zona rural San Cristóbal', tipoRiesgo: 'deslizamiento', nivel: 'medio', estado: 'activa', descripcion: 'Vía con riesgo de caída de rocas en temporada de lluvias.', lat: 10.4421, lng: -73.2294, radio: 800 },
  { id: '5', nombre: 'Sector centro nocturno', tipoRiesgo: 'seguridad', nivel: 'bajo', estado: 'en_monitoreo', descripcion: 'Aumento de hurtos en horas de la noche.', lat: 10.4701, lng: -73.2488, radio: 350 },
  { id: '6', nombre: 'Pastizales del borde urbano', tipoRiesgo: 'incendio', nivel: 'medio', estado: 'inactiva', descripcion: 'Riesgo de incendio forestal en temporada seca.', lat: 10.4655, lng: -73.2386, radio: 600 },
]

export async function listarZonas(): Promise<Zona[]> {
  if (USE_MOCK) return mock.map((z) => ({ ...z }))

  const pagina = await api<Pagina<ZonaApi>>(`/zonas-peligrosas${consulta({ por_pagina: 100 })}`)
  return pagina.items.map(aZona)
}

export async function crearZona(datos: DatosZona): Promise<Zona> {
  if (USE_MOCK) {
    const nueva: Zona = { ...datos, id: String(Date.now()) }
    mock = [nueva, ...mock]
    return { ...nueva }
  }

  const payload = {
    nombre: datos.nombre,
    tipo_riesgo: datos.tipoRiesgo,
    nivel: datos.nivel,
    descripcion: datos.descripcion || null,
    estado: datos.estado,
    zona: {
      lat: datos.lat,
      lng: datos.lng,
      radio_m: datos.radio,
    },
  }

  const respuesta = await api<ZonaApi>('/zonas-peligrosas', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
  return aZona(respuesta)
}

export async function actualizarZona(id: string, cambios: Partial<DatosZona>): Promise<Zona> {
  if (USE_MOCK) {
    mock = mock.map((z) => (z.id === id ? { ...z, ...cambios } : z))
    const actualizada = mock.find((z) => z.id === id)
    if (!actualizada) throw new Error('Zona no encontrada')
    return { ...actualizada }
  }

  const payload: Record<string, unknown> = {}
  if (cambios.nombre !== undefined) payload.nombre = cambios.nombre
  if (cambios.tipoRiesgo !== undefined) payload.tipo_riesgo = cambios.tipoRiesgo
  if (cambios.nivel !== undefined) payload.nivel = cambios.nivel
  if (cambios.descripcion !== undefined) payload.descripcion = cambios.descripcion || null
  if (cambios.estado !== undefined) payload.estado = cambios.estado
  if (cambios.lat !== undefined && cambios.lng !== undefined && cambios.radio !== undefined) {
    payload.zona = {
      lat: cambios.lat,
      lng: cambios.lng,
      radio_m: cambios.radio,
    }
  }

  const respuesta = await api<ZonaApi>(`/zonas-peligrosas/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(payload),
  })
  return aZona(respuesta)
}
