import type { EstadoReporte } from './reporte'
import type { PrioridadIA, Solicitud } from './solicitud'
import type { RegistroAuditoria } from './auditoria'

// Todo se calcula a partir de los datos reales de cada módulo (ver dashboard.service.ts).
export interface ResumenAdmin {
  reportesTotal: number
  reportesPendientes: number
  solicitudesAbiertas: number // pendiente + en_atencion
  solicitudesUrgentes: number // abiertas con prioridad efectiva crítica o alta
  solicitudesSinClasificar: number // abiertas que la IA aún no clasificó y nadie priorizó
  alertasActivas: number
  zonasActivas: number
  centrosOperativos: number
  centrosTotal: number
  donacionesAgotadas: number
  desaparecidosBuscando: number
  voluntariosActivos: number
  voluntariosTotal: number
}

export interface PuntoActividad {
  fecha: string // YYYY-MM-DD (día local)
  reportes: number
  solicitudes: number
}

export interface DashboardAdmin {
  resumen: ResumenAdmin
  reportesPorEstado: Record<EstadoReporte, number>
  solicitudesPorPrioridad: Record<PrioridadIA, number> // solo abiertas
  actividad: PuntoActividad[] // 30 días que terminan en el día del registro más reciente
  requierenAtencion: Solicitud[] // abiertas, ordenadas por prioridad
  pendientes: Solicitud[] // sin tomar por nadie (estado pendiente), para el semáforo y el briefing
  auditoriaReciente: RegistroAuditoria[]
}
