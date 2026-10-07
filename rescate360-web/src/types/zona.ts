export type TipoRiesgo = 'inundacion' | 'deslizamiento' | 'incendio' | 'seguridad'
export type NivelRiesgo = 'alto' | 'medio' | 'bajo'
export type EstadoZona = 'activa' | 'en_monitoreo' | 'inactiva'

export interface Zona {
  id: string
  nombre: string
  tipoRiesgo: TipoRiesgo
  nivel: NivelRiesgo
  estado: EstadoZona
  descripcion: string
  lat: number
  lng: number
  radio: number // metros
}

export type DatosZona = Omit<Zona, 'id'>