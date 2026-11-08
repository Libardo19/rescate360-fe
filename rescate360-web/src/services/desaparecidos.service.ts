import { api, USE_MOCK } from './api'
import { desplazarFechas } from './mockTiempo'
import type { EstadoCaso, PersonaDesaparecida } from '../types/desaparecido'

// Datos de prueba, SOLO para desarrollo de la interfaz (personas ficticias).
let mock: PersonaDesaparecida[] = desplazarFechas([
  { id: '1', nombre: 'Laura Camila Ortiz', caracteristicas: '14 años, 1,55 m, cabello largo negro. Vestía uniforme escolar azul y morral rojo.', fotoUrl: null, ultimaUbicacion: { lat: 10.4712, lng: -73.2478 }, referenciaUbicacion: 'Calle 10 con Cra. 5', estadoCaso: 'buscando', reportadoPor: 'Diana Ortiz', telefonoContacto: '+57 310 222 1188', creadoEn: '2026-10-05T07:20:00' },
  { id: '2', nombre: 'José Antonio Mendoza', caracteristicas: '72 años, usa bastón, camisa blanca y pantalón gris. Tiene pérdida de memoria.', fotoUrl: null, ultimaUbicacion: { lat: 10.4558, lng: -73.2611 }, referenciaUbicacion: 'Barrio El Prado', estadoCaso: 'buscando', reportadoPor: 'Ana Mendoza', telefonoContacto: '+57 311 555 0021', creadoEn: '2026-10-04T18:05:00' },
  { id: '3', nombre: 'Kevin Andrés Ruiz', caracteristicas: '9 años, camiseta amarilla, tenis blancos. Se separó de su familia durante la evacuación.', fotoUrl: null, ultimaUbicacion: { lat: 10.4863, lng: -73.2659 }, referenciaUbicacion: 'Vereda La Esperanza', estadoCaso: 'buscando', reportadoPor: 'Marta Ruiz', telefonoContacto: '+57 300 987 6543', creadoEn: '2026-10-05T09:40:00' },
  { id: '4', nombre: 'Rosa Elena Pacheco', caracteristicas: '58 años, vestido floreado, lentes de marco café.', fotoUrl: null, ultimaUbicacion: { lat: 10.4627, lng: -73.2385 }, referenciaUbicacion: 'Cra. 19 #12-45', estadoCaso: 'encontrado', reportadoPor: 'Luis Pacheco', telefonoContacto: '+57 312 444 7766', creadoEn: '2026-10-02T11:30:00' },
], 'creadoEn')

export async function listarDesaparecidos(): Promise<PersonaDesaparecida[]> {
  if (USE_MOCK) return mock.map((p) => ({ ...p }))

  // BACKEND: confirmar la ruta real. Estos casos son visibles para todas las organizaciones.
  return api<PersonaDesaparecida[]>('/admin/personas-desaparecidas')
}

export async function cambiarEstadoCaso(id: string, estadoCaso: EstadoCaso): Promise<PersonaDesaparecida> {
  if (USE_MOCK) {
    mock = mock.map((p) => (p.id === id ? { ...p, estadoCaso } : p))
    const persona = mock.find((p) => p.id === id)
    if (!persona) throw new Error('Caso no encontrado')
    return { ...persona }
  }

  // BACKEND: endpoint para marcar un caso como encontrado o reabrirlo (queda en auditoría).
  return api<PersonaDesaparecida>(`/admin/personas-desaparecidas/${id}`, {
    method: 'PATCH',
    body: JSON.stringify({ estado_caso: estadoCaso }),
  })
}
