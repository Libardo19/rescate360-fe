export type EstadoReporte = 'pendiente' | 'verificado' | 'rechazado' | 'duplicado'

export type TipoIncidente =
  | 'accidente'
  | 'robo'
  | 'inundacion'
  | 'deslizamiento'
  | 'incendio'
  | 'otro'

export interface Reporte {
  id: string
  tipo: TipoIncidente
  descripcion: string
  ubicacion: string
  reportante: string
  fecha: string // formato ISO
  estado: EstadoReporte
}