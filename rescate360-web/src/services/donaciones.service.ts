import { api, USE_MOCK } from './api'
import type { DatosDonacion, Donacion } from '../types/donacion'

// Datos de prueba, SOLO para desarrollo de la interfaz. Los centroId son los del mock de centros.
let mock: Donacion[] = [
  { id: '1', centroId: '4', tipo: 'agua', cantidad: 320, unidad: 'litros', actualizadoEn: '2026-10-05T09:10:00' },
  { id: '2', centroId: '4', tipo: 'alimentos', cantidad: 85, unidad: 'kg', actualizadoEn: '2026-10-05T08:45:00' },
  { id: '3', centroId: '4', tipo: 'higiene', cantidad: 40, unidad: 'kits', actualizadoEn: '2026-10-04T17:20:00' },
  { id: '4', centroId: '5', tipo: 'ropa', cantidad: 120, unidad: 'prendas', actualizadoEn: '2026-10-04T15:00:00' },
  { id: '5', centroId: '5', tipo: 'cobijas', cantidad: 35, unidad: 'unidades', actualizadoEn: '2026-10-04T15:05:00' },
  { id: '6', centroId: '6', tipo: 'medicamentos', cantidad: 18, unidad: 'cajas', actualizadoEn: '2026-10-05T07:30:00' },
  { id: '7', centroId: '1', tipo: 'cobijas', cantidad: 60, unidad: 'unidades', actualizadoEn: '2026-10-03T19:40:00' },
  { id: '8', centroId: '1', tipo: 'agua', cantidad: 4, unidad: 'litros', actualizadoEn: '2026-10-05T10:00:00' },
  { id: '9', centroId: '8', tipo: 'alimentos', cantidad: 42, unidad: 'kg', actualizadoEn: '2026-10-05T06:50:00' },
]

export async function listarDonaciones(): Promise<Donacion[]> {
  if (USE_MOCK) return mock.map((d) => ({ ...d }))

  // BACKEND: confirmar la ruta real. Debe traer las donaciones de los centros que gestiona la organización.
  return api<Donacion[]>('/admin/donaciones')
}

export async function crearDonacion(datos: DatosDonacion): Promise<Donacion> {
  if (USE_MOCK) {
    const nueva: Donacion = { ...datos, id: String(Date.now()), actualizadoEn: new Date().toISOString() }
    mock = [nueva, ...mock]
    return { ...nueva }
  }

  // BACKEND: endpoint para registrar una donación en un centro.
  return api<Donacion>('/admin/donaciones', { method: 'POST', body: JSON.stringify(datos) })
}

export async function actualizarCantidad(id: string, cantidad: number): Promise<Donacion> {
  if (USE_MOCK) {
    mock = mock.map((d) => (d.id === id ? { ...d, cantidad, actualizadoEn: new Date().toISOString() } : d))
    const donacion = mock.find((d) => d.id === id)
    if (!donacion) throw new Error('Donación no encontrada')
    return { ...donacion }
  }

  // BACKEND: endpoint para actualizar la cantidad disponible (entradas y salidas).
  return api<Donacion>(`/admin/donaciones/${id}`, { method: 'PATCH', body: JSON.stringify({ cantidad }) })
}
