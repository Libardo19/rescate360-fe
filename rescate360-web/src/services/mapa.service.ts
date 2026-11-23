import { api, consulta, USE_MOCK } from './api'
import type { MapaOut, PuntoMapa } from '../types/mapa'

const punto = (p: Pick<PuntoMapa, 'id' | 'capa' | 'titulo' | 'detalle' | 'estado' | 'lat' | 'lng'>): PuntoMapa => ({
  ...p,
  tipo: p.capa,
  prioridad: null,
  radio_m: null,
  aproximada: false,
  propio: true,
  activo: true,
  actualizado_en: '2026-10-05T10:00:00',
})

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
const MOCK: PuntoMapa[] = [
  punto({ id: 'r1', capa: 'reporte', titulo: 'Accidente de tránsito', detalle: 'Calle 10 #5-20', estado: 'pendiente', lat: 10.4712, lng: -73.2478 }),
  punto({ id: 'r2', capa: 'reporte', titulo: 'Inundación', detalle: 'Barrio El Prado', estado: 'verificado', lat: 10.4558, lng: -73.2611 }),
  punto({ id: 's1', capa: 'solicitud', titulo: 'Ayuda médica', detalle: 'Adulto mayor con dificultad para respirar', estado: 'pendiente', lat: 10.4574, lng: -73.2587 }),
  punto({ id: 's2', capa: 'solicitud', titulo: 'SOS', detalle: 'Solicitud de emergencia (SOS)', estado: 'en_proceso', lat: 10.4863, lng: -73.2659 }),
  { ...punto({ id: 'q1', capa: 'sismo', titulo: 'Sismo M6.1', detalle: '85 km E of Hualien City, Taiwan', estado: 'mundo', lat: 23.9, lng: 122.4 }), magnitud: 6.1 },
  { ...punto({ id: 'q2', capa: 'sismo', titulo: 'Sismo M4.7', detalle: '12 km SW of Los Santos, Colombia', estado: 'colombia', lat: 6.75, lng: -73.18 }), magnitud: 4.7, radio_m: 11_487 },
  punto({ id: 'c1', capa: 'centro', titulo: 'Hospital Municipal', detalle: 'Centro de salud · Cra. 9 #14-30', estado: 'disponible', lat: 10.4689, lng: -73.2551 }),
]

const CAPAS = 'solicitudes,reportes,centros,zonas,alertas,sismos'

// Sin `desde` trae el mapa completo (lo abierto). Con `desde` = generado_en de la consulta anterior,
// trae solo lo que cambió, incluido lo que se cerró (activo=false) para quitarlo.
export async function obtenerMapa(desde?: string): Promise<MapaOut> {
  if (USE_MOCK) return { puntos: desde ? [] : MOCK, generado_en: new Date().toISOString() }
  return api<MapaOut>(`/mapa${consulta({ capas: CAPAS, desde })}`)
}
