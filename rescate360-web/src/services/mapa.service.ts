import { api, USE_MOCK } from './api'
import type { PuntoMapa } from '../types/mapa'

// Datos de prueba, SOLO para desarrollo de la interfaz.
const MOCK: PuntoMapa[] = [
  { id: 'r1', tipo: 'reporte', titulo: 'Accidente de tránsito', detalle: 'Calle 10 #5-20', estado: 'Pendiente', lat: 10.4712, lng: -73.2478 },
  { id: 'r2', tipo: 'reporte', titulo: 'Inundación', detalle: 'Barrio El Prado', estado: 'Verificado', lat: 10.4558, lng: -73.2611 },
  { id: 'r3', tipo: 'reporte', titulo: 'Robo en comercio', detalle: 'Parque Central', estado: 'Pendiente', lat: 10.4769, lng: -73.2519 },
  { id: 'r4', tipo: 'reporte', titulo: 'Deslizamiento', detalle: 'Vereda La Esperanza', estado: 'Pendiente', lat: 10.4905, lng: -73.2702 },
  { id: 'r5', tipo: 'reporte', titulo: 'Incendio en vivienda', detalle: 'Cra. 19 #12-45', estado: 'Verificado', lat: 10.4627, lng: -73.2385 },
  { id: 's1', tipo: 'solicitud', titulo: 'Ayuda médica', detalle: 'Adulto mayor con dificultad para respirar', estado: 'Pendiente', lat: 10.4574, lng: -73.2587 },
  { id: 's2', tipo: 'solicitud', titulo: 'Refugio', detalle: 'Familia sin vivienda tras la inundación', estado: 'En proceso', lat: 10.4863, lng: -73.2659 },
  { id: 's3', tipo: 'solicitud', titulo: 'Rescate', detalle: 'Persona atrapada en un vehículo', estado: 'Pendiente', lat: 10.4421, lng: -73.2294 },
  { id: 'c1', tipo: 'centro', titulo: 'Hospital Municipal', detalle: 'Centro de salud · Cra. 9 #14-30', estado: 'Disponible', lat: 10.4689, lng: -73.2551 },
  { id: 'c2', tipo: 'centro', titulo: 'Refugio Municipal', detalle: 'Albergue · Calle 16 #8-32', estado: 'Disponible', lat: 10.4602, lng: -73.2447 },
  { id: 'c3', tipo: 'centro', titulo: 'Centro de Acopio San José', detalle: 'Punto de acopio · Calle 12 #8-45', estado: 'Disponible', lat: 10.4795, lng: -73.2634 },
]

export async function listarPuntosMapa(): Promise<PuntoMapa[]> {
  if (USE_MOCK) return MOCK

  // BACKEND: confirmar la ruta real. Cada punto necesita latitud y longitud
  // (de los reportes, las solicitudes y los centros de ayuda).
  return api<PuntoMapa[]>('/admin/mapa')
}