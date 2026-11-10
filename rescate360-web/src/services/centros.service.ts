import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { Centro, CentroApi, DatosCentro, EstadoCentro, TipoCentro } from '../types/centro'

export const aCentro = (c: CentroApi): Centro => ({
  id: c.id,
  nombre: c.nombre,
  tipo: (c.tipo as TipoCentro) ?? 'albergue',
  ubicacion: c.direccion ?? `${c.ubicacion.lat.toFixed(5)}, ${c.ubicacion.lng.toFixed(5)}`,
  estado: (c.estado as EstadoCentro) ?? 'activo',
  lat: c.ubicacion.lat,
  lng: c.ubicacion.lng,
  recursosDisponibles: c.recursos_disponibles,
})

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
let mock: Centro[] = [
  { id: '1', nombre: 'Colegio San José', tipo: 'albergue', ubicacion: 'Cra. 9 #14-30', estado: 'activo', lat: 10.4689, lng: -73.2551 },
  { id: '2', nombre: 'Refugio Municipal', tipo: 'albergue', ubicacion: 'Calle 16 #8-32', estado: 'activo', lat: 10.4602, lng: -73.2447 },
  { id: '3', nombre: 'Polideportivo Municipal', tipo: 'albergue', ubicacion: 'Av. Los Cortijos', estado: 'activo', lat: 10.4741, lng: -73.2386 },
  { id: '4', nombre: 'Centro de Acopio San José', tipo: 'centro_acopio', ubicacion: 'Calle 12 #8-45', estado: 'activo', lat: 10.4795, lng: -73.2634 },
  { id: '5', nombre: 'Iglesia San Martín', tipo: 'centro_acopio', ubicacion: 'Cra. 5 #10-12', estado: 'activo', lat: 10.4655, lng: -73.2513 },
  { id: '6', nombre: 'Hospital Rosario Pumarejo', tipo: 'puesto_medico', ubicacion: 'Cra. 12 #44-20', estado: 'activo', lat: 10.4512, lng: -73.2602 },
  { id: '7', nombre: 'Puesto de Salud El Prado', tipo: 'puesto_medico', ubicacion: 'Cra. 15 #11-30', estado: 'activo', lat: 10.4558, lng: -73.2611 },
  { id: '8', nombre: 'Comedor Comunitario Los Cortijos', tipo: 'comedor', ubicacion: 'Av. Los Cortijos #20-15', estado: 'en_operacion', lat: 10.4768, lng: -73.2409 },
  { id: '9', nombre: 'Comedor Popular Centro', tipo: 'comedor', ubicacion: 'Calle 15 #6-18', estado: 'inactivo', lat: 10.4701, lng: -73.2488 },
]

export async function listarCentros(): Promise<Centro[]> {
  if (USE_MOCK) return mock.map((c) => ({ ...c }))

  const pagina = await api<Pagina<CentroApi>>(`/centros-ayuda${consulta({ por_pagina: 100 })}`)
  return pagina.items.map(aCentro)
}

export async function crearCentro(datos: DatosCentro): Promise<Centro> {
  if (USE_MOCK) {
    const nuevo: Centro = { ...datos, id: String(Date.now()) }
    mock = [nuevo, ...mock]
    return { ...nuevo }
  }

  const payload = {
    nombre: datos.nombre,
    tipo: datos.tipo,
    estado: datos.estado,
    direccion: datos.ubicacion,
    lat: datos.lat,
    lng: datos.lng,
  }

  const respuesta = await api<CentroApi>('/centros-ayuda', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
  return aCentro(respuesta)
}

export async function actualizarCentro(id: string, cambios: Partial<DatosCentro>): Promise<Centro> {
  if (USE_MOCK) {
    mock = mock.map((c) => (c.id === id ? { ...c, ...cambios } : c))
    const actualizado = mock.find((c) => c.id === id)
    if (!actualizado) throw new Error('Centro no encontrado')
    return { ...actualizado }
  }

  const payload: Record<string, unknown> = {}
  if (cambios.nombre !== undefined) payload.nombre = cambios.nombre
  if (cambios.tipo !== undefined) payload.tipo = cambios.tipo
  if (cambios.estado !== undefined) payload.estado = cambios.estado
  if (cambios.ubicacion !== undefined) payload.direccion = cambios.ubicacion
  if (cambios.lat !== undefined) payload.lat = cambios.lat
  if (cambios.lng !== undefined) payload.lng = cambios.lng

  const respuesta = await api<CentroApi>(`/centros-ayuda/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(payload),
  })
  return aCentro(respuesta)
}
