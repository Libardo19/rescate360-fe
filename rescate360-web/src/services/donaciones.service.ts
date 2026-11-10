import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { Donacion, DonacionApi, Campana, CampanaApi, DatosCampana, CategoriaDonacion, EstadoDonacion } from '../types/donacion'

export const aCampana = (c: CampanaApi): Campana => ({
  id: c.id,
  titulo: c.titulo,
  descripcion: c.descripcion,
  categoria: (c.categoria as CategoriaDonacion) ?? 'otro',
  meta: c.meta,
  recaudado: c.recaudado ?? 0,
  unidad: c.unidad,
  fechaFin: c.fecha_fin,
  activa: c.activa,
})

export const aDonacion = (d: DonacionApi): Donacion => ({
  id: d.id,
  fecha: d.creado_en,
  categoria: (d.categoria as CategoriaDonacion) ?? 'otro',
  descripcion: d.descripcion ?? 'Sin descripción',
  cantidad: `${d.cantidad} ${d.unidad}`,
  monto: d.monto ?? undefined,
  estado: (d.estado as EstadoDonacion) ?? 'recibida',
})

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
let donaciones: Donacion[] = [
  { id: '1', fecha: '2026-10-05T10:00:00', categoria: 'alimentos', descripcion: 'Mercados y víveres', cantidad: '50 und.', estado: 'recibida' },
  { id: '2', fecha: '2026-10-04T15:30:00', categoria: 'ropa', descripcion: 'Ropa para adultos y niños', cantidad: '120 und.', estado: 'recibida' },
  { id: '3', fecha: '2026-10-03T09:15:00', categoria: 'medicamentos', descripcion: 'Kit básico de medicamentos', cantidad: '20 und.', estado: 'en_proceso' },
  { id: '4', fecha: '2026-10-02T17:45:00', categoria: 'agua', descripcion: 'Botellas de agua potable', cantidad: '200 und.', estado: 'recibida' },
  { id: '5', fecha: '2026-10-01T11:00:00', categoria: 'dinero', descripcion: 'Apoyo económico', cantidad: '1 aporte', monto: 1000000, estado: 'recibida' },
  { id: '6', fecha: '2026-09-30T13:20:00', categoria: 'dinero', descripcion: 'Aporte para la campaña de alimentos', cantidad: '1 aporte', monto: 450000, estado: 'en_proceso' },
]

let campanas: Campana[] = [
  { id: '1', titulo: 'Alimentos para familias', descripcion: 'Recolección de alimentos no perecederos.', categoria: 'alimentos', meta: 500, recaudado: 330, unidad: 'kits', fechaFin: '2026-10-10T23:59:59', activa: true },
  { id: '2', titulo: 'Medicamentos de emergencia', descripcion: 'Medicamentos básicos y de uso general.', categoria: 'medicamentos', meta: 300, recaudado: 126, unidad: 'kits', fechaFin: '2026-10-12T23:59:59', activa: true },
  { id: '3', titulo: 'Ropa y abrigo', descripcion: 'Ropa en buen estado para todas las edades.', categoria: 'ropa', meta: 400, recaudado: 92, unidad: 'prendas', fechaFin: '2026-10-14T23:59:59', activa: true },
]

export async function listarCampanas(): Promise<Campana[]> {
  if (USE_MOCK) return campanas.map((c) => ({ ...c }))

  // En el backend la ruta es GET /campanas (devuelve list[CampanaOut])
  const lista = await api<CampanaApi[]>('/campanas?todas=true')
  return lista.map(aCampana)
}

export async function crearCampana(datos: DatosCampana): Promise<Campana> {
  if (USE_MOCK) {
    const nueva: Campana = { ...datos, id: String(Date.now()), recaudado: 0, activa: true }
    campanas = [nueva, ...campanas]
    return { ...nueva }
  }

  const payload = {
    titulo: datos.titulo,
    descripcion: datos.descripcion,
    categoria: datos.categoria,
    meta: Number(datos.meta),
    unidad: datos.unidad,
    fecha_fin: datos.fechaFin.slice(0, 10),
  }

  const respuesta = await api<CampanaApi>('/campanas', {
    method: 'POST',
    body: JSON.stringify(payload),
  })
  return aCampana(respuesta)
}

export async function finalizarCampana(id: string): Promise<Campana> {
  if (USE_MOCK) {
    campanas = campanas.map((c) => (c.id === id ? { ...c, activa: false } : c))
    const campana = campanas.find((c) => c.id === id)
    if (!campana) throw new Error('Campaña no encontrada')
    return { ...campana }
  }

  const respuesta = await api<CampanaApi>(`/campanas/${id}`, {
    method: 'PATCH',
    body: JSON.stringify({ activa: false }),
  })
  return aCampana(respuesta)
}

export async function listarDonaciones(): Promise<Donacion[]> {
  if (USE_MOCK) return donaciones.map((d) => ({ ...d }))

  // En el backend la ruta es GET /donaciones (devuelve Pagina[DonacionOut])
  const pagina = await api<Pagina<DonacionApi>>(`/donaciones${consulta({ por_pagina: 100 })}`)
  return pagina.items.map(aDonacion)
}

export async function marcarDonacionRecibida(id: string): Promise<Donacion> {
  if (USE_MOCK) {
    donaciones = donaciones.map((d) => (d.id === id ? { ...d, estado: 'recibida' } : d))
    const donacion = donaciones.find((d) => d.id === id)
    if (!donacion) throw new Error('Donación no encontrada')
    return { ...donacion }
  }

  // En el backend la ruta es PATCH /donaciones/{id}/estado
  const respuesta = await api<DonacionApi>(`/donaciones/${id}/estado`, {
    method: 'PATCH',
    body: JSON.stringify({ estado: 'recibida' }),
  })
  return aDonacion(respuesta)
}
