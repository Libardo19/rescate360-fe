import { api, USE_MOCK } from './api'
import type { DashboardAdmin, DashboardApi, ActividadApi } from '../types/dashboard'

const calcularHace = (iso: string): string => {
  const diffSegundos = Math.max(0, Math.floor((Date.now() - new Date(iso).getTime()) / 1000))
  if (diffSegundos < 60) return 'Hace un momento'
  const minutos = Math.floor(diffSegundos / 60)
  if (minutos < 60) return `Hace ${minutos} min`
  const horas = Math.floor(minutos / 60)
  if (horas < 24) return `Hace ${horas} h`
  const dias = Math.floor(horas / 24)
  return `Hace ${dias} día${dias > 1 ? 's' : ''}`
}

export const aActividadReciente = (a: ActividadApi) => ({
  id: a.id,
  tipo: a.tipo,
  titulo: a.titulo,
  detalle: a.detalle,
  estado: a.estado,
  hace: calcularHace(a.creado_en),
})

export const aDashboardAdmin = (d: DashboardApi): DashboardAdmin => ({
  resumen: {
    reportesPendientes: d.resumen.reportes_pendientes,
    solicitudesActivas: d.resumen.solicitudes_activas,
    alertasActivas: d.resumen.alertas_activas,
    centrosRegistrados: d.resumen.centros_registrados,
    personasBuscando: d.resumen.personas_buscando,
    voluntariosActivos: d.resumen.voluntarios_activos,
  },
  recientes: d.recientes.map(aActividadReciente),
})

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

  const datos = await api<DashboardApi>('/dashboard')
  return aDashboardAdmin(datos)
}
