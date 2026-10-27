import { api, USE_MOCK } from './api'
import type { DashboardAdmin } from '../types/dashboard'

const MOCK: DashboardAdmin = {
  resumen: {
    reportesPendientes: 12,
    solicitudesActivas: 7,
    alertasActivas: 3,
    centrosRegistrados: 18,
  },
  recientes: [
    { id: '1', tipo: 'reporte', titulo: 'Accidente de tránsito', detalle: 'Calle 10 #5-20', estado: 'En revisión', hace: 'Hace 30 min' },
    { id: '2', tipo: 'solicitud', titulo: 'Ayuda médica', detalle: 'Barrio El Prado', estado: 'En proceso', hace: 'Hace 1 h' },
    { id: '3', tipo: 'reporte', titulo: 'Inundación', detalle: 'Barrio El Prado', estado: 'Confirmado', hace: 'Hace 4 h' },
    { id: '4', tipo: 'reporte', titulo: 'Deslizamiento', detalle: 'Vereda La Esperanza', estado: 'Pendiente', hace: 'Hace 1 día' },
  ],
}

export async function obtenerDashboardAdmin(): Promise<DashboardAdmin> {
  if (USE_MOCK) return MOCK

  // BACKEND: confirmar la ruta real y la forma de la respuesta.
  return api<DashboardAdmin>('/dashboard')
}