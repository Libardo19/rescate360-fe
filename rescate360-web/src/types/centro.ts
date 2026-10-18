export type TipoCentro = 'albergue' | 'comedor' | 'puesto_medico' | 'centro_acopio'
export type EstadoCentro = 'activo' | 'en_operacion' | 'inactivo'

export interface Centro {
  id: string
  nombre: string
  tipo: TipoCentro
  ubicacion: string
  estado: EstadoCentro
  lat: number
  lng: number
}

export type DatosCentro = Omit<Centro, 'id'>