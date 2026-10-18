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