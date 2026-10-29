import type { Prioridad } from './solicitud'

// Valores iguales a los del backend
export type EstadoReporte = 'pendiente' | 'verificado' | 'rechazado' | 'duplicado' | 'no_verificable'

// El tipo es texto libre: hay una lista sugerida (GET /reportes/tipos), pero el ciudadano
// puede escribir otro tipo de emergencia ("fuga de gas", "árbol caído"…)
export type TipoIncidente = string

export interface TipoSugerido {
  valor: string
  etiqueta: string
}

export interface Evidencia {
  id: string
  tipo: 'foto' | 'video'
  url: string
  mime: string
}

// ReporteOut del backend
export interface ReporteApi {
  id: string
  usuario_id: string
  tipo: string
  tipo_etiqueta: string
  descripcion: string
  direccion: string | null
  ubicacion: { lat: number; lng: number }
  estado: EstadoReporte
  prioridad_ia: Prioridad
  prioridad_manual: Prioridad | null
  confianza_ia: number | null
  razonamiento_ia: string | null
  organizacion_objetivo_id: string | null
  organizacion_manual_id: string | null
  verificado_por: string | null
  verificado_en: string | null
  motivo_rechazo: string | null
  duplicado_de_id: string | null
  evidencias: Evidencia[]
  reportante: { id: string; nombre: string } | null
  creado_en: string
  actualizado_en: string
}

// Lo que usa la pantalla (lo arma reportes.service)
export interface Reporte {
  id: string
  tipo: TipoIncidente
  tipoEtiqueta: string
  descripcion: string
  ubicacion: string
  lat: number
  lng: number
  reportante: string
  fecha: string // formato ISO
  estado: EstadoReporte
  evidencias: Evidencia[]
  prioridadIA: Prioridad
  prioridadManual: Prioridad | null // si tiene valor, prevalece sobre la IA
  confianzaIA: number | null
  motivoIA: string
  motivoRechazo: string | null
  duplicadoDeId: string | null
  organizacionId: string | null // la manual prevalece sobre la sugerida por la IA
}

// Regla del negocio: la prioridad manual del administrador prevalece sobre la de la IA.
export const prioridadEfectivaReporte = (r: Reporte): Prioridad => r.prioridadManual ?? r.prioridadIA
