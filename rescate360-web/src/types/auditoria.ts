// Contrato del backend (app/schemas/auditoria_schema.py)
export type OperacionAuditoria = 'INSERT' | 'UPDATE' | 'DELETE'

export interface ActorAuditoriaApi {
  id: string
  nombre: string
}

export interface AuditoriaApi {
  id: string
  tabla: string
  modulo: string
  registro_id: string
  operacion: OperacionAuditoria
  actor: ActorAuditoriaApi | null
  accion: string
  campos_modificados: string[] | null
  datos_anteriores: Record<string, unknown> | null
  datos_nuevos: Record<string, unknown> | null
  creado_en: string
}

// Lo que usa la pantalla de AuditoriaPage
export type TipoEvento = 'acceso' | 'cambio' | 'error'

export type ModuloAuditoria =
  | 'acceso'
  | 'reportes'
  | 'solicitudes'
  | 'usuarios'
  | 'zonas'
  | 'centros'
  | 'alertas'
  | 'donaciones'
  | 'desaparecidos'

export interface EventoAuditoria {
  id: string
  fecha: string // formato ISO
  usuario: string
  accion: string
  tipo: TipoEvento
  modulo: ModuloAuditoria
  detalle: string
  ip: string
}
