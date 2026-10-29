// Valores iguales a los del backend (enums de app/models/enums.py)
export type EstadoSolicitud = 'pendiente' | 'en_proceso' | 'atendida' | 'cancelada'
// "pendiente" = la IA todavía no la clasificó
export type Prioridad = 'pendiente' | 'baja' | 'media' | 'alta' | 'critica'
export type TipoAyuda = 'medica' | 'alimentaria' | 'refugio' | 'rescate' | 'ropa' | 'otro'
export type OrigenSolicitud = 'manual' | 'acelerometro' | 'sos'

// AtencionOut: la asignación más reciente que no se canceló (null si nadie lo ha tomado).
// El backend solo la manda a la organización y al super admin.
export interface AtencionApi {
  voluntario: { id: string; nombre: string }
  estado: 'activa' | 'finalizada' | 'cancelada'
  desde: string
  hasta: string | null
}

export interface Atencion {
  voluntario: string
  finalizada: boolean
  desde: string
  hasta: string | null
}

export const aAtencion = (a: AtencionApi | null | undefined): Atencion | null =>
  a ? { voluntario: a.voluntario.nombre, finalizada: a.estado === 'finalizada', desde: a.desde, hasta: a.hasta } : null

// SolicitudAyudaOut, tal como responde GET /solicitudes-ayuda
export interface SolicitudApi {
  id: string
  usuario_id: string
  descripcion: string
  direccion: string | null
  tipo: TipoAyuda
  ubicacion: { lat: number; lng: number }
  origen: OrigenSolicitud
  prioridad_ia: Prioridad
  prioridad_manual: Prioridad | null
  organizacion_objetivo_id: string | null
  organizacion_manual_id: string | null
  confianza_ia: number | null
  razonamiento_ia: string | null
  estado: EstadoSolicitud
  creado_en: string
  actualizado_en: string
  // Cuando el backend los incluya (pendiente en SolicitudAyudaOut)
  solicitante?: { nombre: string; telefono: string | null } | null
  atencion?: AtencionApi | null
}

// Lo que usa la pantalla (la arma solicitudes.service a partir de SolicitudApi)
export interface Solicitud {
  id: string
  tipo: TipoAyuda
  origen: OrigenSolicitud
  descripcion: string
  ubicacion: string
  lat: number
  lng: number
  solicitante: string
  telefono: string
  fecha: string // formato ISO
  estado: EstadoSolicitud
  prioridadIA: Prioridad
  motivoIA: string
  prioridadManual: Prioridad | null // si tiene valor, prevalece sobre la IA
  organizacionId: string | null // la manual prevalece sobre la sugerida por la IA
  atencion: Atencion | null // qué voluntario lo tomó y si ya finalizó
}

export interface CambiosSolicitud {
  estado?: EstadoSolicitud
  prioridadManual?: Prioridad
}

// Regla del negocio: la prioridad manual del administrador prevalece sobre la de la IA.
export const prioridadEfectiva = (s: Solicitud): Prioridad => s.prioridadManual ?? s.prioridadIA
