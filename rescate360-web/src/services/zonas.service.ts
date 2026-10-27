import { api, USE_MOCK } from './api'
import type { Zona, DatosZona } from '../types/zona'

// Datos de prueba, SOLO para desarrollo de la interfaz.
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

  // BACKEND: confirmar la ruta real y la forma de la respuesta.
  // Si las zonas llegan como polígonos y no como círculo, hay que ajustar el tipo y el mapa.
  return api<Zona[]>('/zonas-peligrosas')
}

export async function crearZona(datos: DatosZona): Promise<Zona> {
  if (USE_MOCK) {
    const nueva: Zona = { ...datos, id: String(Date.now()) }
    mock = [nueva, ...mock]
    return { ...nueva }
  }

  // BACKEND: endpoint para crear una zona peligrosa.
  return api<Zona>('/zonas-peligrosas', { method: 'POST', body: JSON.stringify(datos) })
}

export async function actualizarZona(id: string, cambios: Partial<DatosZona>): Promise<Zona> {
  if (USE_MOCK) {
    mock = mock.map((z) => (z.id === id ? { ...z, ...cambios } : z))
    const actualizada = mock.find((z) => z.id === id)
    if (!actualizada) throw new Error('Zona no encontrada')
    return { ...actualizada }
  }

  // BACKEND: endpoint para editar una zona (incluye activar o desactivar con el estado).
  return api<Zona>(`/zonas-peligrosas/${id}`, { method: 'PATCH', body: JSON.stringify(cambios) })
}