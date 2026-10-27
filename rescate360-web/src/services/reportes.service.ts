import { api, consulta, urlArchivo, USE_MOCK, type Pagina } from './api'
import type { Reporte, ReporteApi, TipoSugerido } from '../types/reporte'

const TIPOS_MOCK: TipoSugerido[] = [
  { valor: 'accidente', etiqueta: 'Accidente' },
  { valor: 'robo', etiqueta: 'Robo' },
  { valor: 'inundacion', etiqueta: 'Inundación' },
  { valor: 'deslizamiento', etiqueta: 'Deslizamiento' },
  { valor: 'incendio', etiqueta: 'Incendio' },
  { valor: 'sismo', etiqueta: 'Sismo' },
]

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
const base = { lat: 10.4631, lng: -73.2532, evidencias: [], motivoRechazo: null, duplicadoDeId: null, organizacionId: null }
let mock: Reporte[] = [
  { ...base, id: '1', tipo: 'accidente', tipoEtiqueta: 'Accidente', descripcion: 'Choque entre moto y carro, hay heridos leves.', ubicacion: 'Calle 10 #5-20', reportante: 'Juan Pérez', fecha: '2026-10-05T09:30:00', estado: 'pendiente' },
  { ...base, id: '2', tipo: 'inundacion', tipoEtiqueta: 'Inundación', descripcion: 'Se desbordó la quebrada, el agua entra a varias casas.', ubicacion: 'Barrio El Prado', reportante: 'María López', fecha: '2026-10-05T07:10:00', estado: 'verificado' },
  { ...base, id: '3', tipo: 'fuga de gas', tipoEtiqueta: 'Fuga de gas', descripcion: 'Olor fuerte a gas en la esquina.', ubicacion: 'Parque Central', reportante: 'Carlos Rojas', fecha: '2026-10-04T21:45:00', estado: 'pendiente' },
]

// Del contrato del backend al modelo de la pantalla
const aReporte = (r: ReporteApi): Reporte => ({
  id: r.id,
  tipo: r.tipo,
  tipoEtiqueta: r.tipo_etiqueta,
  descripcion: r.descripcion,
  ubicacion: r.direccion ?? `${r.ubicacion.lat.toFixed(5)}, ${r.ubicacion.lng.toFixed(5)}`,
  lat: r.ubicacion.lat,
  lng: r.ubicacion.lng,
  reportante: r.reportante?.nombre ?? 'Anónimo',
  fecha: r.creado_en,
  estado: r.estado,
  // El backend devuelve rutas relativas (/uploads/...): el navegador necesita la URL completa del API
  evidencias: r.evidencias.map((e) => ({ ...e, url: urlArchivo(e.url) })),
  motivoRechazo: r.motivo_rechazo,
  duplicadoDeId: r.duplicado_de_id,
  organizacionId: r.organizacion_manual_id ?? r.organizacion_objetivo_id,
})

export async function listarTipos(): Promise<TipoSugerido[]> {
  if (USE_MOCK) return TIPOS_MOCK
  return api<TipoSugerido[]>('/reportes/tipos')
}

// El backend pagina; la pantalla filtra en el navegador. El admin recibe los de su organización.
export async function listarReportes(): Promise<Reporte[]> {
  if (USE_MOCK) return mock.map((r) => ({ ...r }))
  const pagina = await api<Pagina<ReporteApi>>(`/reportes${consulta({ por_pagina: 100 })}`)
  return pagina.items.map(aReporte)
}

const cambiarMock = (id: string, cambios: Partial<Reporte>) => {
  mock = mock.map((r) => (r.id === id ? { ...r, ...cambios } : r))
  return { ...mock.find((r) => r.id === id)! }
}

const patch = async (ruta: string, cuerpo?: object) =>
  aReporte(await api<ReporteApi>(ruta, { method: 'PATCH', ...(cuerpo ? { body: JSON.stringify(cuerpo) } : {}) }))

// Las tres revisiones solo se hacen sobre un reporte pendiente
export async function verificarReporte(id: string): Promise<Reporte> {
  if (USE_MOCK) return cambiarMock(id, { estado: 'verificado' })
  return patch(`/reportes/${id}/verificar`)
}

export async function rechazarReporte(id: string, motivo: string): Promise<Reporte> {
  if (USE_MOCK) return cambiarMock(id, { estado: 'rechazado', motivoRechazo: motivo || null })
  return patch(`/reportes/${id}/rechazar`, motivo ? { motivo } : undefined)
}

export async function marcarDuplicado(id: string, duplicadoDeId: string): Promise<Reporte> {
  if (USE_MOCK) return cambiarMock(id, { estado: 'duplicado', duplicadoDeId })
  return patch(`/reportes/${id}/marcar-duplicado`, { duplicado_de_id: duplicadoDeId })
}

// Solo el super admin
export async function asignarOrganizacionReporte(id: string, organizacionId: string): Promise<Reporte> {
  if (USE_MOCK) return cambiarMock(id, { organizacionId })
  return patch(`/reportes/${id}/organizacion`, { organizacion_id: organizacionId })
}
