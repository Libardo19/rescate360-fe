export type CategoriaDonacion = 'alimentos' | 'ropa' | 'medicamentos' | 'agua' | 'dinero'
export type EstadoDonacion = 'recibida' | 'en_proceso'

export interface Donacion {
  id: string
  fecha: string // formato ISO
  categoria: CategoriaDonacion
  descripcion: string
  cantidad: string
  monto?: number // solo para donaciones en dinero
  estado: EstadoDonacion
}

export interface Campana {
  id: string
  titulo: string
  descripcion: string
  categoria: CategoriaDonacion
  meta: number
  recaudado: number
  unidad: string
  fechaFin: string // formato ISO
  activa: boolean
}

export type DatosCampana = Pick<Campana, 'titulo' | 'descripcion' | 'categoria' | 'meta' | 'unidad' | 'fechaFin'>