// Tabla `donaciones` (modelo BD v2): inventario de lo recibido en cada centro de ayuda.
export type TipoDonacion = 'agua' | 'alimentos' | 'medicamentos' | 'ropa' | 'higiene' | 'cobijas' | 'otro'

export interface Donacion {
  id: string
  centroId: string
  tipo: TipoDonacion
  cantidad: number
  unidad: string
  actualizadoEn: string // formato ISO
}

export type DatosDonacion = Pick<Donacion, 'centroId' | 'tipo' | 'cantidad' | 'unidad'>
