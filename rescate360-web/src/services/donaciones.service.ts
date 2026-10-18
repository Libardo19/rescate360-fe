import { api, USE_MOCK } from './api'
import type { Donacion, Campana, DatosCampana } from '../types/donacion'

// Datos de prueba, SOLO para desarrollo de la interfaz.
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

export async function listarDonaciones(): Promise<Donacion[]> {
  if (USE_MOCK) return donaciones.map((d) => ({ ...d }))

  // BACKEND: confirmar la ruta real y la forma de la respuesta.
  return api<Donacion[]>('/admin/donaciones')
}

export async function marcarDonacionRecibida(id: string): Promise<Donacion> {
  if (USE_MOCK) {
    donaciones = donaciones.map((d) => (d.id === id ? { ...d, estado: 'recibida' } : d))
    const donacion = donaciones.find((d) => d.id === id)
    if (!donacion) throw new Error('Donación no encontrada')
    return { ...donacion }
  }

  // BACKEND: endpoint para confirmar la recepción de una donación.
  return api<Donacion>(`/admin/donaciones/${id}/recibida`, { method: 'PATCH' })
}

export async function listarCampanas(): Promise<Campana[]> {
  if (USE_MOCK) return campanas.map((c) => ({ ...c }))

  // BACKEND: confirmar la ruta real. El avance (recaudado) lo debería calcular el backend.
  return api<Campana[]>('/admin/campanas')
}

export async function crearCampana(datos: DatosCampana): Promise<Campana> {
  if (USE_MOCK) {
    const nueva: Campana = { ...datos, id: String(Date.now()), recaudado: 0, activa: true }
    campanas = [nueva, ...campanas]
    return { ...nueva }
  }

  // BACKEND: endpoint para crear una campaña de donación.
  return api<Campana>('/admin/campanas', { method: 'POST', body: JSON.stringify(datos) })
}

export async function finalizarCampana(id: string): Promise<Campana> {
  if (USE_MOCK) {
    campanas = campanas.map((c) => (c.id === id ? { ...c, activa: false } : c))
    const campana = campanas.find((c) => c.id === id)
    if (!campana) throw new Error('Campaña no encontrada')
    return { ...campana }
  }

  // BACKEND: endpoint para cerrar una campaña.
  return api<Campana>(`/admin/campanas/${id}/finalizar`, { method: 'PATCH' })
}