// Sismo de GET /sismos (feed público del USGS; los simulacros de la demo traen fuente "simulado")
export interface Sismo {
  id: string
  fuente: string
  magnitud: number
  profundidadKm: number | null
  lugar: string
  lat: number
  lng: number
  ocurridoEn: string
  radioAfectacionM: number
  alertaId: string | null
  enColombia: boolean // solo los de Colombia alertan; los demás son informativos
}

export interface SismoApi {
  id: string
  fuente: string
  magnitud: number
  profundidad_km: number | null
  lugar: string
  epicentro: { lat: number; lng: number }
  ocurrido_en: string
  radio_afectacion_m: number
  alerta_id: string | null
  en_colombia: boolean
  distancia_m: number | null
  aviso: string
}

export type RegionSismo = 'todos' | 'colombia' | 'mundo'

export type EstadoCheckIn = 'pendiente' | 'a_salvo' | 'necesito_ayuda' | 'sin_respuesta'

export interface PersonaCheckIn {
  id: string
  nombre: string
  telefono: string | null
  estado: EstadoCheckIn
  respondidoEn: string | null
}

export interface CheckInsSismo {
  resumen: Record<EstadoCheckIn, number>
  personas: PersonaCheckIn[]
}

export interface CheckInsEventoApi {
  resumen: Record<EstadoCheckIn, number>
  personas: { id: string; nombre: string; telefono: string | null; estado: EstadoCheckIn; respondido_en: string | null }[]
}
