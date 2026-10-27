export type EstadoSolicitud = 'pendiente' | 'en_proceso' | 'atendida' | 'cancelada'
export type Prioridad = 'alta' | 'media' | 'baja'
export type TipoAyuda = 'medica' | 'alimentaria' | 'refugio' | 'rescate' | 'otro'

export interface Solicitud {
  id: string
  tipo: TipoAyuda
  descripcion: string
  ubicacion: string
  solicitante: string
  telefono: string
  fecha: string // formato ISO
  estado: EstadoSolicitud
  prioridadIA: Prioridad
  motivoIA: string
  prioridadManual: Prioridad | null // si tiene valor, prevalece sobre la IA
}

export interface CambiosSolicitud {
  estado?: EstadoSolicitud
  prioridadManual?: Prioridad | null
}

// Regla del negocio: la prioridad manual del administrador prevalece sobre la de la IA.
export const prioridadEfectiva = (s: Solicitud): Prioridad => s.prioridadManual ?? s.prioridadIA