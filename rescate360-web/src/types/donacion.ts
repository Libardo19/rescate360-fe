// Contrato del backend (app/schemas/donaciones_schema.py)
export type CategoriaDonacion = 'alimentos' | 'ropa' | 'medicamentos' | 'agua' | 'dinero' | 'otro'
export type EstadoDonacion = 'recibida' | 'en_proceso' | 'entregada'

export interface CampanaApi {
  id: string
  titulo: string
  descripcion: string
  categoria: string
  meta: number
  unidad: string
  fecha_fin: string
  activa: boolean
  organizacion_id: string | null
  creado_en: string
  recaudado: number
  propia: boolean
}

export interface DonacionApi {
  id: string
  categoria: string
  descripcion: string | null
  cantidad: number
  unidad: string
  monto: number | null
  estado: EstadoDonacion
  campana_id: string | null
  centro_id: string | null
  organizacion_id: string | null
  creado_en: string
}

// Lo que usa la pantalla de DonacionesPage
export interface Donacion {
  id: string
  fecha: string // formato ISO
  categoria: CategoriaDonacion
  descripcion: string
  cantidad: string
  monto?: number
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
  fechaFin: string // formato ISO o fecha corta YYYY-MM-DD
  activa: boolean
}

export interface DatosCampana {
  titulo: string
  descripcion: string
  categoria: CategoriaDonacion
  meta: number
  unidad: string
  fechaFin: string
}
