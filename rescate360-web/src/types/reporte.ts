// Tabla `reportes` (modelo BD v2).
export type EstadoReporte = 'pendiente' | 'verificado' | 'rechazado' | 'duplicado' | 'no_verificable'

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
  fotoUrl?: string | null
  // Organización a la que va dirigido. Solo sus administradores (o el super_admin) lo ven.
  organizacionObjetivoId: string | null
  verificadoPor?: string | null // nombre de quien lo verificó
}
