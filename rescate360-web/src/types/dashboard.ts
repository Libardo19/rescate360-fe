// Contrato del backend (DashboardOut de app/schemas/dashboard_schema.py)
export interface ResumenApi {
  reportes_pendientes: number
  solicitudes_activas: number
  alertas_activas: number
  centros_registrados: number
  personas_buscando: number
  voluntarios_activos: number
  mis_tareas_activas?: number | null
  casos_sin_organizacion?: number | null
}

export interface ActividadApi {
  id: string
  tipo: 'reporte' | 'solicitud'
  titulo: string
  detalle: string
  estado: string
  creado_en: string
}

export interface TotalesOrganizacionApi {
  organizacion_id: string
  nombre: string
  reportes_pendientes: number
  solicitudes_activas: number
  voluntarios_activos: number
}

export interface DashboardApi {
  alcance: 'organizacion' | 'global'
  resumen: ResumenApi
  recientes: ActividadApi[]
  por_organizacion?: TotalesOrganizacionApi[] | null
}

// Lo que usa la pantalla de AdminDashboard
export interface ResumenAdmin {
  reportesPendientes: number
  solicitudesActivas: number
  alertasActivas: number
  centrosRegistrados: number
  personasBuscando?: number
  voluntariosActivos?: number
}

export interface ActividadReciente {
  id: string
  tipo: 'reporte' | 'solicitud'
  titulo: string
  detalle: string
  estado: string
  hace: string
}

export interface DashboardAdmin {
  resumen: ResumenAdmin
  recientes: ActividadReciente[]
}
