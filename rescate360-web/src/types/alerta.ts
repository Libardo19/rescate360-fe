// Contrato del backend (app/schemas/alertas_schema.py)
export type TipoAlerta = 'inundacion' | 'deslizamiento' | 'seguridad' | 'clima' | 'sismo' | 'otro'
export type NivelAlerta = 'bajo' | 'medio' | 'alto'
export type EstadoAlerta = 'activa' | 'expirada' | 'cancelada'

export interface CirculoAlertaApi {
  lat: number
  lng: number
  radio_m: number
}

export interface AlertaApi {
  id: string
  titulo: string
  tipo: string
  mensaje: string
  nivel: NivelAlerta
  estado: EstadoAlerta
  origen: string
  zona: CirculoAlertaApi
  expira_en: string
  creado_en: string
  actualizado_en: string
  organizacion_id: string | null
  propia: boolean
}

// Lo que usa la pantalla de AlertasPage
export interface Alerta {
  id: string
  tipo: TipoAlerta
  titulo: string
  descripcion: string
  zona: string
  lat?: number
  lng?: number
  radio_m?: number
  fecha: string // formato ISO
  activa: boolean
  nivel?: NivelAlerta
}

export interface NuevaAlerta {
  tipo: TipoAlerta
  titulo: string
  descripcion: string
  zona: string
  lat?: number
  lng?: number
  radio_m?: number
  horas_vigencia?: number
}
