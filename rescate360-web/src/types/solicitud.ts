// Tabla `solicitudes_ayuda` (modelo BD v2).
export type EstadoSolicitud = 'pendiente' | 'en_atencion' | 'resuelta'
export type Prioridad = 'baja' | 'media' | 'alta' | 'critica'
// La IA puede no haber clasificado todavía la solicitud.
export type PrioridadIA = Prioridad | 'pendiente'
// 'acelerometro' = la app detectó una caída o golpe fuerte y pidió ayuda sola.
export type OrigenSolicitud = 'manual' | 'acelerometro'

export interface Solicitud {
  id: string
  descripcion: string
  ubicacion: string
  solicitante: string
  telefono: string
  fecha: string // formato ISO
  origen: OrigenSolicitud
  estado: EstadoSolicitud
  prioridadIA: PrioridadIA
  confianzaIA: number | null // 0 a 1
  motivoIA: string // razonamiento_ia
  prioridadManual: Prioridad | null // si tiene valor, prevalece sobre la IA
  organizacionObjetivoId: string | null // la que sugirió la IA / el sistema
  organizacionManualId: string | null // si un admin la reasignó a otra organización
}

export interface CambiosSolicitud {
  estado?: EstadoSolicitud
  prioridadManual?: Prioridad | null
  organizacionManualId?: string | null
}

// Regla del negocio: la prioridad manual del administrador prevalece sobre la de la IA.
export const prioridadEfectiva = (s: Solicitud): PrioridadIA => s.prioridadManual ?? s.prioridadIA

// La organización reasignada manualmente prevalece sobre la sugerida.
export const organizacionEfectiva = (s: Solicitud): string | null =>
  s.organizacionManualId ?? s.organizacionObjetivoId
