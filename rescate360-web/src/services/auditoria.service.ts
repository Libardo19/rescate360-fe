import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { EventoAuditoria, AuditoriaApi, ModuloAuditoria, TipoEvento } from '../types/auditoria'

const MAPA_MODULOS: Record<string, ModuloAuditoria> = {
  usuarios: 'usuarios',
  solicitudes_ayuda: 'solicitudes',
  reportes: 'reportes',
  personas_desaparecidas: 'desaparecidos',
  zonas_peligrosas: 'zonas',
  centros_ayuda: 'centros',
  alertas: 'alertas',
  campanas: 'donaciones',
  donaciones: 'donaciones',
  sesiones: 'acceso',
  auth: 'acceso',
}

export const aEventoAuditoria = (a: AuditoriaApi): EventoAuditoria => {
  const modulo = MAPA_MODULOS[a.tabla] ?? 'reportes'
  const tipo: TipoEvento = a.tabla === 'sesiones' || a.tabla === 'auth' ? 'acceso' : 'cambio'
  const detalle = a.campos_modificados?.length
    ? `Campos modificados: ${a.campos_modificados.join(', ')}`
    : a.accion

  return {
    id: a.id,
    fecha: a.creado_en,
    usuario: a.actor?.nombre ?? 'Sistema',
    accion: a.accion,
    tipo,
    modulo,
    detalle,
    ip: '—',
  }
}

// Datos de prueba inventados, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
const MOCK: EventoAuditoria[] = [
  { id: '1', fecha: '2026-10-08T10:24:00', usuario: 'Admin Demo', accion: 'Inició sesión', tipo: 'acceso', modulo: 'acceso', detalle: 'Inicio de sesión en el panel', ip: '192.168.1.10' },
  { id: '2', fecha: '2026-10-08T09:52:00', usuario: 'Marta Salcedo', accion: 'Creó reporte', tipo: 'cambio', modulo: 'reportes', detalle: 'Reporte de accidente en Calle 10', ip: '192.168.1.21' },
  { id: '3', fecha: '2026-10-08T09:18:00', usuario: 'Carlos Peñaranda', accion: 'Actualizó solicitud', tipo: 'cambio', modulo: 'solicitudes', detalle: 'Estado cambiado a "En proceso"', ip: '192.168.1.33' },
  { id: '4', fecha: '2026-10-08T08:45:00', usuario: 'Laura Mejía', accion: 'Añadió usuario', tipo: 'cambio', modulo: 'usuarios', detalle: 'Nuevo voluntario invitado', ip: '192.168.1.45' },
  { id: '5', fecha: '2026-10-07T21:12:00', usuario: 'Admin Demo', accion: 'Eliminó zona peligrosa', tipo: 'cambio', modulo: 'zonas', detalle: 'Zona: Pastizales del borde urbano', ip: '192.168.1.10' },
]

export async function listarEventos(): Promise<EventoAuditoria[]> {
  if (USE_MOCK) return MOCK.map((e) => ({ ...e }))

  const pagina = await api<Pagina<AuditoriaApi>>(`/auditoria${consulta({ por_pagina: 100 })}`)
  return pagina.items.map(aEventoAuditoria)
}
