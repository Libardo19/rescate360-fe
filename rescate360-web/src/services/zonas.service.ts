import { api, USE_MOCK } from './api'
import type { EstadoZona, NuevaZona, ZonaPeligrosa } from '../types/zona'

// Datos de prueba, SOLO para desarrollo de la interfaz.
let mock: ZonaPeligrosa[] = [
  { id: '1', tipoRiesgo: 'inundacion', estado: 'activa', gestionadoPor: 'Admin Demo', actualizadoEn: '2026-10-05T08:40:00', area: [[10.48, -73.27], [10.483, -73.262], [10.476, -73.259], [10.473, -73.267]] },
  { id: '2', tipoRiesgo: 'deslizamiento', estado: 'activa', gestionadoPor: 'Admin Demo', actualizadoEn: '2026-10-05T07:15:00', area: [[10.492, -73.274], [10.495, -73.269], [10.49, -73.266], [10.488, -73.272]] },
  { id: '3', tipoRiesgo: 'inseguridad', estado: 'activa', gestionadoPor: 'Admin Demo', actualizadoEn: '2026-10-04T21:00:00', area: [[10.469, -73.253], [10.471, -73.249], [10.467, -73.247], [10.465, -73.251]] },
  { id: '4', tipoRiesgo: 'inundacion', estado: 'resuelta', gestionadoPor: 'Admin Demo', actualizadoEn: '2026-10-02T16:30:00', area: [[10.457, -73.264], [10.459, -73.259], [10.454, -73.258], [10.453, -73.262]] },
]

export async function listarZonas(): Promise<ZonaPeligrosa[]> {
  if (USE_MOCK) return mock.map((z) => ({ ...z }))

  // BACKEND: confirmar la ruta real. `area` llega como lista de [lat, lng]
  // (o GeoJSON, en cuyo caso hay que convertirlo aquí; ojo: GeoJSON usa [lng, lat]).
  return api<ZonaPeligrosa[]>('/admin/zonas-peligrosas')
}

export async function crearZona(datos: NuevaZona): Promise<ZonaPeligrosa> {
  if (USE_MOCK) {
    const nueva: ZonaPeligrosa = {
      ...datos,
      id: String(Date.now()),
      estado: 'activa',
      gestionadoPor: 'Admin Demo',
      actualizadoEn: new Date().toISOString(),
    }
    mock = [nueva, ...mock]
    return { ...nueva }
  }

  // BACKEND: endpoint para crear una zona. gestionado_por lo pone el backend con el usuario del token.
  return api<ZonaPeligrosa>('/admin/zonas-peligrosas', { method: 'POST', body: JSON.stringify(datos) })
}

export async function cambiarEstadoZona(id: string, estado: EstadoZona): Promise<ZonaPeligrosa> {
  if (USE_MOCK) {
    mock = mock.map((z) => (z.id === id ? { ...z, estado, actualizadoEn: new Date().toISOString() } : z))
    const zona = mock.find((z) => z.id === id)
    if (!zona) throw new Error('Zona no encontrada')
    return { ...zona }
  }

  // BACKEND: endpoint para marcar una zona como resuelta o volver a activarla.
  return api<ZonaPeligrosa>(`/admin/zonas-peligrosas/${id}`, { method: 'PATCH', body: JSON.stringify({ estado }) })
}
