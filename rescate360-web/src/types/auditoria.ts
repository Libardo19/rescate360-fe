// Tabla `auditoria` (modelo BD v2). Las filas las crea el trigger fn_auditoria().
export type TablaAuditada =
  | 'usuarios'
  | 'reportes'
  | 'solicitudes_ayuda'
  | 'personas_desaparecidas'
  | 'zonas_peligrosas'
  | 'alertas'

export type Operacion = 'INSERT' | 'UPDATE' | 'DELETE'

export type DatosFila = Record<string, unknown>

export interface RegistroAuditoria {
  id: string
  tabla: TablaAuditada
  registroId: string
  operacion: Operacion
  usuarioId: string | null
  usuarioNombre: string | null // BACKEND: unir con usuarios para enviar el nombre; null = cambio del sistema
  datosAnteriores: DatosFila | null
  datosNuevos: DatosFila | null
  camposModificados: string[] | null
  creadoEn: string // formato ISO
}
