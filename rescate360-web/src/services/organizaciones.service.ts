import { api, USE_MOCK } from './api'
import type { Organizacion } from '../types/organizacion'

// Datos de prueba, SOLO para desarrollo de la interfaz.
// 'org-1' es la organización del administrador de prueba (admin@demo.com).
const MOCK: Organizacion[] = [
  { id: 'org-1', nombre: 'Cuerpo de Bomberos Valledupar', tipo: 'bomberos', telefonoContacto: '+57 605 574 0119', activa: true },
  { id: 'org-2', nombre: 'Cruz Roja Seccional Cesar', tipo: 'cruz_roja', telefonoContacto: '+57 605 571 2290', activa: true },
  { id: 'org-3', nombre: 'Defensa Civil Valledupar', tipo: 'defensa_civil', telefonoContacto: '+57 605 580 4433', activa: true },
  { id: 'org-4', nombre: 'Policía Metropolitana', tipo: 'policia', telefonoContacto: '123', activa: true },
]

// Lista de organizaciones activas, para reasignar solicitudes a otra entidad.
export async function listarOrganizaciones(): Promise<Organizacion[]> {
  if (USE_MOCK) return MOCK.map((o) => ({ ...o }))

  // BACKEND: confirmar la ruta real. Solo se necesitan las organizaciones activas.
  return api<Organizacion[]>('/organizaciones?activa=true')
}
