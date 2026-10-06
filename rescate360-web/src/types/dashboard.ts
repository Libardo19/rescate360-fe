export interface ResumenAdmin {
  reportesPendientes: number
  solicitudesActivas: number
  alertasActivas: number
  centrosRegistrados: number
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