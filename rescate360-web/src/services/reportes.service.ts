import { api, USE_MOCK } from './api'
import { desplazarFechas } from './mockTiempo'
import type { Reporte, EstadoReporte } from '../types/reporte'

// Datos de prueba, SOLO para desarrollo de la interfaz.
let mock: Reporte[] = desplazarFechas([
  { id: '1', tipo: 'accidente', descripcion: 'Choque entre moto y carro, hay heridos leves.', ubicacion: 'Calle 10 #5-20', reportante: 'Juan Pérez', fecha: '2026-10-05T09:30:00', estado: 'pendiente', organizacionObjetivoId: 'org-1' },
  { id: '2', tipo: 'inundacion', descripcion: 'Se desbordó la quebrada, el agua entra a varias casas.', ubicacion: 'Barrio El Prado', reportante: 'María López', fecha: '2026-10-05T07:10:00', estado: 'verificado', organizacionObjetivoId: 'org-1', verificadoPor: 'Admin Demo' },
  { id: '3', tipo: 'robo', descripcion: 'Robo a un comercio en horas de la noche.', ubicacion: 'Parque Central', reportante: 'Carlos Rojas', fecha: '2026-10-04T21:45:00', estado: 'pendiente', organizacionObjetivoId: 'org-1' },
  { id: '4', tipo: 'deslizamiento', descripcion: 'Derrumbe parcial que bloquea la vía.', ubicacion: 'Vereda La Esperanza', reportante: 'Lucía Herrera', fecha: '2026-10-04T16:20:00', estado: 'pendiente', organizacionObjetivoId: 'org-1' },
  { id: '5', tipo: 'incendio', descripcion: 'Humo en el segundo piso de una vivienda.', ubicacion: 'Cra. 19 #12-45', reportante: 'Andrés Gómez', fecha: '2026-10-04T12:05:00', estado: 'verificado', organizacionObjetivoId: 'org-1', verificadoPor: 'Admin Demo' },
  { id: '6', tipo: 'inundacion', descripcion: 'Calle inundada tras la lluvia.', ubicacion: 'Barrio El Prado', reportante: 'Pedro Díaz', fecha: '2026-10-05T07:40:00', estado: 'duplicado', organizacionObjetivoId: 'org-1' },
  { id: '7', tipo: 'otro', descripcion: 'Poste de luz caído sobre la acera.', ubicacion: 'Av. Simón Bolívar #45', reportante: 'Sofía Mora', fecha: '2026-10-03T18:00:00', estado: 'rechazado', organizacionObjetivoId: 'org-1', verificadoPor: 'Admin Demo' },
  { id: '9', tipo: 'otro', descripcion: 'Dicen que hay humo cerca del río, sin más datos ni foto.', ubicacion: 'Sin dirección exacta', reportante: 'Anónimo', fecha: '2026-10-03T22:10:00', estado: 'no_verificable', organizacionObjetivoId: 'org-1', verificadoPor: 'Admin Demo' },
  { id: '8', tipo: 'accidente', descripcion: 'Vehículo volcado en la vía a la salida de la ciudad.', ubicacion: 'Vía Nacional km 3', reportante: 'Luis Castro', fecha: '2026-10-05T10:15:00', estado: 'pendiente', organizacionObjetivoId: 'org-1' },
], 'fecha')

export async function listarReportes(): Promise<Reporte[]> {
  if (USE_MOCK) return mock.map((r) => ({ ...r }))

  // BACKEND: confirmar la ruta real, los filtros y la forma de la respuesta.
  // El backend debe devolver SOLO los reportes cuyo organizacion_objetivo_id
  // es la organización del administrador (el super_admin ve todos).
  return api<Reporte[]>('/admin/reportes')
}

export async function cambiarEstadoReporte(
  id: string,
  estado: Exclude<EstadoReporte, 'pendiente'>,
): Promise<Reporte> {
  if (USE_MOCK) {
    mock = mock.map((r) => (r.id === id ? { ...r, estado } : r))
    const actualizado = mock.find((r) => r.id === id)
    if (!actualizado) throw new Error('Reporte no encontrado')
    return { ...actualizado }
  }

  // BACKEND: aquí van los endpoints de verificar, rechazar y marcar duplicado.
  return api<Reporte>(`/admin/reportes/${id}/estado`, {
    method: 'PATCH',
    body: JSON.stringify({ estado }),
  })
}