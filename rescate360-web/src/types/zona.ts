// Contrato del backend (app/schemas/zonas_peligrosas_schema.py)
export type TipoRiesgo = 'inundacion' | 'deslizamiento' | 'incendio' | 'seguridad' | 'otro'
export type NivelRiesgo = 'alto' | 'medio' | 'bajo'
export type EstadoZona = 'activa' | 'en_monitoreo' | 'inactiva'

export interface ZonaCirculoApi {
  lat: number
  lng: number
  radio_m: number
}

export interface ZonaApi {
  id: string
  nombre: string
  tipo_riesgo: string
  nivel: NivelRiesgo
  descripcion: string | null
  estado: EstadoZona
  zona: ZonaCirculoApi
  actualizado_en: string
  propia: boolean
  distancia_m?: number | null
}

// Lo que usa la pantalla de ZonasPage
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
