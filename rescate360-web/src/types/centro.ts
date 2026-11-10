// Contrato del backend (app/schemas/centros_ayuda_schema.py)
export type TipoCentro = 'albergue' | 'comedor' | 'puesto_medico' | 'centro_acopio'
export type EstadoCentro = 'activo' | 'en_operacion' | 'inactivo'

export interface CentroApi {
  id: string
  nombre: string
  tipo: string
  estado: string
  direccion: string | null
  recursos_disponibles: string | null
  gestionado_por: string
  organizacion_id: string | null
  ubicacion: { lat: number; lng: number }
  distancia_m?: number | null
}

// Lo que usa la pantalla de CentrosPage
export interface Centro {
  id: string
  nombre: string
  tipo: TipoCentro
  ubicacion: string
  estado: EstadoCentro
  lat: number
  lng: number
  recursosDisponibles?: string | null
}

export type DatosCentro = Omit<Centro, 'id'>
