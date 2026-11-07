import { api, USE_MOCK } from './api'
import type { RegistroAuditoria } from '../types/auditoria'

// Datos de prueba, SOLO para desarrollo de la interfaz.
const MOCK: RegistroAuditoria[] = [
  {
    id: 'a1', tabla: 'solicitudes_ayuda', registroId: '2', operacion: 'UPDATE', usuarioId: '1', usuarioNombre: 'Admin Demo',
    datosAnteriores: { estado: 'pendiente', prioridad_ia: 'media', prioridad_manual: null, modificado_por: null },
    datosNuevos: { estado: 'en_atencion', prioridad_ia: 'media', prioridad_manual: 'alta', modificado_por: '1' },
    camposModificados: ['estado', 'prioridad_manual', 'modificado_por'], creadoEn: '2026-10-05T08:52:00',
  },
  {
    id: 'a2', tabla: 'reportes', registroId: '2', operacion: 'UPDATE', usuarioId: '1', usuarioNombre: 'Admin Demo',
    datosAnteriores: { estado: 'pendiente', verificado_por: null },
    datosNuevos: { estado: 'verificado', verificado_por: '1' },
    camposModificados: ['estado', 'verificado_por'], creadoEn: '2026-10-05T07:25:00',
  },
  {
    id: 'a3', tabla: 'usuarios', registroId: '12', operacion: 'UPDATE', usuarioId: '1', usuarioNombre: 'Admin Demo',
    datosAnteriores: { nombre: 'Jorge Baquero', rol: 'ciudadano', organizacion_id: null },
    datosNuevos: { nombre: 'Jorge Baquero', rol: 'voluntario', organizacion_id: 'org-1' },
    camposModificados: ['rol', 'organizacion_id'], creadoEn: '2026-10-01T09:15:00',
  },
  {
    id: 'a4', tabla: 'zonas_peligrosas', registroId: '1', operacion: 'INSERT', usuarioId: '1', usuarioNombre: 'Admin Demo',
    datosAnteriores: null,
    datosNuevos: { tipo_riesgo: 'inundacion', estado: 'activa', gestionado_por: '1' },
    camposModificados: null, creadoEn: '2026-10-05T08:40:00',
  },
  {
    id: 'a5', tabla: 'alertas', registroId: '1', operacion: 'INSERT', usuarioId: '14', usuarioNombre: 'Ricardo Lozano',
    datosAnteriores: null,
    datosNuevos: { tipo: 'inundacion', mensaje: 'Crecida del río en la zona urbana. Evite acercarse a las orillas.', creado_por: '14' },
    camposModificados: null, creadoEn: '2026-10-05T09:00:00',
  },
  {
    id: 'a6', tabla: 'zonas_peligrosas', registroId: '4', operacion: 'UPDATE', usuarioId: '14', usuarioNombre: 'Ricardo Lozano',
    datosAnteriores: { estado: 'activa' },
    datosNuevos: { estado: 'resuelta' },
    camposModificados: ['estado'], creadoEn: '2026-10-02T16:30:00',
  },
  {
    id: 'a7', tabla: 'personas_desaparecidas', registroId: '4', operacion: 'UPDATE', usuarioId: '1', usuarioNombre: 'Admin Demo',
    datosAnteriores: { nombre: 'Rosa Elena Pacheco', estado_caso: 'buscando' },
    datosNuevos: { nombre: 'Rosa Elena Pacheco', estado_caso: 'encontrado' },
    camposModificados: ['estado_caso'], creadoEn: '2026-10-03T13:10:00',
  },
  {
    id: 'a8', tabla: 'reportes', registroId: '6', operacion: 'UPDATE', usuarioId: '14', usuarioNombre: 'Ricardo Lozano',
    datosAnteriores: { estado: 'pendiente' },
    datosNuevos: { estado: 'duplicado' },
    camposModificados: ['estado'], creadoEn: '2026-10-05T07:55:00',
  },
  {
    id: 'a9', tabla: 'solicitudes_ayuda', registroId: '5', operacion: 'INSERT', usuarioId: null, usuarioNombre: null,
    datosAnteriores: null,
    datosNuevos: { origen: 'acelerometro', estado: 'pendiente', prioridad_ia: 'pendiente' },
    camposModificados: null, creadoEn: '2026-10-05T10:22:00',
  },
  {
    id: 'a10', tabla: 'alertas', registroId: '7', operacion: 'DELETE', usuarioId: '1', usuarioNombre: 'Admin Demo',
    datosAnteriores: { tipo: 'otro', mensaje: 'Alerta de prueba publicada por error.', creado_por: '1' },
    datosNuevos: null,
    camposModificados: null, creadoEn: '2026-10-01T12:00:00',
  },
  {
    id: 'a11', tabla: 'reportes', registroId: '7', operacion: 'UPDATE', usuarioId: '1', usuarioNombre: 'Admin Demo',
    datosAnteriores: { estado: 'pendiente', verificado_por: null },
    datosNuevos: { estado: 'rechazado', verificado_por: '1' },
    camposModificados: ['estado', 'verificado_por'], creadoEn: '2026-10-03T18:30:00',
  },
]

export async function listarAuditoria(): Promise<RegistroAuditoria[]> {
  if (USE_MOCK) return MOCK.map((r) => ({ ...r }))

  // BACKEND: confirmar la ruta real y paginar (la tabla crece rápido).
  // Un administrador solo debe ver los cambios hechos sobre recursos de su organización
  // o por usuarios de su organización; el super_admin ve todo.
  return api<RegistroAuditoria[]>('/admin/auditoria')
}
